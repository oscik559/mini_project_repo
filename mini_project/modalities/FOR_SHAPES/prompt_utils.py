from datetime import datetime
from typing import Dict, List

from langchain_core.prompts import PromptTemplate


class PromptBuilder:
    @staticmethod
    def scene_prompt_template() -> PromptTemplate:
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

        ---
        if the object is a slide, it will have a usd_name of slide.usd, and the holder object will have a usd_name of holder.usd
        any objects with object_name that does not start with "slide..." are not slides
        ---

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
