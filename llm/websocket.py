from fastapi import WebSocket, WebSocketDisconnect, Depends
from sqlalchemy.orm import Session
from typing import Dict, List, Set
import json
import asyncio
import logging
import sys
import os

# Add project root to path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)

from backend.app.database.base import get_db, SessionLocal
from llm.database import AgentDatabaseService
from llm.schemas import AgentAlert, RiskLevel

logger = logging.getLogger(__name__)


class ConnectionManager:
    def __init__(self):
        # user_id -> set of WebSocket connections
        self.active_connections: Dict[int, Set[WebSocket]] = {}
        # WebSocket -> user_id (for cleanup)
        self.connection_user: Dict[WebSocket, int] = {}

    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)
        self.connection_user[websocket] = user_id
        logger.info(f"WebSocket connected for user {user_id}")

    def disconnect(self, websocket: WebSocket):
        user_id = self.connection_user.get(websocket)
        if user_id and user_id in self.active_connections:
            self.active_connections[user_id].discard(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
        if websocket in self.connection_user:
            del self.connection_user[websocket]
        logger.info(f"WebSocket disconnected for user {user_id}")

    async def send_personal_message(self, message: dict, user_id: int):
        if user_id in self.active_connections:
            disconnected = set()
            for connection in self.active_connections[user_id]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    logger.error(f"Error sending message to user {user_id}: {e}")
                    disconnected.add(connection)
            
            # Clean up disconnected
            for conn in disconnected:
                self.disconnect(conn)

    async def broadcast(self, message: dict):
        for user_id, connections in self.active_connections.items():
            await self.send_personal_message(message, user_id)


manager = ConnectionManager()


async def notify_user(user_id: int, event_type: str, data: dict):
    """Send notification to user via WebSocket."""
    message = {
        "type": event_type,
        "data": data,
        "timestamp": asyncio.get_event_loop().time()
    }
    await manager.send_personal_message(message, user_id)


async def notify_new_alert(user_id: int, alert: AgentAlert):
    """Notify user of new alert."""
    await notify_user(user_id, "new_alert", {
        "alert_id": alert.alert_id,
        "severity": alert.severity.value,
        "alert_type": alert.alert_type.value,
        "title": alert.title,
        "reason": alert.plain_language_reason,
        "action": alert.recommended_action,
        "event_id": alert.event_id,
        "campaign_id": alert.campaign_id
    })


async def notify_risk_updated(user_id: int, risk_score: int, risk_level: RiskLevel, campaign_id: str = None):
    """Notify user of risk level change."""
    await notify_user(user_id, "risk_updated", {
        "risk_score": risk_score,
        "risk_level": risk_level.value,
        "campaign_id": campaign_id
    })


async def notify_campaign_updated(user_id: int, campaign_id: str, stage: str, risk_score: int, status: str):
    """Notify user of campaign update."""
    await notify_user(user_id, "campaign_updated", {
        "campaign_id": campaign_id,
        "stage": stage,
        "risk_score": risk_score,
        "status": status
    })


async def notify_call_risk(user_id: int, caller: str, risk_score: int, risk_level: RiskLevel, stage: str):
    """Notify user of call risk."""
    await notify_user(user_id, "call_risk_updated", {
        "caller": caller,
        "risk_score": risk_score,
        "risk_level": risk_level.value,
        "stage": stage
    })


async def notify_sms_analyzed(user_id: int, sender: str, risk_score: int, risk_level: RiskLevel, classification: str):
    """Notify user of SMS analysis."""
    await notify_user(user_id, "sms_analyzed", {
        "sender": sender,
        "risk_score": risk_score,
        "risk_level": risk_level.value,
        "classification": classification
    })


async def notify_payment_warning(user_id: int, amount: float, currency: str, receiver: str, risk_level: RiskLevel):
    """Notify user of payment warning."""
    await notify_user(user_id, "payment_warning", {
        "amount": amount,
        "currency": currency,
        "receiver": receiver,
        "risk_level": risk_level.value
    })


async def notify_family_alert(user_id: int, alert: AgentAlert):
    """Notify user that family was alerted."""
    await notify_user(user_id, "family_alert_triggered", {
        "alert_id": alert.alert_id,
        "severity": alert.severity.value,
        "reason": alert.plain_language_reason
    })


async def notify_recovery_required(user_id: int, campaign_id: str, actions: List[str], priority: str):
    """Notify user of required recovery actions."""
    await notify_user(user_id, "recovery_required", {
        "campaign_id": campaign_id,
        "actions": actions,
        "priority": priority
    })


# WebSocket endpoint
async def websocket_endpoint(websocket: WebSocket, user_id: int, db: Session = Depends(get_db)):
    await manager.connect(websocket, user_id)
    db_service = AgentDatabaseService(db)
    
    try:
        # Send initial state
        alerts = db_service.get_user_alerts(user_id, limit=10, unread_only=True)
        await websocket.send_json({
            "type": "initial_state",
            "data": {
                "unread_alerts": len(alerts),
                "alerts": [
                    {
                        "alert_id": a.alert_id,
                        "severity": a.severity,
                        "title": a.title,
                        "created_at": a.created_at.isoformat() if a.created_at else None
                    }
                    for a in alerts
                ]
            }
        })
        
        # Keep connection alive and handle incoming messages
        while True:
            try:
                data = await websocket.receive_json()
                # Handle client messages (ping, ack, etc.)
                if data.get("type") == "ping":
                    await websocket.send_json({"type": "pong"})
                elif data.get("type") == "ack":
                    # Client acknowledged notification
                    pass
            except WebSocketDisconnect:
                break
            except Exception as e:
                logger.error(f"WebSocket error for user {user_id}: {e}")
                break
                
    except WebSocketDisconnect:
        pass
    finally:
        manager.disconnect(websocket)


def get_websocket_manager() -> ConnectionManager:
    return manager