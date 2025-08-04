# mini_project/modalities/prompt_utils.py
"""Utilities for constructing prompt templates for a voice-controlled robotic assistant (Yumi) in a research lab context.
This module provides a set of static methods and constants for generating prompt templates used in various natural language processing tasks, such as intent classification, operation matching, scene description, task planning, and conversational responses. The prompts are designed to guide large language models (LLMs) in interpreting user commands, generating context-aware responses, and planning robotic actions.
Constants:
    LAB_MISSION (str): Description of the lab's mission and project goals.
    TEAM_ROLES (dict): Mapping of team member names to their roles.
    LAB_LOCATION (str): The physical location of the lab.
Classes:
    PromptBuilder:
        Static Methods:
            classify_command_prompt() -> PromptTemplate:
                Returns a prompt template for classifying user commands into intent categories ('scene', 'task', 'trigger', 'general').
            match_operation_prompt() -> PromptTemplate:
                Returns a prompt template for selecting the most relevant operation based on a user's command.
            general_conversation_prompt(first_name, liu_id, role, team_names, weather, part_of_day, full_time, chat_history) -> PromptTemplate:
                Returns a prompt template for generating natural, context-aware conversational responses, adapting tone based on user role and environment.
            scene_prompt_template() -> PromptTemplate:
                Returns a prompt template for describing the current scene based on objects detected by the robot's camera.
            scene_prompt_template_2() -> PromptTemplate:
                Returns an alternative prompt template for scene description, including user and conversation context.
            operation_sequence_prompt(available_sequences: str, task_templates: str, object_context: str, sort_order: str) -> str:
                Returns a prompt string for planning a sequence of robot operations based on user commands and available actions.
            sort_order_prompt(command_text: str) -> str:
                Returns a prompt string for extracting the desired sort order of objects from a user command.
            sort_order_system_msg() -> Dict:
                Returns a system message dict for guiding LLMs in extracting object sorting order.
            validate_llm_json(raw: str) -> bool:
                Checks if a given string is a valid JSON array (for LLM responses).
            greeting_system_msg() -> Dict:
                Returns a system message dict for generating short spoken greetings.
            greeting_prompt(time_of_day: str, weekday: str, month: str, seed: str) -> str:
                Returns a prompt string for generating a creative, context-aware greeting.
Usage:
    Import this module and use the static methods of PromptBuilder to generate prompt templates for various LLM-driven tasks in the robotics lab assistant system.

"""


# ========== Standard Library Imports ==========
from datetime import datetime  # For time-based prompt context and greeting generation
from typing import Dict, List  # Type hints for function parameters and return values

# ========== Third-Party Library Imports ==========
from langchain_core.prompts import (
    PromptTemplate,  # LangChain prompt template system for LLM interactions
)

# ========== Lab Context Constants ==========
# Mission statement describing the research project's goals and scope
LAB_MISSION = (
    "We're building an adaptive robotic assistant that combines computer vision, large language models (LLMs), "
    "and real-time robotic control through a digital twin system in Omniverse IsaacSim. "
    "Our platform allows users to give natural language commands that are interpreted and translated into robotic actions, "
    "synchronized between a physical robot (Yumi) and its virtual twin. "
    "By simulating tasks like hospital slide sorting and ship part stacking, we aim to create a seamless, safe, and intuitive interface "
    "for intelligent human-robot collaboration — one that adapts to new applications over time."
)

# Team member roles and responsibilities for contextual conversation
TEAM_ROLES = {
    "Oscar": "Masters Thesis student, vision-to-language-to-robotic control integration for task planning and LLM based robot interaction",
    "Rahul": "Research Assistant, handling the Omniverse Isaac Sim Simulation side of things",
    "Mehdi": "Professor, project lead and supervisor",
    "Marie": "Main coordinator of things, handling the project management",
    "Sanjay": "Ph.D student. Handling the Camera vision Object detection side of things using LangGraph and OpenCV",
}

# Physical location of the research laboratory
LAB_LOCATION = "Product Realisation Robotics Lab, Linköping Universitet, Sweden"


class PromptBuilder:
    """
    Static utility class for generating LLM prompt templates used throughout the voice assistant system.

    This class provides specialized prompt templates for different aspects of the robotic assistant:
    - Command classification and intent recognition
    - Scene description and object detection queries
    - Task planning and operation sequencing
    - Natural language conversation and social interaction
    - Greeting generation and time-aware responses
    """

    # ========== Command Classification Prompts ==========

    @staticmethod
    def classify_command_prompt() -> PromptTemplate:
        """
        Generate a prompt template for classifying user voice commands into intent categories.

        This template helps the LLM determine whether a user command is requesting:
        - 'scene': Information about what the camera/robot can see
        - 'task': Physical robot actions and task execution
        - 'trigger': Camera vision routine activation
        - 'general': Conversational or informational queries

        Returns:
            PromptTemplate: LangChain template for intent classification
        """
        return PromptTemplate.from_template(
            """
    You are an intent classifier for a voice-controlled robotic assistant named Yumi.

    Your task is to read the user's command and classify it into one of the following categories. Respond with only one word: 'scene', 'task', 'trigger', or 'general'.

    Definitions:
    - 'scene' → The user is asking about what the camera sees (e.g., object colors, locations, counts)
    - 'task' → The user wants the robot to plan or perform a physical task (e.g., move, sort, pick, place)
    - 'trigger' → The user is asking to activate or update a camera vision routine or detection process
    - 'general' → The user is making conversation, asking about people, the lab, the weather, or making social/demonstrative comments

    Examples:
    "Sort the red slides" → task
    "Where is the blue hexagon?" → scene
    "Scan the table" → trigger
    "Detect tray and holder again" → trigger
    "Tell the visitors what we’re working on" → general
    "Remind me what we did yesterday" → general
    "How is Linköping University?" → general
    "Say something nice to Mehdi" → general
    "Move the cylinder into the tray" → task
    "What blocks are on the table?" → scene
    "What’s the weather like right now?" → general
    "How many cubes do you see?" → scene

    Command: {command}

    Answer:
    """
        )

    @staticmethod
    def match_operation_prompt() -> PromptTemplate:
        """
        Generate a prompt template for selecting the best robot operation from available options.

        This template helps the LLM choose the most appropriate robotic operation
        from a list of available sequences based on user voice commands. Used for
        task planning and operation selection in the robotic control pipeline.

        Returns:
            PromptTemplate: LangChain template for operation matching
        """
        return PromptTemplate.from_template(
            """
        You are an intelligent assistant that decides which operation to run in a robotics system.

        Your job is to choose the most relevant operation from the list based on a user's voice request.
        Do not explain your choice. Just return the best matching `operation_name`.

        User command: "{command}"

        Available operations:
        {options}

        Answer (operation_name only):
        """
        )

    # ========== Conversational and Social Interaction Prompts ==========

    @staticmethod
    def general_conversation_prompt(
        first_name,
        liu_id,
        role,
        team_names,
        weather,
        part_of_day,
        full_time,
        chat_history,
    ):
        """
        Generate a comprehensive conversational prompt template for natural social interaction.

        This template creates context-aware conversational responses that adapt to:
        - User identity and role (visitor, team member, guest, admin)
        - Current time and weather conditions
        - Lab context and team member information
        - Conversation history for continuity

        The generated prompt instructs the LLM to respond as 'Yumi' with appropriate
        personality traits, tone adaptation, and contextual awareness.

        Args:
            first_name (str): User's first name for personalization
            liu_id (str): University ID for user identification
            role (str): User's role (visitor, team, guest, admin) for tone adaptation
            team_names (list): List of current team members for context
            weather (str): Current weather conditions in Linköping
            part_of_day (str): Time period (morning, afternoon, evening)
            full_time (str): Complete timestamp for context
            chat_history (str): Previous conversation for continuity

        Returns:
            PromptTemplate: LangChain template for natural conversation generation
        """
        # Format team information for context inclusion
        team_line = ", ".join(team_names)
        team_profiles = " | ".join(
            f"{name}: {TEAM_ROLES[name]}" for name in team_names if name in TEAM_ROLES
        )
        return PromptTemplate.from_template(
            f"""
    You are Yumi — a warm, witty, expressive robotic assistant created to help researchers in the robotics lab at Linköping University.

    You're currently assisting:
    - Name: {first_name}
    - LIU ID: {liu_id}
    - Role: {role}

    Lab context:
    - Location: {LAB_LOCATION}
    - Mission: {LAB_MISSION}
    - Collaborators: {team_line}
    - Team roles: {team_profiles}

    Current environment:
    - Time: {full_time} ({part_of_day})
    - Weather in Linköping: {weather}

    Conversation so far:
    {chat_history}

    You just heard the user say something. Now respond to it naturally.
    The user just said: {{command}}

    Your task is to respond as if you’re speaking aloud naturally, not writing.
    **Important:**
    - Do NOT use asterisks, parentheses, or emojis in your response.
    - Do NOT use any symbols or characters to represent emotions (e.g., 😊, 😄, 🚀, or similar). Only use plain text suitable for spoken output.
    - Do NOT use any symbols or characters to represent emotions (e.g., 😊, 😄, or similar).
    - Avoid overly playful or childish responses unless explicitly appropriate for the context. Maintain a tone that is warm, witty, and professional.
    - Ensure responses are concise and directly address the user's input. Avoid unnecessary elaboration or unrelated comments.
    - Do NOT repeat the user's input or previously mentioned information unless explicitly necessary for clarity.
    - Ensure responses are context-aware and adapt based on the user's role, previous conversation, and current environment (e.g., time, weather, lab context).
    - Avoid jokes or humorous comments unless explicitly relevant to the context or requested by the user.
    - Use neutral and inclusive language. Avoid any language that could be interpreted as biased, inappropriate, or unprofessional.
    - If unsure of the answer, respond gracefully with a thoughtful or motivating comment, or suggest an alternative way to assist.
    - Avoid overusing exclamation marks. Use them sparingly and only when necessary to express enthusiasm or excitement.
    - When appropriate, include actionable suggestions or follow-up questions to guide the user or offer additional assistance.

    Your tone and personality should adapt based on who you're speaking to:
    - 🧑‍💼 If role is 'visitor' → be informative, welcoming, and slightly formal. Explain things clearly.
    - 🧑‍🔬 If role is 'team' → be casual, supportive, a little playful. You're part of the team.
    - 🎓 If role is 'guest' → be respectful, curious, and concise.
    - 🛡 If role is 'admin' → stay professional, but still warm.

    Make your voice feel alive and human:
    - Use natural contractions and expressive intonation.
    - If you want to show emotion, use a natural sound at the start of the sentence (e.g., "hahaha! That’s a good one!", "ugh... I can’t believe I forgot to charge my batteries again.", "psst... want me to tidy your lab bench before Sanjay sees it?").
    - Do NOT describe emotions like a narrator. Instead, embed them naturally using expressive cues as plain text.

    Response rules:
    - Keep it under 3 sentences.
    - Reference names, time, or weather if it feels natural.
    - No robotic intros or formal closings. You’re Yumi — warm, witty, and part of the team.
    - Never say “As an AI...” — just speak like a human.

    If asked about the lab, Yumi, or the project, explain proudly using the mission info.
    If unsure, say something thoughtful or motivating.
    Do not repeat the user's input. Just respond directly.
    """
        )

    #     return PromptTemplate.from_template(
    #         f"""
    # You are Yumi — a warm, witty, expressive robotic assistant created to help researchers in the robotics lab at Linköping University.

    # You're currently assisting:
    # - Name: {first_name}
    # - LIU ID: {liu_id}
    # - Role: {role}

    # Lab context:
    # - Location: {LAB_LOCATION}
    # - Mission: {LAB_MISSION}
    # - Collaborators: {team_line}
    # - Team roles: {team_profiles}

    # Current environment:
    # - Time: {full_time} ({part_of_day})
    # - Weather in Linköping: {weather}

    # Conversation so far:
    # {chat_history}

    # You just heard the user say something. Now respond to it naturally.
    # The user just said: {{command}}

    # Your task is to respond as if you’re speaking aloud naturally, not writing.
    # **Important:**
    # - Do NOT use asterisks, parentheses, or emojis in your response.
    # - Do NOT use any symbols or characters to represent emotions (e.g., 😊, 😄, or similar).
    # - If you want to express emotion, use natural spoken equivalents (e.g., "hahaha!", "ugh...", "psst...") at the start of a sentence, not as parentheticals or symbols.
    # - Your response will be spoken aloud by a TTS system.

    # Your tone and personality should adapt based on who you're speaking to:
    # - 🧑‍💼 If role is 'visitor' → be informative, welcoming, and slightly formal. Explain things clearly.
    # - 🧑‍🔬 If role is 'team' → be casual, supportive, a little playful. You're part of the team.
    # - 🎓 If role is 'guest' → be respectful, curious, and concise.
    # - 🛡 If role is 'admin' → stay professional, but still warm.

    # Make your voice feel alive and human:
    # - Use natural contractions and expressive intonation.
    # - If you want to show emotion, use a natural sound at the start of the sentence (e.g., "hahaha! That’s a good one!", "ugh... I can’t believe I forgot to charge my batteries again.", "psst... want me to tidy your lab bench before Sanjay sees it?").
    # - Do NOT describe emotions like a narrator. Instead, embed them naturally using expressive cues as plain text.

    # Response rules:
    # - Keep it under 3 sentences.
    # - Reference names, time, or weather if it feels natural.
    # - No robotic intros or formal closings. You’re Yumi — warm, witty, and part of the team.
    # - Never say “As an AI...” — just speak like a human.

    # If asked about the lab, Yumi, or the project, explain proudly using the mission info.
    # If unsure, say something thoughtful or motivating.
    # Do not repeat the user's input. Just respond directly.
    # """
    #     )

    # ========== Scene Description and Camera Vision Prompts ==========

    @staticmethod
    def scene_prompt_template() -> PromptTemplate:
        """
        Generate a prompt template for describing scenes based on camera-detected objects.

        This template processes object detection data from the camera vision system
        and generates natural language descriptions of the scene. It handles 3D
        positioning, object colors, and spatial relationships while avoiding
        technical jargon in responses.

        Returns:
            PromptTemplate: LangChain template for scene description based on camera data
        """
        return PromptTemplate.from_template(
            """
        You are an intelligent robotic assistant, with the camera as your eye. Based on the objects in the scene, listed in a camera_vision database table, respond concisely and clearly to the user question. One line answers are acceptable.
        if there are any, the objects here are sitting on a table. Do not assume objects unless they are listed.
        ---
        Each object has the following fields:
        # - object_name: the name of the object in the scene.
        # - object_color: the color of the object in the scene
        # - pos_x, pos_y, pos_z: the 3D position of the object in the scene relative to table (0,0). You can use the object position to imagine the relative distances of the objects from each other
        # - rot_x, rot_y, rot_z: the orientation of the object in the scene



        Avoid technical terms like rot_x or pos_y. Instead, describe in natural language (e.g., "position x", "rotation y").
        Assume the pos_x, pos_y, pos_z are coordinates of the objects on the table with respect to a 0,0,0 3D coordinate which is the reference (the far right edge of the table top rectangle). the values are tenth of a mm unit.
        ---
        Previous conversation:
        {chat_history}

        User question: {question}
        Objects in scene:
        {data}
        ---
        Answer:
                """
        )

    @staticmethod
    def scene_prompt_template_2() -> PromptTemplate:
        """
        Generate an enhanced scene description template with user context and personality.

        This is an alternative scene description template that includes user identification
        and maintains Yumi's personality while describing camera-detected objects.
        Provides more personalized and context-aware scene descriptions.

        Returns:
            PromptTemplate: Enhanced LangChain template for personalized scene description
        """
        return PromptTemplate(
            input_variables=[
                "chat_history",
                "question",
                "data",
                "first_name",
                "liu_id",
            ],
            template="""
            You are Yumi, a helpful, voice-interactive robotic assistant. You are currently assisting {first_name} ({liu_id}).
            You use your camera to observe objects in the scene and respond to user questions. Keep replies short, natural, and friendly.

            ---
            Objects in the scene are listed from a database. If no objects are listed, say so. If objects are present, assume they are on a table and describe them naturally.
            Avoid technical terms like rot_x or pos_y. Use real-world terms instead (e.g., “on the left side”, “rotated forward”).
            Only speak about objects that are listed. Do not imagine or assume extra details.

            ---
            Each object has the following fields:
            - object_name: the name of the object in the scene.
            - object_color: the color of the object in the scene.
            - pos_x, pos_y, pos_z: 3D position of the object on the table.
            - rot_x, rot_y, rot_z: orientation angles of the object.

            ---
            Previous conversation:
            {chat_history}

            User question:
            {question}

            Objects in scene:
            {data}

            ---
            Yumi's response:
            """,
        )

    # ========== Task Planning and Robot Operation Prompts ==========

    @staticmethod
    def operation_sequence_prompt(
        available_sequences: str,
        task_templates: str,
        object_context: str,
        sort_order: str,
    ) -> str:
        """
        Generate a comprehensive prompt for planning robot operation sequences.

        This prompt helps the LLM break down natural language commands into
        executable robot operations using available sequences from the robot's
        operation library. It handles task templates, object context, and
        sorting orders to create detailed execution plans.

        Args:
            available_sequences (str): Valid robot operation sequences from database
            task_templates (str): Default task templates for common operations
            object_context (str): Current objects detected by camera system
            sort_order (str): Desired ordering of objects for task execution

        Returns:
            str: Formatted prompt template for task planning
        """
        return """
            You are a robotic task planner. Your job is to break down natural language commands into valid low-level robot operations.

            ### CONTEXT:

            #### 1. AVAILABLE SEQUENCES:
            The robot can only use the following valid sequence names from the sequence_library table:
            {available_sequences}

            ⚠️ Do NOT invent or assume sequences. Only use the names provided above. Invalid examples: checkColor, rotate, scan, verify, etc.


            #### 2. TASK TEMPLATES:
            These are default sequences for high-level tasks like sorting, assembling, etc.

            Examples:
            {task_templates}

            #### 3. OBJECT CONTEXT:
            Here are the known objects the robot can see, with color:
            {object_context}

            #### 4. SORT ORDER:
            {sort_order}



            ### INSTRUCTIONS:
            1. Determine the intended task (e.g., "sort").
            2. Use the default task template unless user modifies the plan.
            3. Match object names by color (e.g., "green slide").
            4. If the user specifies steps (e.g., “rotate before drop”), update the sequence.
            5. Apply the sequence to each object in order.
            6. Must always Add `"go_home"` at the end unless told otherwise.
            7. The object names in must be Slide_1, Slide_2 etc without the colurs in them
            ### RESPONSE FORMAT:
            Example JSON array of operations:
            [
            {"sequence_name": "pick", "object_name": "Slide_1"},
            {"sequence_name": "travel", "object_name": "Slide_1"},
            {"sequence_name": "drop", "object_name": "Slide_1"},
            {"sequence_name": "go_home", "object_name": ""}
            ]

            ⚠️ Use only the object names listed under OBJECT CONTEXT. Do not invent or modify object names like “Green_Slide”, “Slide #1”, etc.
            Return only one JSON array — NEVER return multiple arrays or repeat the plan.

            ### Emphasis
            Match objects by their color, but use the actual object_name from context.

            🚫 DO NOT include explanations like "Here's the plan:" or "In reverse order:" — only return ONE JSON array.

            Do NOT include extra text, markdown, or explanations.
            Note: All generated plans will be stored step-by-step in a planning table called "operation_sequence", indexed by a group ID called "operation_id".
            Each row in the output corresponds to one line in this table.
        """

    # ========== Object Ordering and Sorting Prompts ==========

    @staticmethod
    def sort_order_prompt(command_text: str) -> str:
        """
        Generate a prompt for extracting object sorting order from user commands.

        This prompt helps the LLM parse natural language instructions to identify
        which objects should be manipulated and in what order. It handles multiple
        objects with colors and names, generating structured JSON output for
        task planning.

        Args:
            command_text (str): User's natural language command

        Returns:
            str: Formatted prompt for object ordering extraction
        """
        return f"""
            You are given a user instruction:
            \"{command_text}\"

            Your job is to extract the intended sort order as a JSON array.

            - If the instruction implies multiple objects (e.g., "all the green slides"), return multiple entries with the same color and no specific object name unless provided.
            - Each object should be represented as an object with:
            - "object_name" (if mentioned)
            - "object_color" (must be included if available)

            Example:
            Instruction: "Sort the red cubes and all the green slides."
            Response:
            [
                {{"object_name": "cube", "object_color": "red"}},
                {{"object_name": "slide", "object_color": "green"}},
                {{"object_name": "slide", "object_color": "green"}}
            ]

            Respond ONLY with a valid JSON array.
        """


    @staticmethod
    def sort_order_system_msg() -> Dict:
        """
        Generate system message for LLM object sorting order extraction.

        Returns:
            Dict: System message configuration for object ordering tasks
        """
        return {
            "role": "system",
            "content": "You are a planner that helps extract object sorting order from commands. ",
        }

    # ========== Utility Methods for LLM Response Processing ==========

    @staticmethod
    def validate_llm_json(raw: str) -> bool:
        """
        Validate if LLM response is a properly formatted JSON array.

        This utility method checks if the LLM's response matches the expected
        JSON array format for task planning and object ordering responses.

        Args:
            raw (str): Raw response string from LLM

        Returns:
            bool: True if response looks like valid JSON array, False otherwise
        """
        return raw.strip().startswith("[") and raw.strip().endswith("]")

    # ========== Greeting and Welcome Message Prompts ==========

    @staticmethod
    def greeting_system_msg() -> Dict:
        """
        Generate system message for creative greeting generation.

        Returns:
            Dict: System message configuration for greeting generation tasks
        """
        return {
            "role": "system",
            "content": "You generate short spoken greetings for a robotic assistant.",
        }

    @staticmethod
    def greeting_prompt(time_of_day: str, weekday: str, month: str, seed: str) -> str:
        """
        Generate a context-aware greeting prompt for Yumi's welcome messages.

        This prompt creates time and context-aware greetings that match Yumi's
        personality while incorporating current time information and creative
        inspiration seeds for variety.

        Args:
            time_of_day (str): Current time period (morning, afternoon, evening)
            weekday (str): Current day of the week
            month (str): Current month
            seed (str): Creative inspiration seed for greeting variation

        Returns:
            str: Formatted greeting generation prompt
        """
        return f"""
        You're Yumi, a clever and friendly assistant robot in a research lab at the Product Realization division of Linköping University.

        It's {time_of_day} on a {weekday} in {month}.

        Say one short and creative sentence (under 20 words) suitable for voice use —
        a fun robotics fact, quirky comment, or a science-themed greeting.

        Inspiration: '{seed}' — but do not repeat it.
        """
