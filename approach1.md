<!-- APPROACH ! -->
````mermaid
flowchart TD
    %% Define style classes
    classDef startStyle fill:#D5E8D4,stroke:#82B366,stroke-width:2px;
    classDef decisionStyle fill:#FFE6CC,stroke:#D79B00,stroke-width:2px;
    classDef processStyle fill:#DAE8FC,stroke:#6C8EBF,stroke-width:2px;
    classDef registrationStyle fill:#F8CECC,stroke:#B85450,stroke-width:2px;

    A[Start Task Manager GUI]:::startStyle
    B[Initial Face Identification Attempt]:::processStyle
    C{Face Recognized?}:::decisionStyle
    D[Welcome User and Store liu_id]:::processStyle
    E[Manual Registration for Face & Voice]:::registrationStyle
    F[Retry Face Identification]:::processStyle
    G[User Authenticated]:::processStyle
    H[Generate Unique Session ID]:::processStyle
    I[Display Prompt: Please speak your request]:::processStyle
    J[Start Voice Capture Thread]:::processStyle
    K[Start Gesture Capture Thread]:::processStyle
    L[Wait for Capture Completion]:::processStyle
    M[Store Voice & Gesture Instructions in DB<br>with liu_id]:::processStyle
    N[Synchronizer Merges Inputs and Generates Unified Command<br>with liu_id]:::processStyle
    O[Display Unified Command for Confirmation]:::processStyle
    P{User Confirms Command?}:::decisionStyle
    Q[Process Command via CommandProcessor]:::processStyle
    R[Re-Capture Voice & Gesture Input]:::processStyle
    S[Loop for Next Command or End Session]:::processStyle

    A --> B
    B --> C
    C -- Yes --> D
    C -- No --> E
    E --> F
    F --> B
    D --> G
    G --> H
    H --> I
    I --> J
    I --> K
    J --> L
    K --> L
    L --> M
    M --> N
    N --> O
    O --> P
    P -- Yes --> Q
    P -- No --> R
    Q --> S
    R --> J
    S --> G

````