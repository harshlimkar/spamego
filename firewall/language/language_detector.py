# Language Detector supporting Native Indic, English, and Romanized Code-Mixed dialects

import re
from .script_detector import ScriptDetector

class LanguageDetector:
    def __init__(self):
        self.script_detector = ScriptDetector()
        
        # Romanized lexical markers for Indic dialects
        self.MARKERS = {
            "Tamil": [
                "unga", "ungal", "sollunga", "sollu", "aagiduchu", "aagum", "pannunga", "pannu",
                "irundhu", "vaanga", "podunga", "konjam", "enakku", "mudivu", "kudunga", "vandhutiya",
                "veetuku", "kidaikkum", "parunga", "illa", "irukku", "theriyum", "ippo", "aachu"
            ],
            "Hindi": [
                "apka", "aapka", "karein", "kijiye", "sakta", "raha", "rahi", "hoga", "hoja", "jayega",
                "karo", "karne", "ke liye", "abhi", "tumhara", "mujhe", "bhejo", "batao", "turant",
                "ghar", "aaya", "aaye", "paise", "milega", "chahiye", "hai", "hain", "karna", "de do"
            ],
            "Telugu": [
                "meeru", "meeku", "cheyandi", "cheppandi", "pampandi", "undi", "leka", "vasthundi",
                "ippudu", "avuthundi", "chudandi", "ivvandi"
            ],
            "Kannada": [
                "nimma", "nimge", "madi", "heli", "kodi", "agide", "ide", "barutte", "beku", "illi"
            ],
            "Malayalam": [
                "ningalude", "parayuka", "cheyyuka", "varunnu", "und", "illa", "nalkuka", "aano"
            ]
        }

    def detect(self, text: str) -> dict:
        if not text:
            return {
                "language_code": "en",
                "language_name": "English",
                "confidence": 1.0,
                "is_code_mixed": False,
                "script": "Latin",
                "details": "Empty text"
            }

        script_info = self.script_detector.detect_scripts(text)
        primary_script = script_info["primary_script"]
        is_mixed_script = script_info["is_mixed_script"]
        
        # 1. Native Indic Scripts
        if primary_script == "Tamil":
            return {
                "language_code": "ta",
                "language_name": "Tamil",
                "confidence": 0.98,
                "is_code_mixed": is_mixed_script,
                "script": "Tamil",
                "details": "Native Tamil script"
            }
        elif primary_script == "Devanagari":
            return {
                "language_code": "hi",
                "language_name": "Hindi",
                "confidence": 0.98,
                "is_code_mixed": is_mixed_script,
                "script": "Devanagari",
                "details": "Native Devanagari script"
            }
        elif primary_script == "Telugu":
            return {
                "language_code": "te",
                "language_name": "Telugu",
                "confidence": 0.98,
                "is_code_mixed": is_mixed_script,
                "script": "Telugu",
                "details": "Native Telugu script"
            }
        elif primary_script == "Malayalam":
            return {
                "language_code": "ml",
                "language_name": "Malayalam",
                "confidence": 0.98,
                "is_code_mixed": is_mixed_script,
                "script": "Malayalam",
                "details": "Native Malayalam script"
            }
        elif primary_script == "Kannada":
            return {
                "language_code": "kn",
                "language_name": "Kannada",
                "confidence": 0.98,
                "is_code_mixed": is_mixed_script,
                "script": "Kannada",
                "details": "Native Kannada script"
            }

        # 2. Latin Script Romanized Dialects (Tanglish, Hinglish, English)
        lowered = text.lower()
        words = re.findall(r'\b[a-zA-Z]+\b', lowered)
        
        ta_matches = sum(1 for w in words if w in self.MARKERS["Tamil"])
        hi_matches = sum(1 for w in words if w in self.MARKERS["Hindi"])
        te_matches = sum(1 for w in words if w in self.MARKERS["Telugu"])
        kn_matches = sum(1 for w in words if w in self.MARKERS["Kannada"])
        
        if ta_matches >= 1 and (ta_matches >= hi_matches):
            return {
                "language_code": "ta-en",
                "language_name": "Tamil-English mixed (Tanglish)",
                "confidence": min(0.95, 0.6 + (ta_matches * 0.15)),
                "is_code_mixed": True,
                "script": "Latin",
                "dialect": "Tanglish",
                "details": f"Detected {ta_matches} Tamil phonetic markers in Latin script"
            }
        elif hi_matches >= 1:
            return {
                "language_code": "hi-en",
                "language_name": "Hindi-English mixed (Hinglish)",
                "confidence": min(0.95, 0.6 + (hi_matches * 0.15)),
                "is_code_mixed": True,
                "script": "Latin",
                "dialect": "Hinglish",
                "details": f"Detected {hi_matches} Hindi phonetic markers in Latin script"
            }
        elif te_matches >= 1:
            return {
                "language_code": "te-en",
                "language_name": "Telugu-English mixed",
                "confidence": 0.85,
                "is_code_mixed": True,
                "script": "Latin",
                "dialect": "Telugu-English",
                "details": f"Detected {te_matches} Telugu phonetic markers in Latin script"
            }
        elif kn_matches >= 1:
            return {
                "language_code": "kn-en",
                "language_name": "Kannada-English mixed",
                "confidence": 0.85,
                "is_code_mixed": True,
                "script": "Latin",
                "dialect": "Kannada-English",
                "details": f"Detected {kn_matches} Kannada phonetic markers in Latin script"
            }

        # Default to English if Latin characters dominant
        return {
            "language_code": "en",
            "language_name": "English",
            "confidence": 0.90,
            "is_code_mixed": False,
            "script": "Latin",
            "details": "Standard English in Latin script"
        }
