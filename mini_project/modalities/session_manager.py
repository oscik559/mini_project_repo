# mini_project/modalities/session_manager.py
"""SessionManager handles user authentication and session management using face and voice modalities.
Classes:
    SessionManager: Manages user authentication (face and voice), session creation, cancellation, and retry.
SessionManager Methods:
    __init__(face_auth: FaceAuthSystem = None, voice_auth: VoiceAuth = None)
        Initializes the SessionManager with optional face and voice authentication modules.
    authenticate_user()
        Attempts to authenticate a user via face recognition. If the face is not recognized, initiates manual registration.
        After successful face authentication or registration, checks for an existing voice embedding and prompts for voice registration if absent.
        Returns the authenticated user dictionary or None if authentication fails.
    create_session()
        Generates a new unique session ID, marks the session as running, and logs the session creation.
        Returns the session ID.
    cancel_session()
        Cancels the current session if active and logs the action.
    retry_session()
        Cancels the current session (if any) and creates a new session.
        Returns the new session ID.
"""


# ========== Standard Library Imports ==========
import logging  # For structured logging of authentication and session events
import uuid  # For generating unique session identifiers

# ========== Local Project Imports ==========
# Authentication modules for face and voice recognition
from mini_project.authentication._face_auth import FaceAuthSystem
from mini_project.authentication._voice_auth import VoiceAuth

# Configuration paths for database and audio file storage
from mini_project.config.app_config import DB_PATH, TEMP_AUDIO_PATH, VOICE_DATA_PATH

# Initialize logger for this module
logger = logging.getLogger("SessionManager")


class SessionManager:
    """
    Manages user authentication and session lifecycle for the multi-modal interaction system.

    This class coordinates face and voice authentication, handles session creation and management,
    and maintains user state throughout the interaction session.
    """

    def __init__(self, face_auth: FaceAuthSystem = None, voice_auth: VoiceAuth = None):
        """
        Initialize the SessionManager with authentication modules.

        Args:
            face_auth (FaceAuthSystem, optional): Face authentication system instance.
                                                 If None, creates a new instance.
            voice_auth (VoiceAuth, optional): Voice authentication system instance.
                                            If None, creates a new instance.
        """
        # Initialize authentication modules - create new instances if not provided
        self.face_auth = face_auth if face_auth else FaceAuthSystem()
        self.voice_auth = voice_auth if voice_auth else VoiceAuth()

        # Session state management
        self.session_id = None  # Unique identifier for the current session
        self.authenticated_user = (
            None  # User info dict with keys: 'liu_id', 'first_name', 'last_name', etc.
        )
        self.running = False  # Flag indicating if a session is currently active

    def authenticate_user(self):
        """
        Perform comprehensive user authentication using face recognition and voice enrollment.

        Authentication Flow:
        1. Attempt face identification using camera input
        2. If face not recognized, initiate manual user registration
        3. After successful face auth, check for existing voice embedding
        4. If no voice data exists, prompt user for voice registration

        Returns:
            dict or None: User information dictionary containing 'liu_id', 'first_name',
                         'last_name', and other user details if authentication succeeds,
                         None if authentication fails or user declines registration.
        """
        # ========== Phase 1: Face Authentication ==========
        logger.info("🟡 Attempting face authentication...")
        user = self.face_auth.identify_user()

        # Handle case where face is not recognized in the system
        if not user:
            logger.warning(
                "🔴 Face not recognized. Initiating manual face registration..."
            )
            # Prompt user to register their face in the system
            registered = self.face_auth.register_user()
            if not registered:
                logger.warning("🚫 User declined registration. Session halted.")
                return None

            # Refresh the face recognition index with new data and retry identification
            self.face_auth._refresh_index()
            user = self.face_auth.identify_user()
            if not user:
                logger.error("❌ User authentication failed after registration.")
                return None

        # Store authenticated user information in session state
        self.authenticated_user = user
        logger.info(
            f"✅ Successful face authentication. Welcome {user['first_name']} {user['last_name']} (liu_id: {user['liu_id']})"
        )

        # ========== Phase 2: Voice Enrollment Check ==========
        logger.info(f"🟡 Initiating voice enrollment verification...")
        embedding = self.authenticated_user.get("voice_embedding")
        logger.info(f"🟡 Checking for existing voice embedding...")

        # Check if user has existing voice data in the system
        if not embedding or len(embedding) == 0:
            logger.info(f"🟢 No voice embedding found for user...")
            # Prompt user for voice registration to enable voice-based interactions
            confirm = (
                input("🎤 Would you like to register your voice now? (y/n): ")
                .strip()
                .lower()
            )
            if confirm == "y":
                try:
                    # Register voice embedding for the authenticated user
                    self.voice_auth.register_voice_for_user(
                        first_name=self.authenticated_user["first_name"],
                        last_name=self.authenticated_user["last_name"],
                        liu_id=self.authenticated_user["liu_id"],
                    )
                    logger.info("✅ Voice registration completed successfully.")
                except Exception as e:
                    logger.error(f"❌ Voice registration failed: {str(e)}")
            else:
                # User chose to skip voice registration - proceed without voice capabilities
                logger.info("🟡 Voice registration skipped by user request.")
        else:
            # User already has voice data registered - no action needed
            logger.info(
                "✅ Voice embedding already exists. Skipping voice registration."
            )

        # Return authenticated user data for session use
        return self.authenticated_user

    # ========== Session Management Methods ==========

    def create_session(self):
        """
        Create a new interaction session with unique identifier.

        Generates a UUID-based session ID and marks the session as active.
        This session ID can be used for tracking user interactions and
        maintaining state throughout the conversation.

        Returns:
            str: Unique session identifier (UUID string)
        """
        # Generate unique session identifier
        self.session_id = str(uuid.uuid4())
        self.running = True
        logger.info(f"✅ New session created with ID: {self.session_id}")
        return self.session_id

    def cancel_session(self):
        """
        Terminate the current active session.

        Sets the running flag to False and logs the cancellation.
        Handles graceful session termination with appropriate logging.
        """
        if self.running:
            logger.info(f"🟡 Cancelling session: {self.session_id}")
            self.running = False
        else:
            logger.info("🔴 No active session to cancel.")

    def retry_session(self):
        """
        Reset the current session and create a fresh one.

        This method cancels any existing session and immediately creates
        a new session with a new UUID. Useful for handling errors or
        user requests to restart their interaction session.

        Returns:
            str: New unique session identifier (UUID string)
        """
        # Cancel any existing session first
        self.cancel_session()
        # Create and return a new session ID
        return self.create_session()
