import os
import sys

# Add backend directory to sys.path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from app.services.ml_analysis_service import ml_service

def test_predictions():
    print("Testing ML Service Predictions...")
    
    test_cases = [
        "Your OTP for bank login is 453123. Do not share it.",
        "Sir, your KYC is expiring today. Call immediately to update or account blocked.",
        "Congratulations! You won a lottery of 50 lakhs. Click link to claim.",
        "Can we meet for lunch tomorrow at 1 PM?",
        "Dear Customer, your electricity bill is due. Pay immediately to avoid disconnection. Link: http://bit.ly/fake"
    ]
    
    for text in test_cases:
        res = ml_service.analyze_text(text)
        print(f"\nText: {text}")
        print(f"Result: {res}")

if __name__ == "__main__":
    test_predictions()
