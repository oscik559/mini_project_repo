# Mini Project: Vision-Language-Robotics Integration

## Overview

This project combines computer vision, natural language processing, and robotic control to create an intelligent system capable of understanding and executing tasks in virtual environments. The system leverages modern AI technologies to provide personalized task execution capabilities.

## Features

- Computer vision integration for environment perception
- Language model integration for natural language understanding
- Robotic control system for task execution
- Web interface for user interaction
- Authentication system for secure access
- Database integration for data persistence

## Prerequisites

- Python 3.8 or higher
- Virtual environment (recommended)
- ngrok (included in the repository)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/oscik559/mini_project_repo
cd mini_project
```

2. Create and activate a virtual environment:
```bash
python -m venv .venv
# On Windows
.venv\Scripts\activate
# On Unix or MacOS
source .venv/bin/activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Usage

1. Start the application:
```bash
python run.py
```

2. Access the web interface:
   - Local: http://localhost:8000
   - Public URL: Will be displayed in the console (via ngrok)

## Project Structure

```
mini_project/
├── assets/         # Static assets and resources
├── camera/         # Camera and vision-related modules
├── modalities/     # Different input/output modalities
├── authentication/ # User authentication system
├── config/         # Configuration files
├── web_interface/  # FastAPI web interface
├── tests/          # Test suite
└── database/       # Database models and utilities
```

## Development

- Run tests: `pytest`
- Code formatting: Follow PEP 8 guidelines
- Documentation: Available in the `docs/` directory

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Contact

Oscar Ikechukwu - oscik559@student.liu.se

Project Link: https://github.com/oscik559/mini_project_repo
