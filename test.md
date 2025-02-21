
````mermaid
graph TD
    %% Define style classes
    classDef startStyle fill:#D5E8D4,stroke:#82B366,stroke-width:2px;
    classDef decisionStyle fill:#FFE6CC,stroke:#D79B00,stroke-width:2px;
    classDef processStyle fill:#DAE8FC,stroke:#6C8EBF,stroke-width:2px;
    classDef registrationStyle fill:#F8CECC,stroke:#B85450,stroke-width:2px;

    A[Start Application] --> B[Initialize GUI]
    B --> C[Set State Variables]
    C --> D[Instantiate Core Modules]
    D --> E[Build GUI Elements]
    E --> F[Log Event: Application started]
    F --> G[Run Main Loop]

    G -->|Start Execution| H[Check Authentication]
    H -->|Not Authenticated| I[Authenticate User]
    I -->|Authenticated| J[Generate Session ID]
    J --> K[Set Controls State]
    K --> L[Start Execution Pipeline Thread]
    L --> M[Log Event: Execution started]

    G -->|Stop Execution| N[Set Running to False]
    N --> O[Set Controls State]
    O --> P[Log Event: Execution stopped]

    G -->|New Command| Q[Generate New Session ID]
    Q --> R[Log Event: New command session started]
    R --> S[Start Execution]

    G -->|Clear Tables| T[Clear Database Tables]
    T --> U[Log Event: Database instructions cleared]

    G -->|Exit Application| V[Stop Execution]
    V --> W[Close Command Processor]
    W --> X[Destroy GUI]

    L --> Y[Execution Pipeline]
    Y --> Z[Start Voice and Gesture Capture Threads]
    Z --> AA[Log Event: Capture started]
    AA --> BB[Wait for Capture Threads to Complete]
    BB --> CC[Log Event: Capture complete]
    CC --> DD[Merge Inputs]
    DD --> EE[Log Event: Merging inputs]
    EE --> FF[Get Unified Command]
    FF -->|Unified Command Available| GG[Log Event: Unified Command]
    GG --> HH[Ask for User Confirmation]
    HH -->|Confirmed| II[Process Command]
    II -->|Success| JJ[Log Event: Command processed]
    JJ --> KK[End Session]
    HH -->|Rejected| LL[Log Event: Command rejected]
    LL --> MM[Retry Capture]
    FF -->|No Unified Command| NN[Log Event: No unified command]
    NN --> MM
    MM --> OO[Retry Capture Loop]
    OO --> Y
    Y --> PP[Set Controls State]
    PP --> QQ[Log Event: Session ended]
````