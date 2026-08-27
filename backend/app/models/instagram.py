"""
Instagram Account Credentials Model for ScamEgo AI Backend
"""

from datetime import datetime
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text
from app.database.base import Base

class InstagramAccount(Base):
    __tablename__ = "instagram_accounts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    username = Column(String, nullable=False)
    encrypted_password = Column(Text, nullable=False)
    session_data = Column(Text, nullable=True)
    is_connected = Column(Boolean, default=False)
    last_scraped = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    monitoring_status = Column(String, default="stopped")  # "running", "stopped", "error"
    session_started_at = Column(DateTime, nullable=True)
    target_profile_url = Column(Text, nullable=True)
