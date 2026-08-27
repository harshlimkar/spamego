from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.ml_router import router as ml_router
from app.api.instagram_router import router as instagram_router
from app.database.base import Base, engine

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="ScameGo AI Backend",
    description="Instagram DM Spam/Scam Detection API",
    version="1.0.0"
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

@app.get("/")
async def root():
    return {"message": "ScameGo AI Backend - Instagram Spam/Scam Detection"}

@app.get("/health")
async def health():
    return {"status": "healthy"}