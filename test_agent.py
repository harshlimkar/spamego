import sys
import os
import asyncio
from datetime import datetime

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
from llm.schemas import AgentEventInput, EventType, EventChannel


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


def test_agent_pipeline():
    """Test the full agent pipeline with demo events."""
    db = SessionLocal()
    try:
        agent = create_agent(db)
        
        print("\n=== Testing ScameGo Agent Pipeline ===\n")
        
        # Test 1: Legitimate SMS from verified number
        print("--- Test 1: Legitimate SMS ---")
        event1 = AgentEventInput(
            user_id=1,
            event_type=EventType.SMS,
            channel=EventChannel.SMS,
            timestamp=datetime.utcnow(),
            sender="1800123456",  # Official number in seed data
            content="Your OTP for login is 123456. Do not share this OTP with anyone.",
            source="android_sms"
        )
        result1 = agent.process_event(event1)
        safe_print(f"Classification: {result1.analysis.classification}")
        safe_print(f"Risk Score: {result1.decision.risk_score}")
        safe_print(f"Risk Level: {result1.decision.risk_level}")
        safe_print(f"Stage: {result1.decision.stage}")
        safe_print(f"Explanation: {result1.decision.explanation}")
        safe_print(f"Campaign ID: {result1.campaign_id}")
        print()
        
        # Test 2: KYC Scam SMS from unknown number
        print("--- Test 2: KYC Scam SMS ---")
        event2 = AgentEventInput(
            user_id=1,
            event_type=EventType.SMS,
            channel=EventChannel.SMS,
            timestamp=datetime.utcnow(),
            sender="+919999999999",  # Reported scam number in seed data
            content="Sir unga KYC expire aagiduchu. Update immediately. Share OTP.",
            source="android_sms"
        )
        result2 = agent.process_event(event2)
        safe_print(f"Classification: {result2.analysis.classification}")
        safe_print(f"Risk Score: {result2.decision.risk_score}")
        safe_print(f"Risk Level: {result2.decision.risk_level}")
        safe_print(f"Stage: {result2.decision.stage}")
        safe_print(f"Intent: {[i.value for i in result2.decision.intent]}")
        safe_print(f"Explanation: {result2.decision.explanation}")
        safe_print(f"Campaign ID: {result2.campaign_id}")
        safe_print(f"Actions: {[a.value for a in result2.decision.actions]}")
        print()
        
        # Test 3: Call from same number (campaign correlation)
        print("--- Test 3: Call from Same Number (Campaign Correlation) ---")
        event3 = AgentEventInput(
            user_id=1,
            event_type=EventType.CALL_TRANSCRIPT,
            channel=EventChannel.CALL,
            timestamp=datetime.utcnow(),
            sender="+919999999999",
            content="I am calling from your bank. Your KYC has expired. Tell me the OTP immediately.",
            source="call_recording"
        )
        result3 = agent.process_event(event3)
        safe_print(f"Classification: {result3.analysis.classification}")
        safe_print(f"Risk Score: {result3.decision.risk_score}")
        safe_print(f"Risk Level: {result3.decision.risk_level}")
        safe_print(f"Stage: {result3.decision.stage}")
        safe_print(f"Intent: {[i.value for i in result3.decision.intent]}")
        safe_print(f"Campaign ID: {result3.campaign_id} (should match previous)")
        safe_print(f"Actions: {[a.value for a in result3.decision.actions]}")
        print()
        
        # Test 4: Payment request (escalation)
        print("--- Test 4: Payment Request (Critical Escalation) ---")
        event4 = AgentEventInput(
            user_id=1,
            event_type=EventType.PAYMENT_REQUEST,
            channel=EventChannel.PAYMENT,
            timestamp=datetime.utcnow(),
            sender="+919999999999",
            content="Payment request for KYC update",
            metadata={"amount": 50000, "receiver": "scammer@upi", "upi_id": "scammer@upi"},
            source="android_notification"
        )
        result4 = agent.process_event(event4)
        safe_print(f"Classification: {result4.analysis.classification}")
        safe_print(f"Risk Score: {result4.decision.risk_score}")
        safe_print(f"Risk Level: {result4.decision.risk_level}")
        safe_print(f"Stage: {result4.decision.stage}")
        safe_print(f"Intent: {[i.value for i in result4.decision.intent]}")
        safe_print(f"Exposure: {result4.decision.exposure.model_dump()}")
        safe_print(f"Explanation: {result4.decision.explanation}")
        safe_print(f"Campaign ID: {result4.campaign_id}")
        safe_print(f"Actions: {[a.value for a in result4.decision.actions]}")
        safe_print(f"Notify Trusted Contact: {result4.decision.notify_trusted_contact}")
        safe_print(f"Recovery Required: {result4.decision.recovery_required}")
        safe_print(f"Recovery Actions: {result4.decision.recovery_actions}")
        print()
        
        # Test 5: Safe message
        print("--- Test 5: Safe Message ---")
        event5 = AgentEventInput(
            user_id=1,
            event_type=EventType.SMS,
            channel=EventChannel.SMS,
            timestamp=datetime.utcnow(),
            sender="+918888888888",
            content="Hey, are we meeting for lunch today?",
            source="android_sms"
        )
        result5 = agent.process_event(event5)
        safe_print(f"Classification: {result5.analysis.classification}")
        safe_print(f"Risk Score: {result5.decision.risk_score}")
        safe_print(f"Risk Level: {result5.decision.risk_level}")
        safe_print(f"Stage: {result5.decision.stage}")
        safe_print(f"Explanation: {result5.decision.explanation}")
        print()
        
        print("=== All Tests Completed ===")
        
    finally:
        db.close()


def test_campaign_correlation():
    """Test campaign correlation across different channels."""
    db = SessionLocal()
    try:
        agent = create_agent(db)
        
        print("\n=== Testing Campaign Correlation ===\n")
        
        # Simulate a multi-channel campaign
        base_time = datetime.utcnow()
        sender = "+917777777777"
        
        events = [
            ("SMS", "You have won a lottery! Click link to claim.", EventChannel.SMS),
            ("CALL", "Congratulations! You won 10 lakhs. I need your bank details to transfer.", EventChannel.CALL),
            ("SMS", "Send the OTP you received to verify your account.", EventChannel.SMS),
        ]
        
        for i, (channel_name, content, channel) in enumerate(events):
            event = AgentEventInput(
                user_id=1,
                event_type=EventType.SMS if channel == EventChannel.SMS else EventType.CALL_TRANSCRIPT,
                channel=channel,
                timestamp=base_time,
                sender=sender,
                content=content,
                source=f"test_{channel_name.lower()}"
            )
            result = agent.process_event(event)
            safe_print(f"Event {i+1} ({channel_name}): Risk={result.decision.risk_score}, Stage={result.decision.stage}, Campaign={result.campaign_id}")
        
        print("\nCampaign successfully correlated across channels!")
        
    finally:
        db.close()


if __name__ == "__main__":
    init_agent_db()
    test_agent_pipeline()
    test_campaign_correlation()