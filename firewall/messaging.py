import re

REGIONAL_SIGNS = {
    "otp": {"otp", "ஒடிபி", "aotsb"},
    "block": {"block", "பிளாக்", "முடக்க", "ब्लॉक", "फ्रीज", "frozen"},
    "account": {"account", "கணக்கு", "खाता"},
    "kyc": {"kyc", "கேஒய்சி", "केयीसि"},
    "password": {"password", "கடவுச்சொல்", "பினி", "पासवर्ड", "पिन"},
    "urgency": {"immediately", "urgent", "உடனடி", "உடனே", "அவசர", "तुरंत", "जल्दी", "अभी"},
    "tell": {"tell", "சொல்லுங்க", "சொல்லு", "கொடு", "தர", "बताइए", "बताओ", "दीजिए"},
    "bank": {"bank", "வங்கி", "बैंक"},
    "police": {"police", "போலீஸ்", "गाइड", "कावल"},
    "money": {"money", "பணம்", "पैसे", "रुपये", "रू"},
    "click": {"click", "கிளிக்", "लिंक", "क्लिक"},
    "install": {"install", "இன்ஸ்டால்", "इंस्टॉल", "app"},
    "prize": {"prize", "பரிசு", "लॉटरी", "इनाम"},
    "suspicious_app": {"anydesk", "teamviewer", "quicksupport", "screen share"},
}

TANGLISH = {
    "unga": "your",
    "ungal": "your",
    "sollunga": "tell",
    "sollu": "tell",
    "aagiduchu": "expired",
    "aagachu": "expired",
    "pannunga": "do",
    "pannu": "do",
    "irundhu": "from",
    "kudunga": "give",
    "kudunga": "give",
    "kondhuttu": "take away",
    "paarthu": "look",
    "konjam": "a little",
    "theva": "needed",
}

LANG_BLOCKS = {
    "Tamil": [(0x0B80, 0x0BFF)],
    "Devanagari": [(0x0900, 0x097F)],
    "Telugu": [(0x0C00, 0x0C7F)],
    "Malayalam": [(0x0D00, 0x0D7F)],
    "Kannada": [(0x0C80, 0x0CFF)],
}

KNOWN_MARKERS = {
    "Tamil": ["unga", "ungal", "sollunga", "aagiduchu", "pannunga", "irundhu", "vaanga", "podunga", "konjam", "enakku", "mudivu"],
    "Hindi": ["apka", "aapka", "karein", "kijiye", "sakta", "raha", "rahi", "hoga", "hoja", "karo", "karne", "ke liye", "abhi", "tumhara", "mujhe"],
}

SCAM_SIGNS = {
    "credential": ["pin", "password", "passcode", "atmpin", "netbanking", "pwd", "கடவுச்சொல்"],
    "otp_give": ["otp share", "share otp", "tell me otp", "send me otp", "otp சொல்லுங்க", "otp பங்கு"],
    "block_today": ["blocked today", "block today", "within 24", "today itself", "இன்று"],
    "money_send": ["send money", "transfer money", "pay now", "advance", "processing fee", "refund required"],
    "remote": ["anydesk", "teamviewer", "quicksupport", "download the app"],
    "verify_urgent": ["verify immediately", "update immediately", "complete kyc", "kyc update", "link expire"],
    "police": ["arrest", "court", "supari", "cyber cell", "non-bailable"],
    "prize": ["won", "winner", "lucky draw", "congratulations you have won"],
}


class Messaging:
    def detect_language(self, text):
        detected = set()
        for ch in text:
            o = ord(ch)
            for lang, blocks in LANG_BLOCKS.items():
                for lo, hi in blocks:
                    if lo <= o <= hi:
                        detected.add(lang)
        lowered = text.lower()
        for lang, markers in KNOWN_MARKERS.items():
            if any(m in lowered for m in markers):
                detected.add(lang)
        if len(detected) > 1:
            return "Mixed"
        if not detected:
            return "English" if re.search(r"[a-zA-Z]", text) else "Unknown"
        return list(detected)[0]

    def normalize(self, text):
        original = text or ""
        lowered = original.lower().strip()
        collapsed = re.sub(r"\s+", " ", lowered)
        return {
            "original": original,
            "normalized": collapsed,
            "detected_language": self.detect_language(original),
        }

    def translate_tanglish(self, text):
        lowered = text.lower()
        replaced = lowered
        for k, v in TANGLISH.items():
            replaced = replaced.replace(k, v)
        return replaced

    def regional_eng_signals(self, text):
        lowered = text.lower()
        found = {}
        for sig, variants in REGIONAL_SIGNS.items():
            for v in variants:
                if v in lowered:
                    found[sig] = found.get(sig, 0) + 1
        return found


messaging = Messaging()