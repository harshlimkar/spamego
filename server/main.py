from fastapi import FastAPI
from server.api.sms_gateway import router as sms_router
from server.api.sync import router as sync_router
from server.database.db_setup import init_db, seed_db
from backend.app.api.ml_router import router as ml_router
import os

app = FastAPI(title="ScameGo Intelligence Server")

# Initialize DB on startup
@app.on_event("startup")
async def startup_event():
    init_db()
    seed_db()
    print("ScameGo Server started and DB initialized.")

app.include_router(sms_router, prefix="/api")
app.include_router(sync_router, prefix="/api")
app.include_router(ml_router, prefix="/api/ml")

if __name__ == "__main__":
    import uvicorn
    # Make sure to run this file if starting the server manually
    uvicorn.run(app, host="127.0.0.1", port=8000)
