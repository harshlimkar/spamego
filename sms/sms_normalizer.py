import re

class SMSNormalizer:
    @staticmethod
    def normalize(text):
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text).strip()
        
        # Detect basic mixed language by checking for Tamil Unicode block (0B80–0BFF)
        has_tamil_script = bool(re.search(r'[\u0B80-\u0BFF]', text))
        
        # Detect English characters
        has_english = bool(re.search(r'[A-Za-z]', text))
        
        # Detect Tanglish words
        tanglish_words = ["unga", "sollunga", "aagum", "pannunga", "irundhu", "la"]
        has_tanglish = any(word in text.lower() for word in tanglish_words)
        
        language = "Unknown"
        if (has_tamil_script and has_english) or has_tanglish:
            language = "Mixed (Tamil+English)"
        elif has_tamil_script:
            language = "Tamil"
        elif has_english:
            language = "English"

        return {
            "original": text,
            "normalized": text.lower(),
            "detected_language": language
        }
