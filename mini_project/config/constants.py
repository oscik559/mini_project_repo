# mini_project/config/constants.py
"""
This module defines constant values used throughout the mini_project application.
Constants:
    VOICE_TABLE (str): Name of the database table for voice instructions.
    GESTURE_TABLE (str): Name of the database table for gesture instructions.
    PROCESSED_COL (str): Name of the column indicating processed instructions.
    UNIFIED_TABLE (str): Name of the unified instructions table.
    WHISPER_LANGUAGE_NAMES (dict): Maps language codes to their English names for use with the Whisper voice processor.
    WAKE_RESPONSES (list): List of possible responses when the system is activated or addressed.
    GENERAL_TRIGGERS (set): Set of keywords or phrases that trigger general-purpose actions or queries.
    TASK_VERBS (set): Set of verbs related to task execution, such as sorting or moving.
    QUESTION_WORDS (set): Set of words and phrases used to identify questions.
    CONFIRM_WORDS (set): Set of words and phrases used to confirm actions.
    CANCEL_WORDS (set): Set of words and phrases used to cancel or stop actions.
    TRIGGER_WORDS (set): Set of words and phrases that trigger specific system actions.
"""


# Synchronizer Constants
VOICE_TABLE = "voice_instructions"
GESTURE_TABLE = "gesture_instructions"
PROCESSED_COL = "processed"
UNIFIED_TABLE = "unified_instructions"

# Voice Processor Constants
WHISPER_LANGUAGE_NAMES = {
    "en": "english",
    "zh": "chinese",
    "de": "german",
    "es": "spanish",
    "ru": "russian",
    "ko": "korean",
    "fr": "french",
    "ja": "japanese",
    "pt": "portuguese",
    "tr": "turkish",
    "pl": "polish",
    "ca": "catalan",
    "nl": "dutch",
    "ar": "arabic",
    "sv": "swedish",
    "it": "italian",
    "id": "indonesian",
    "hi": "hindi",
    "fi": "finnish",
    "vi": "vietnamese",
    "he": "hebrew",
    "uk": "ukrainian",
    "el": "greek",
    "ms": "malay",
    "cs": "czech",
    "ro": "romanian",
    "da": "danish",
    "hu": "hungarian",
    "ta": "tamil",
    "no": "norwegian",
    "th": "thai",
    "ur": "urdu",
    "hr": "croatian",
    "bg": "bulgarian",
    "lt": "lithuanian",
    "la": "latin",
    "mi": "maori",
    "ml": "malayalam",
    "cy": "welsh",
    "sk": "slovak",
    "te": "telugu",
    "fa": "persian",
    "lv": "latvian",
    "bn": "bengali",
    "sr": "serbian",
    "az": "azerbaijani",
    "sl": "slovenian",
    "kn": "kannada",
    "et": "estonian",
    "mk": "macedonian",
    "br": "breton",
    "eu": "basque",
    "is": "icelandic",
    "hy": "armenian",
    "ne": "nepali",
    "mn": "mongolian",
    "bs": "bosnian",
    "kk": "kazakh",
    "sq": "albanian",
    "sw": "swahili",
    "gl": "galician",
    "mr": "marathi",
    "pa": "punjabi",
    "si": "sinhala",
    "km": "khmer",
    "sn": "shona",
    "yo": "yoruba",
    "so": "somali",
    "af": "afrikaans",
    "oc": "occitan",
    "ka": "georgian",
    "be": "belarusian",
    "tg": "tajik",
    "sd": "sindhi",
    "gu": "gujarati",
    "am": "amharic",
    "yi": "yiddish",
    "lo": "lao",
    "uz": "uzbek",
    "fo": "faroese",
    "ht": "haitian creole",
    "ps": "pashto",
    "tk": "turkmen",
    "nn": "nynorsk",
    "mt": "maltese",
    "sa": "sanskrit",
    "lb": "luxembourgish",
    "my": "myanmar",
    "bo": "tibetan",
    "tl": "tagalog",
    "mg": "malagasy",
    "as": "assamese",
    "tt": "tatar",
    "haw": "hawaiian",
    "ln": "lingala",
    "ha": "hausa",
    "ba": "bashkir",
    "jw": "javanese",
    "su": "sundanese",
    "yue": "cantonese",
}


WAKE_RESPONSES = [
    "yes?",
    "I'm listening",
    "what's up?",
    "go ahead.",
    "at your service.",
    "hello?",
    "I'm here!",
    "you called?",
    "what do you want?",
    "I'm listening.",
    "hi?",
    "what is it?",
]
GENERAL_TRIGGERS = {
    "weather",
    "who is",
    "linköping",
    "university",
    "say something",
    "remind",
    "recap",
    "explain",
    "lab",
    "appreciate",
    "motivate",
    "how are we doing",
    "tell us about",
    "introduce",
    "location",
    "where is",
    "project",
    "working on",
    "colleague",
    "summary",
}
TASK_VERBS = {
    "sort",
    "move",
    "place",
    "assemble",
    "pick",
    "drop",
    "grab",
    "stack",
    "push",
    "pull",
}
QUESTION_WORDS = {
    "what",
    "where",
    "which",
    "who",
    "how many",
    "is there",
    "are there",
}
CONFIRM_WORDS = {
    "yes",
    "sure",
    "okay",
    "go ahead",
    "absolutely",
    "yep",
    "definitely",
    "please do",
}
CANCEL_WORDS = {"no", "cancel", "not now", "stop", "never mind", "don't"}
TRIGGER_WORDS = {
    "detect",
    "refresh",
    "capture",
    "scan",
    "trigger",
}
