import requests
import json
import time
import subprocess
import os
import sys

def test_ml_endpoint():
    print("Testing ML Endpoint on Server...")
    
    # 1. Start Server
    env = os.environ.copy()
    env["PYTHONPATH"] = os.path.dirname(os.path.abspath(__file__))
    
    server = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "server.main:app", "--port", "8000"],
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL
    )
    
    time.sleep(3) # Wait for startup
    
    try:
        url = "http://localhost:8000/api/ml/analyze"
        
        test_payloads = [
            {"text": "Hey can we talk later?", "content_type": "sms", "content_id": 1, "user_id": 1},
            {"text": "Urgent! Bank OTP is 1234. Do not share.", "content_type": "sms", "content_id": 2, "user_id": 1},
            {"text": "KYC expired. Click here to verify or account blocked.", "content_type": "sms", "content_id": 3, "user_id": 1}
        ]
        
        for payload in test_payloads:
            print(f"\nSending: {payload['text']}")
            response = requests.post(url, json=payload)
            print(f"Response ({response.status_code}): {json.dumps(response.json(), indent=2)}")
            
    finally:
        server.terminate()
        print("\nTest completed.")

if __name__ == "__main__":
    test_ml_endpoint()
