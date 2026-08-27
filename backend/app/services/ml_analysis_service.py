import os
import json
import joblib
import numpy as np

class MLAnalysisService:
    def __init__(self):
        # Resolve paths relative to this file
        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
        model_dir = os.path.join(base_dir, 'models', 'scam_classifier')
        
        self.model_path = os.path.join(model_dir, 'sklearn_model.joblib')
        self.vectorizer_path = os.path.join(model_dir, 'vectorizer.joblib')
        self.mapping_path = os.path.join(model_dir, 'label_mapping.json')
        
        self.model = None
        self.vectorizer = None
        self.label_mapping = {}
        self.id2label = {}
        
        self._load_models()

    def _load_models(self):
        try:
            if not os.path.exists(self.model_path):
                print(f"[ML] Model file not found at {self.model_path}")
                return
                
            self.model = joblib.load(self.model_path)
            self.vectorizer = joblib.load(self.vectorizer_path)
            
            with open(self.mapping_path, 'r') as f:
                mapping_data = json.load(f)
                self.label_mapping = mapping_data.get("label2id", {})
                self.id2label = mapping_data.get("id2label", {})
                
            print("[ML] Scam Classifier Models loaded successfully.")
        except Exception as e:
            print(f"[ML] Error loading models: {e}")

    def analyze_text(self, text: str):
        if not self.model or not self.vectorizer:
            return {
                "text": text,
                "scam_label": "UNKNOWN",
                "risk_score": 0,
                "confidence": 0.0,
                "error": "Models not loaded"
            }
            
        try:
            # Vectorize input
            X = self.vectorizer.transform([text])
            
            # Predict
            prediction_idx = self.model.predict(X)[0]
            
            # Get probabilities if available
            confidence = 0.0
            if hasattr(self.model, "predict_proba"):
                probs = self.model.predict_proba(X)[0]
                confidence = float(np.max(probs))
            
            # Map back to label (SAFE, SPAM, SCAM)
            label = self.id2label.get(str(prediction_idx), "UNKNOWN")
            
            # Calculate Risk Score (0-100)
            # Safe = 0-20, Spam = 40-70, Scam = 80-100
            risk_score = 0
            if label == "SAFE":
                risk_score = int((1.0 - confidence) * 20)
            elif label == "SPAM":
                risk_score = 40 + int(confidence * 30)
            elif label == "SCAM":
                risk_score = 80 + int(confidence * 20)
                
            return {
                "text": text,
                "scam_label": label,
                "risk_score": risk_score,
                "confidence": round(confidence, 4)
            }
        except Exception as e:
            print(f"[ML] Analysis error: {e}")
            return {
                "text": text,
                "scam_label": "ERROR",
                "risk_score": 0,
                "confidence": 0.0,
                "error": str(e)
            }

# Singleton instance
ml_service = MLAnalysisService()
