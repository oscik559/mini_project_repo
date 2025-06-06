# run.py

"""
This script launches a FastAPI web application using Uvicorn and exposes it to the internet via an ngrok tunnel.
Functions:
    start_ngrok(port=8000, timeout=10):
        Starts an ngrok tunnel on the specified port and waits for the public URL to become available.
        Args:
            port (int): The local port to expose via ngrok. Defaults to 8000.
            timeout (int): Time in seconds to wait for ngrok to provide a public URL. Defaults to 10.
        Returns:
            subprocess.Popen: The process running ngrok.
Main Execution:
    - Determines the port to run the server on (default 8000 or from command line argument).
    - Starts an ngrok tunnel for the specified port.
    - Runs the FastAPI app located at 'mini_project.web_interface.main:app' using Uvicorn with reload enabled.
    - On shutdown (including KeyboardInterrupt), terminates the ngrok process.
"""
import uvicorn
import subprocess
import time
import requests
import sys
import os

ngrok_path = os.path.join(os.path.dirname(__file__), "ngrok.exe")


def start_ngrok(port=8000, timeout=10):
    ngrok = subprocess.Popen(
        [ngrok_path, "http", str(port)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.STDOUT,
    )
    # Poll ngrok API for the public URL
    start = time.time()
    public_url = None
    while time.time() - start < timeout:
        try:
            tunnels = requests.get("http://127.0.0.1:4040/api/tunnels").json()
            if tunnels["tunnels"]:
                public_url = tunnels["tunnels"][0]["public_url"]
                print(f"🟢 ngrok tunnel running at: {public_url}")
                break
        except Exception:
            pass
        time.sleep(0.5)
    if not public_url:
        print("🟡 Could not get ngrok URL after waiting.")
    return ngrok



if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    print(f"Local: http://localhost:{port}")
    ngrok_proc = start_ngrok(port)

    try:
        uvicorn.run(
            "mini_project.web_interface.main:app",
            host="0.0.0.0",
            port=port,
            reload=True,
        )
    except KeyboardInterrupt:
        print("\nShutting down...")
    finally:
        ngrok_proc.terminate()
