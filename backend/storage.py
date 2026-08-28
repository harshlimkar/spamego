import json
import os
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

DB_FILE = "risk_scores.json"

def save_risk_score(call_sid: str, chunk: str, risk_result: dict):
    """
    Saves the risk score and chunk to a JSON file (acting as a mock DB).
    """
    data = []
    
    # Load existing data
    if os.path.exists(DB_FILE):
        try:
            with open(DB_FILE, 'r') as f:
                data = json.load(f)
        except Exception as e:
            logger.error(f"Failed to read {DB_FILE}: {e}")
            
    # Append new record
    record = {
        "timestamp": datetime.utcnow().isoformat(),
        "call_sid": call_sid,
        "transcript_chunk": chunk,
        "qwen_score": risk_result["qwen_score"],
        "ml_score": risk_result["ml_score"],
        "final_risk": risk_result["final_risk"],
        "intent_label": risk_result["intent_label"]
    }
    data.append(record)
    
    # Write back
    try:
        with open(DB_FILE, 'w') as f:
            json.dump(data, f, indent=4)
    except Exception as e:
        logger.error(f"Failed to write to {DB_FILE}: {e}")
