"""
Content Models (Monitored Instagram Comments & Messages) for ScamEgo AI Backend
"""

from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey
from app.database.base import Base

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    post_id = Column(String, nullable=True)
    comment_id = Column(String, nullable=True)
    text = Column(Text, nullable=False)
    author = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    thread_id = Column(String, nullable=True)
    message_id = Column(String, nullable=True)
    text = Column(Text, nullable=False)
    sender = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
