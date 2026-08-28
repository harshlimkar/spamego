import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

_ml_service = None


def _load_via_file():
    import importlib.util
    path = os.path.join(_ROOT, "backend", "app", "services", "ml_analysis_service.py")
    spec = importlib.util.spec_from_file_location("ml_analysis_service", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.ml_service


def get_ml_service():
    global _ml_service
    if _ml_service is None:
        try:
            _ml_service = _load_via_file()
        except Exception as exc:
            _ml_service = _Unavailable(str(exc))
    return _ml_service


class _Unavailable:
    def __init__(self, reason):
        self.reason = reason
        self.model = None
        self.vectorizer = None

    def analyze_text(self, text):
        return {
            "text": text,
            "scam_label": "UNKNOWN",
            "risk_score": 30,
            "confidence": 0.0,
            "error": self.reason,
        }


def ml_analyze(text):
    result = get_ml_service().analyze_text(text or "")
    return {
        "text": result.get("text", text),
        "scam_label": result.get("scam_label", "UNKNOWN"),
        "risk_score": int(result.get("risk_score", 30)),
        "confidence": float(result.get("confidence", 0.0)),
        "error": result.get("error"),
    }