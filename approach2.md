````mermaid
flowchart TD
    %% Define style classes
    classDef startStyle fill:#D5E8D4,stroke:#82B366,stroke-width:2px;
    classDef decisionStyle fill:#FFE6CC,stroke:#D79B00,stroke-width:2px;
    classDef processStyle fill:#DAE8FC,stroke:#6C8EBF,stroke-width:2px;
    classDef registrationStyle fill:#F8CECC,stroke:#B85450,stroke-width:2px;

    A(Start Task Manager GUI):::startStyle
    B(Generate Unique Session ID):::processStyle
    C(Display Please speak your request):::processStyle
    D(Start Voice Capture Thread):::processStyle
    E(Start Gesture Capture Thread):::processStyle
    F(Start Authentication Monitor Thread):::processStyle
    G(Voice Input Captured):::processStyle
    H(Gesture Input Captured):::processStyle
    I{User Identified?}:::decisionStyle
    J[Update GUI with User Name and Store liu_id]:::processStyle
    K[Prompt User to Register]:::registrationStyle
    L[Initiate Face Registration]:::registrationStyle
    M[Initiate Voice Registration]:::registrationStyle
    N[Retry Face Identification]:::processStyle
    O[User Authenticated and liu_id Stored]:::processStyle
    P[Send Voice, Gesture & liu_id to Synchronizer]:::processStyle
    Q[Synchronizer Merges Inputs and Generates Unified Command<br>with liu_id]:::processStyle
    R[Unified Command Stored in DB with liu_id]:::processStyle
    S(Display Unified Command for Confirmation):::processStyle
    T{User Confirms Command?}:::decisionStyle
    U[Process Command via CommandProcessor]:::processStyle
    V[Recapture Voice & Gesture Input]:::processStyle
    W[Loop for Next Command or Stop Session]:::processStyle

    A --> B
    B --> C
    C --> D
    C --> E
    C --> F
    D --> G
    E --> H
    F --> I
    I -- Yes --> J
    I -- No --> K
    K --> L
    L --> M
    M --> N
    N --> I
    J --> O
    G --> P
    H --> P
    O --> P
    P --> Q
    Q --> R
    R --> S
    S --> T
    T -- Yes --> U
    T -- No --> V
    U --> W
    V --> D
    W --> W

````