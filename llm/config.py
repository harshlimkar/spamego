import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class AgentConfig:
    # Groq Configuration
    groq_api_key: str = os.getenv("GROQ_API_KEY", "")
    groq_model: str = os.getenv("GROQ_MODEL", "mixtral-8x7b-32768")
    groq_enabled: bool = os.getenv("GROQ_ENABLED", "false").lower() == "true"
    groq_timeout: int = int(os.getenv("GROQ_TIMEOUT", "10"))
    
    # Agent Configuration
    agent_enabled: bool = os.getenv("AGENT_ENABLED", "true").lower() == "true"
    
    # Risk Thresholds
    risk_threshold_medium: int = int(os.getenv("RISK_THRESHOLD_MEDIUM", "31"))
    risk_threshold_high: int = int(os.getenv("RISK_THRESHOLD_HIGH", "61"))
    risk_threshold_critical: int = int(os.getenv("RISK_THRESHOLD_CRITICAL", "91"))
    
    # Campaign Context Window (hours)
    campaign_window_hours: int = int(os.getenv("CAMPAIGN_WINDOW_HOURS", "24"))
    
    # Trusted Contact
    trusted_contact_alert_enabled: bool = os.getenv("TRUSTED_CONTACT_ALERT_ENABLED", "true").lower() == "true"
    
    # Privacy
    mask_pii_in_llm: bool = os.getenv("MASK_PII_IN_LLM", "true").lower() == "true"
    
    # Database
    database_path: str = os.getenv("SCAMEGO_DB_PATH", "scamego_local.db")


config = AgentConfig()