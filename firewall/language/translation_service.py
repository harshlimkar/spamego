# Translation Service: Transforms Indic, Tanglish, and Hinglish into Canonical English
# Preserves sensitive tokens: OTP, KYC, UPI, PIN, CVV, ₹, bank names, URLs, phone numbers

import re

class TranslationService:
    # 1. Native Tamil Dictionary & Phrasal Replacements
    TAMIL_MAP = {
        "உங்கள்": "your",
        "உங்களுடைய": "your",
        "கணக்கு": "account",
        "முடக்கப்படும்": "will be blocked",
        "முடக்கம்": "blocked",
        "காலாவதியாகும்": "will expire",
        "காலாவதியானது": "has expired",
        "சொல்லுங்கள்": "tell / provide",
        "சொல்லு": "tell",
        "அனுப்புங்கள்": "send",
        "கொடுங்கள்": "give",
        "வங்கி": "bank",
        "உடனடியாக": "immediately",
        "உடனே": "immediately",
        "இன்று": "today",
        "பணம்": "money",
        "பரிசு": "prize",
        "வீட்டிற்கு": "to home",
        "வந்துவிட்டாயா": "did you reach",
        "எப்படி இருக்கிறீர்கள்": "how are you",
        "நல்ல": "good",
    }

    # 2. Tanglish (Romanized Tamil) Phrasal & Word Replacements
    TANGLISH_PHRASES = [
        (r'\bunga account block aagum\b', 'your account will be blocked'),
        (r'\bunga account block aagidum\b', 'your account will be blocked'),
        (r'\bunga kyc expire aagiduchu\b', 'your KYC has expired'),
        (r'\bkyc expire aagiduchu\b', 'KYC has expired'),
        (r'\bdebit card expire aagiduchu\b', 'debit card has expired'),
        (r'\botp sollunga\b', 'tell me the OTP'),
        (r'\botp sollu\b', 'tell the OTP'),
        (r'\botp kudunga\b', 'give the OTP'),
        (r'\botp anupunga\b', 'send the OTP'),
        (r'\bveetuku vandhutiya\b', 'did you reach home?'),
        (r'\bveetuku vandhiya\b', 'did you reach home?'),
        (r'\bepdi irukinga\b', 'how are you?'),
        (r'\bnalla irukken\b', 'I am fine.'),
    ]

    TANGLISH_WORDS = {
        "unga": "your",
        "ungal": "your",
        "ungada": "your",
        "enakku": "to me",
        "sollunga": "tell",
        "sollu": "tell",
        "kudunga": "give",
        "kudu": "give",
        "anupunga": "send",
        "aagiduchu": "has happened / expired",
        "aagum": "will happen / be",
        "aagidum": "will happen / be",
        "pannunga": "do",
        "pannu": "do",
        "irundhu": "from",
        "konjam": "a little",
        "udane": "immediately",
        "ippo": "now",
        "theva": "needed",
        "mudivu": "decision",
        "paarthu": "check / look",
        "vandhutiya": "did you come / reach",
        "veetuku": "home",
    }

    # 3. Native Hindi (Devanagari) Phrasal & Word Replacements
    HINDI_MAP = {
        "आपका": "your",
        "खाता": "account",
        "ब्लॉक": "blocked",
        "हो जाएगा": "will be",
        "कर दिया जाएगा": "will be blocked",
        "केवाईसी": "KYC",
        "ओटीपी": "OTP",
        "भेजें": "send",
        "बताओ": "tell",
        "बताइए": "tell",
        "तुरंत": "immediately",
        "जल्दी": "urgently",
        "बैंक": "bank",
        "पैसे": "money",
        "रुपये": "rupees",
        "लॉटरी": "lottery",
        "इनाम": "prize",
        "घर": "home",
        "आ गए": "arrived",
        "कैसा है": "how is",
    }

    # 4. Hinglish (Romanized Hindi) Phrasal & Word Replacements
    HINGLISH_PHRASES = [
        (r'\baapka account block ho jayega\b', 'your account will be blocked'),
        (r'\bapka account block ho jayega\b', 'your account will be blocked'),
        (r'\baapka kyc pending hai\b', 'your KYC is pending'),
        (r'\baccount 2 ghante me block ho jayega\b', 'account will be blocked in 2 hours'),
        (r'\bturant update kare\b', 'update immediately'),
        (r'\botp bhejo\b', 'send the OTP'),
        (r'\botp batao\b', 'tell the OTP'),
        (r'\botp de do\b', 'give the OTP'),
        (r'\bpaise transfer karo\b', 'transfer the money'),
        (r'\bdigital arrest warrant\b', 'digital arrest warrant'),
        (r'\bbeta ghar aa gaya hoon\b', 'Son, I have arrived home.'),
        (r'\bkya haal hai\b', 'How are you?'),
        (r'\bsab theek hai\b', 'Everything is fine.'),
    ]

    HINGLISH_WORDS = {
        "aapka": "your",
        "apka": "your",
        "tumhara": "your",
        "mera": "my",
        "mujhe": "to me",
        "khata": "account",
        "bhejo": "send",
        "batao": "tell",
        "karein": "do",
        "kijiye": "do",
        "karo": "do",
        "hoga": "will be",
        "jayega": "will happen",
        "turant": "immediately",
        "jaldi": "urgently",
        "abhi": "now",
        "paise": "money",
        "rupya": "rupees",
        "milega": "will receive",
        "hai": "is",
        "hain": "are",
        "ghar": "home",
    }

    def translate_to_english(self, text: str, language_info: dict) -> dict:
        if not text:
            return {"english_text": "", "confidence": 1.0, "status": "empty"}

        lang_code = language_info.get("language_code", "en")
        script = language_info.get("script", "Latin")
        is_code_mixed = language_info.get("is_code_mixed", False)

        # If already standard English
        if lang_code == "en" and not is_code_mixed and script == "Latin":
            return {
                "english_text": text,
                "confidence": 1.0,
                "status": "native_english"
            }

        result = text

        # 1. Native Tamil Translation
        if script == "Tamil" or lang_code == "ta":
            for k, v in self.TAMIL_MAP.items():
                result = result.replace(k, v)
            return {
                "english_text": result.strip(),
                "confidence": 0.92,
                "status": "translated_tamil"
            }

        # 2. Native Devanagari / Hindi Translation
        if script == "Devanagari" or lang_code == "hi":
            for k, v in self.HINDI_MAP.items():
                result = result.replace(k, v)
            return {
                "english_text": result.strip(),
                "confidence": 0.92,
                "status": "translated_hindi"
            }

        # 3. Tanglish (Tamil-English mixed in Latin script)
        if lang_code == "ta-en" or language_info.get("dialect") == "Tanglish":
            # Apply phrase regexes first
            for pattern, rep in self.TANGLISH_PHRASES:
                result = re.sub(pattern, rep, result, flags=re.I)
            # Apply word-level replacements
            words = result.split()
            translated_words = []
            for w in words:
                clean_w = re.sub(r'[^\w]', '', w).lower()
                if clean_w in self.TANGLISH_WORDS:
                    rep_word = self.TANGLISH_WORDS[clean_w]
                    translated_words.append(w.lower().replace(clean_w, rep_word))
                else:
                    translated_words.append(w)
            result = " ".join(translated_words)
            return {
                "english_text": result.strip(),
                "confidence": 0.90,
                "status": "translated_tanglish"
            }

        # 4. Hinglish (Hindi-English mixed in Latin script)
        if lang_code == "hi-en" or language_info.get("dialect") == "Hinglish":
            for pattern, rep in self.HINGLISH_PHRASES:
                result = re.sub(pattern, rep, result, flags=re.I)
            words = result.split()
            translated_words = []
            for w in words:
                clean_w = re.sub(r'[^\w]', '', w).lower()
                if clean_w in self.HINGLISH_WORDS:
                    rep_word = self.HINGLISH_WORDS[clean_w]
                    translated_words.append(w.lower().replace(clean_w, rep_word))
                else:
                    translated_words.append(w)
            result = " ".join(translated_words)
            return {
                "english_text": result.strip(),
                "confidence": 0.90,
                "status": "translated_hinglish"
            }

        # Fallback: keep original text
        return {
            "english_text": result,
            "confidence": 0.70,
            "status": "fallback"
        }
