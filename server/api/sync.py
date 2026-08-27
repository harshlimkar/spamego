from fastapi import APIRouter
from server.database.db_setup import get_db_connection

router = APIRouter()

@router.get("/sync_threat_intelligence")
async def sync_threat_intelligence():
    # Phase 13: Add threat-intelligence synchronization
    # In a real app, this would return only diffs based on client version.
    conn = get_db_connection()
    
    reported = conn.execute("SELECT * FROM reported_numbers").fetchall()
    officials = conn.execute("SELECT * FROM official_numbers").fetchall()
    
    conn.close()
    
    return {
        "server_version": "13.0",
        "reported_numbers": [dict(r) for r in reported],
        "official_numbers": [dict(o) for o in officials]
    }
