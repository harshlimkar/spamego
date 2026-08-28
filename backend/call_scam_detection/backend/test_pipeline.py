import asyncio
from reporting_layer.api import report_number, check_number
from event_engine.engine import EventEngine
from ml_model.model import predict_risk
from ollama_qwen.qwen_wrapper import analyze_transcript
from risk_fusion.fusion import calculate_final_risk

async def run_test_cases():
    print("=== LIVE SCAM DETECTION PIPELINE TESTS ===")
    
    event_engine = EventEngine()
    
    # --- CASE 1: Safe call, unknown number ---
    print("\n--- CASE 1: Safe call, unknown number ---")
    number = "+1234567890"
    transcript = "Hello, yes I am calling to confirm our dinner plans for tonight at 8."
    
    # 1. Check reporting layer
    rep_res = check_number(number)
    print(f"Report Layer: {rep_res}")
    
    # 2. Log in event engine
    event_engine.log_call(number)
    timeline_risk = event_engine.calculate_timeline_risk(number)
    print(f"Timeline Risk: {timeline_risk}")
    
    # 3. ML Model
    ml_score = predict_risk(transcript)
    print(f"ML Score: {ml_score}")
    
    # 4. Qwen
    qwen_score = await analyze_transcript(transcript)
    print(f"Qwen Score: {qwen_score}")
    
    # 5. Fusion
    final_risk = calculate_final_risk(rep_res["base_risk_score"], ml_score, qwen_score, timeline_risk)
    print(f"Final Output: {final_risk}")


    # --- CASE 2: Suspicious keywords, safe history ---
    print("\n--- CASE 2: Suspicious keywords, safe history ---")
    transcript = "This is your bank calling. We noticed some suspicious activity. Please tell me your OTP to verify."
    
    ml_score = predict_risk(transcript)
    qwen_score = await analyze_transcript(transcript)
    final_risk = calculate_final_risk(rep_res["base_risk_score"], ml_score, qwen_score, timeline_risk)
    print(f"ML Score: {ml_score} | Qwen Score: {qwen_score}")
    print(f"Final Output: {final_risk}")


    # --- CASE 3: Repeated calls (Event Engine Escalation) ---
    print("\n--- CASE 3: Repeated calls (Event Engine Escalation) ---")
    # Simulate 2 more quick calls
    event_engine.log_call(number)
    event_engine.log_call(number)
    timeline_risk = event_engine.calculate_timeline_risk(number)
    print(f"Timeline Risk after 3 calls: {timeline_risk}")
    
    final_risk = calculate_final_risk(rep_res["base_risk_score"], ml_score, qwen_score, timeline_risk)
    print(f"Final Output: {final_risk}")


    # --- CASE 4: Highly reported spam number ---
    print("\n--- CASE 4: Highly reported spam number ---")
    spam_num = "+9999999999"
    report_number(spam_num)
    report_number(spam_num)
    report_number(spam_num)
    
    rep_res = check_number(spam_num)
    print(f"Report Layer for {spam_num}: {rep_res}")
    
    final_risk = calculate_final_risk(rep_res["base_risk_score"], 0.0, 0.0, 0.0)
    print(f"Final Output (even with safe transcript): {final_risk}")

if __name__ == "__main__":
    asyncio.run(run_test_cases())
