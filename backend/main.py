from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.ml_router import router as ml_router
from app.api.instagram_router import router as instagram_router
from app.database.base import Base, engine
import os
import sys

# Add project root to path for llm module
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, project_root)

from llm.models import *
from llm.api import router as agent_router
from llm.websocket import websocket_endpoint

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="ScameGo AI Backend",
    description="Instagram DM Spam/Scam Detection API with ScameGo Agent",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ml_router, prefix="/api")
app.include_router(instagram_router, prefix="/api")
app.include_router(agent_router, prefix="/api")

# WebSocket endpoint
@app.websocket("/ws/agent/{user_id}")
async def websocket_agent(websocket, user_id: int):
    from app.database.base import SessionLocal
    db = SessionLocal()
    try:
        await websocket_endpoint(websocket, user_id, db)
    finally:
        db.close()

@app.get("/")
async def root():
    return {"message": "ScameGo AI Backend - Instagram Spam/Scam Detection"}

@app.get("/health")
async def health():
    return {"status": "healthy"}