def calculate_final_risk(report_score: float, ml_score: float, qwen_score: float, timeline_risk: float) -> dict:
    """
    Combines the scores from all modules.
    final_risk = w1*report_layer_score + w2*ml_score + w3*qwen_score + w4*timeline_risk
    """
    # Start with equal weights (or adjust as needed)
    w1, w2, w3, w4 = 0.25, 0.25, 0.25, 0.25
    
    final_risk = (
        (w1 * report_score) + 
        (w2 * ml_score) + 
        (w3 * qwen_score) + 
        (w4 * timeline_risk)
    )
    
    # Map score to label
    if final_risk >= 0.75:
        intent_label = "CRITICAL"
    elif final_risk >= 0.4:
        intent_label = "SUSPICIOUS"
    else:
        intent_label = "SAFE"
        
    return {
        "report_score": report_score,
        "ml_score": ml_score,
        "qwen_score": qwen_score,
        "timeline_risk": timeline_risk,
        "final_risk": final_risk,
        "intent_label": intent_label
    }
