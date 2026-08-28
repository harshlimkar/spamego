"""
ScameGo Agent - Demo Scenario
Reproduces the complete demonstration scenario from the requirements:
- EVENT 1: Bank impersonation call -> Risk = 55
- EVENT 2: Urgency detected -> Risk = 68
- EVENT 3: OTP request -> Risk = 84
- EVENT 4: Suspicious SMS/link -> Risk = 91
- EVENT 5: ₹50,000 payment request -> Risk = 97
"""
import sys
import os
from datetime import datetime, timedelta

# Add project root to path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)

# Set environment variables
os.environ.setdefault("GROQ_API_KEY", "")
os.environ.setdefault("GROQ_ENABLED", "false")
os.environ.setdefault("AGENT_ENABLED", "true")

from sqlalchemy.orm import Session
from backend.app.database.base import SessionLocal, engine, Base
from llm.models import *
from llm.orchestrator import create_agent
from llm.schemas import AgentEventInput, EventType, EventChannel, RiskLevel


def init_agent_db():
    """Initialize agent database tables."""
    print("Creating agent database tables...")
    Base.metadata.create_all(bind=engine)
    print("Tables created successfully!")


def safe_print(text):
    """Print with unicode handling."""
    try:
        print(text)
    except UnicodeEncodeError:
        print(text.encode('ascii', 'replace').decode('ascii'))


def run_demo_scenario():
    """Run the complete demo scenario from requirements."""
    db = SessionLocal()
    try:
        agent = create_agent(db)
        
        print("\n" + "="*60)
        print("SCAMEGO AGENT - COMPLETE DEMO SCENARIO")
        print("="*60)
        print("\nThis demonstrates the multi-event scam campaign progression:")
        print("Bank Impersonation -> Urgency -> OTP Request -> Suspicious Link -> Payment Request")
        print()
        
        sender = "+919999999999"
        base_time = datetime.utcnow()
        
        # EVENT 1: Bank impersonation call
        print("-" * 60)
        print("EVENT 1: Bank Impersonation Call")
        print("-" * 60)
        event1 = AgentEventInput(
            user_id=1,
            event_type=EventType.CALL_TRANSCRIPT,
            channel=EventChannel.CALL,
            timestamp=base_time,
            sender=sender,
            content="Hello, I'm calling from your bank. We need to verify your account details.",
            source="call_recording"
        )
        result1 = agent.process_event(event1)
        safe_print(f"Classification: {result1.analysis.classification}")
        safe_print(f"Risk Score: {result1.decision.risk_score}")
        safe_print(f"Risk Level: {result1.decision.risk_level}")
        safe_print(f"Stage: {result1.decision.stage}")
        safe_print(f"Campaign ID: {result1.campaign_id}")
        print()
        
        # EVENT 2: Urgency detected (30 seconds later)
        print("-" * 60)
        print("EVENT 2: Urgency Detected (30 seconds later)")
        print("-" * 60)
        event2 = AgentEventInput(
            user_id=1,
            event_type=EventType.CALL_TRANSCRIPT,
            channel=EventChannel.CALL,
            timestamp=base_time + timedelta(seconds=30),
            sender=sender,
            content="Your account will be blocked if you don't verify immediately! This is urgent!",
            source="call_recording"
        )
        result2 = agent.process_event(event2)
        safe_print(f"Classification: {result2.analysis.classification}")
        safe_print(f"Risk Score: {result2.decision.risk_score}")
        safe_print(f"Risk Level: {result2.decision.risk_level}")
        safe_print(f"Stage: {result2.decision.stage}")
        safe_print(f"Campaign ID: {result2.campaign_id} (same campaign)")
        print()
        
        # EVENT 3: OTP request (20 seconds later)
        print("-" * 60)
        print("EVENT 3: OTP Request (20 seconds later)")
        print("-" * 60)
        event3 = AgentEventInput(
            user_id=1,
            event_type=EventType.CALL_TRANSCRIPT,
            channel=EventChannel.CALL,
            timestamp=base_time + timedelta(seconds=50),
            sender=sender,
            content="I've sent an OTP to your phone. Tell me the OTP immediately to verify your identity.",
            source="call_recording"
        )
        result3 = agent.process_event(event3)
        safe_print(f"Classification: {result3.analysis.classification}")
        safe_print(f"Risk Score: {result3.decision.risk_score}")
        safe_print(f"Risk Level: {result3.decision.risk_level}")
        safe_print(f"Stage: {result3.decision.stage}")
        safe_print(f"Intent: {[i.value for i in result3.decision.intent]}")
        safe_print(f"Campaign ID: {result3.campaign_id} (same campaign)")
        print()
        
        # EVENT 4: Suspicious SMS/link (40 seconds later)
        print("-" * 60)
        print("EVENT 4: Suspicious SMS/Link (40 seconds later)")
        print("-" * 60)
        event4 = AgentEventInput(
            user_id=1,
            event_type=EventType.SMS,
            channel=EventChannel.SMS,
            timestamp=base_time + timedelta(seconds=90),
            sender=sender,
            content="Click here to verify your KYC: http://fake-bank-kyc.com/verify",
            source="android_sms"
        )
        result4 = agent.process_event(event4)
        safe_print(f"Classification: {result4.analysis.classification}")
        safe_print(f"Risk Score: {result4.decision.risk_score}")
        safe_print(f"Risk Level: {result4.decision.risk_level}")
        safe_print(f"Stage: {result4.decision.stage}")
        safe_print(f"Intent: {[i.value for i in result4.decision.intent]}")
        safe_print(f"Campaign ID: {result4.campaign_id} (same campaign)")
        print()
        
        # EVENT 5: ₹50,000 payment request
        print("-" * 60)
        print("EVENT 5: Rs.50,000 Payment Request")
        print("-" * 60)
        event5 = AgentEventInput(
            user_id=1,
            event_type=EventType.PAYMENT_REQUEST,
            channel=EventChannel.PAYMENT,
            timestamp=base_time + timedelta(seconds=130),
            sender=sender,
            content="Payment request for account verification",
            metadata={"amount": 50000, "receiver": "scammer@upi", "upi_id": "scammer@upi"},
            source="android_notification"
        )
        result5 = agent.process_event(event5)
        safe_print(f"Classification: {result5.analysis.classification}")
        safe_print(f"Risk Score: {result5.decision.risk_score}")
        safe_print(f"Risk Level: {result5.decision.risk_level}")
        safe_print(f"Stage: {result5.decision.stage}")
        safe_print(f"Intent: {[i.value for i in result5.decision.intent]}")
        safe_print(f"Exposure: {result5.decision.exposure.model_dump()}")
        safe_print(f"Explanation: {result5.decision.explanation}")
        safe_print(f"Campaign ID: {result5.campaign_id} (same campaign)")
        safe_print(f"Actions: {[a.value for a in result5.decision.actions]}")
        safe_print(f"Notify Trusted Contact: {result5.decision.notify_trusted_contact}")
        safe_print(f"Recovery Required: {result5.decision.recovery_required}")
        safe_print(f"Recovery Actions: {result5.decision.recovery_actions}")
        print()
        
        # FINAL SUMMARY
        print("="*60)
        print("FINAL AGENT OUTPUT - CRITICAL SCAM CAMPAIGN DETECTED")
        print("="*60)
        print()
        safe_print(f"Current Stage: {result5.decision.stage}")
        print()
        safe_print("Exposure:")
        safe_print(f"  - Money: Rs.{result5.decision.exposure.money_exposure:,.0f}")
        safe_print(f"  - OTP: {'Yes' if result5.decision.exposure.otp_exposure else 'No'}")
        safe_print(f"  - Banking Credentials: {'Yes' if result5.decision.exposure.credential_exposure else 'No'}")
        print()
        safe_print("Reason:")
        safe_print(f"  {result5.decision.explanation}")
        print()
        safe_print("Action: STOP_AND_VERIFY")
        print()
        safe_print("Trusted Contact: NOTIFY - if consent exists")
        print()
        print("="*60)
        print("DEMO COMPLETE")
        print("="*60)
        
    finally:
        db.close()


if __name__ == "__main__":
    init_agent_db()
    run_demo_scenario()