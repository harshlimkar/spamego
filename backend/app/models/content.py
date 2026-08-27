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

class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    participant = Column(String, nullable=False)
    thread_id = Column(String, nullable=True)
    message_count = Column(Integer, default=0)
    flagged_count = Column(Integer, default=0)
    risk_score = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    instagram_post_id = Column(String, nullable=False, unique=True)
    account_id = Column(Integer, ForeignKey("instagram_accounts.id"), nullable=False)
    post_url = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
