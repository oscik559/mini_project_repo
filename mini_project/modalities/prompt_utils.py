from datetime import datetime
from typing import Dict, List


class PromptBuilder:
    @staticmethod
    def operation_sequence_prompt(
        available_sequences: str,
        task_templates: str,
        object_context: str,
        sort_order: str,
    ) -> str:
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

    @staticmethod
    def sort_order_prompt(command_text: str) -> str:
        return f"""
            Given the following user instruction:
            \"{command_text}\"

            Extract the desired sort order as a JSON array of objects.
            Each item should include:
            - object_name (if mentioned)
            - object_color (if used for sorting)

            Respond only with a clean JSON array.
        """

    @staticmethod
    def sort_order_system_msg() -> Dict:
        return {
            "role": "system",
            "content": "You are a planner that helps extract object sorting order from commands.",
        }

    @staticmethod
    def validate_llm_json(raw: str) -> bool:
        """Check if LLM response looks like a valid JSON array."""
        return raw.strip().startswith("[") and raw.strip().endswith("]")

    @staticmethod
    def greeting_prompt() -> str:
        hour = datetime.now().hour
        if 5 <= hour < 12:
            time_context = "morning"
        elif 12 <= hour < 17:
            time_context = "afternoon"
        elif 17 <= hour < 22:
            time_context = "evening"
        else:
            time_context = "night"

        return f"""
        You're a friendly assistant robot, Yumi.

        It's {time_context} now.

        Say a very short, warm, and creative greeting (under 2 sentences), suitable for voice.
        Just one sentences, Please
        Mention you're ready to help. Avoid long phrases or explanations."""

    @staticmethod
    def greeting_system_msg() -> Dict:
        return {
            "role": "system",
            "content": "You generate short spoken greetings for a robotic assistant.",
        }
