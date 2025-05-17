---
config:
  layout: elk
  theme: default
---
<!-- APPROACH ! -->
````mermaid
flowchart TD
    %% Authentication
    subgraph Auth["🔐 Authentication"]
    Face["🧑‍💼 Face Recognition"]
    Voice["🎤 Voice Recognition"]
    AccessLogs["📋 access_logs"]
    end

    %% Web Interface
    subgraph GUI["🖥️ Web Interface"]
    GUIClient["🗣️ User GUI"]
    GUICam["📸 Webcam"]
    GUIMic["🎙️ Microphone"]
    SessionManager["🔄 Session Manager"]
    end

    %% LLM + Routing
    subgraph LLM["🧠 LLM & Modalities"]
    Classifier["📊 Classifier"]
    Subgraphs["🕸️ LangGraph Subgraphs"]
    Planner["🛠️ Task Planner"]
    GeneralTask["💬 General Query"]
    SceneTask["👁️ Scene Query"]
    ActionTask["🎯 Action Task"]
    end

    %% Vision
    subgraph Vision["📸 Computer Vision"]
    Camera["📷 Intel RealSense"]
    Detector["🧩 Object Detection"]
    end

    %% Digital Simulation
    subgraph Sim["🌐 Simulation & Digital Twin"]
    IsaacSim["🧪 Isaac Sim"]
    SimResults["📈 simulation_results"]
    end

    %% Database
    subgraph DB["🗄️ PostgreSQL Database"]
    Users["👥 users"]
    UnifiedInstr["📝 unified_instructions"]
    GestureLib["✋ gesture_library"]
    GestureInstr["🖐️ gesture_instructions"]
    VoiceInstr["🎙️ voice_instructions"]
    CameraTable["🎯 camera_vision"]
    OpSeq["🧾 operation_sequence"]
    OpParams["⚙️ pick_op / travel_op / drop_op"]
    States["🔄 states"]
    USD["📦 usd_data"]
    TaskPrefs["🧠 task_preferences"]
    InteractMem["🧾 interaction_memory"]
    ISIMCtrl["🖱️ isaac_sim_gui"]
    SimMetrics["📊 simulation_results"]
    end

    %% Robot Control
    subgraph Robot["🤖 Robot Control"]
    ABB["🦾 ABB YuMi Robot"]
    IsaacSim --> ABB
    end

    %% Connections
    GUIClient --> SessionManager
    GUIClient --> GUICam & GUIMic
    GUICam --> Face
    GUIMic --> Voice
    GUIMic --> VoiceInstr
    SessionManager --> Face & Voice
    Face --> Users & AccessLogs
    Voice --> Users & AccessLogs
    SessionManager --> InteractMem

    GUIClient --> Classifier
    Classifier --> Subgraphs
    Subgraphs --> Planner
    Subgraphs --> GeneralTask & SceneTask & ActionTask
    GeneralTask --> Planner
    SceneTask --> Planner
    ActionTask --> Planner

    Planner --> UnifiedInstr
    Planner --> OpSeq & OpParams
    Planner --> States & TaskPrefs
    Planner --> USD

    Camera --> Detector --> CameraTable --> Planner
    CameraTable --> InteractMem
    GestureInstr --> UnifiedInstr
    VoiceInstr --> UnifiedInstr
    GestureLib --> GestureInstr

    OpSeq --> ABB & IsaacSim
    OpParams --> ABB & IsaacSim
    ISIMCtrl --> IsaacSim & GUIClient
    USD --> IsaacSim

    IsaacSim --> SimResults
    SimResults --> InteractMem & IsaacSim
    ABB --> InteractMem

    %% Styling
    classDef auth fill:#f9d776,stroke:#333,stroke-width:1px
    classDef gui fill:#b6e3a7,stroke:#333,stroke-width:1px
    classDef llm fill:#c6d6f3,stroke:#333,stroke-width:1px
    classDef vision fill:#f3b0b0,stroke:#333,stroke-width:1px
    classDef db fill:#e5e5e5,stroke:#333,stroke-width:1px
    classDef robot fill:#f7e0ad,stroke:#333,stroke-width:1px
    classDef sim fill:#e0ccff,stroke:#333,stroke-width:1px

    class Auth auth
    class GUI gui
    class LLM llm
    class Vision vision
    class DB db
    class Sim sim
    class Robot robot
````