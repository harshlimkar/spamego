def predict_risk(transcript: str) -> float:
    """
    Placeholder for a fine-tuned classifier (e.g. DistilBERT/IndicBERT).
    Since datasets are not provided yet, this returns a rule-based mock score.
    """
    transcript_lower = transcript.lower()
    suspicious_keywords = ["otp", "password", "bank", "police", "arrest", "urgent", "credit card", "pin"]
    
    match_count = sum(1 for kw in suspicious_keywords if kw in transcript_lower)
    
    if match_count >= 2:
        return 0.9 # High risk (multiple triggers)
    elif match_count == 1:
        return 0.5 # Suspicious
    return 0.0 # Safe
