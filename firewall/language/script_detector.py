# Script Detector for Indian Languages and Scripts

class ScriptDetector:
    # Unicode codepoints for Indic scripts
    SCRIPT_RANGES = {
        "Tamil": (0x0B80, 0x0BFF),
        "Devanagari": (0x0900, 0x097F),
        "Telugu": (0x0C00, 0x0C7F),
        "Malayalam": (0x0D00, 0x0D7F),
        "Kannada": (0x0C80, 0x0CFF),
        "Bengali": (0x0980, 0x09FF),
        "Gujarati": (0x0A80, 0x0AFF),
        "Gurmukhi": (0x0A00, 0x0A7F),
        "Latin": (0x0041, 0x007A),
    }

    def detect_scripts(self, text: str) -> dict:
        if not text:
            return {"primary_script": "Latin", "scripts": ["Latin"], "is_mixed_script": False}

        counts = {s: 0 for s in self.SCRIPT_RANGES}
        total_letters = 0

        for ch in text:
            code = ord(ch)
            total_letters += 1
            for script, (low, high) in self.SCRIPT_RANGES.items():
                if low <= code <= high:
                    counts[script] += 1
                    break

        active_scripts = [s for s, count in counts.items() if count > 0]
        if not active_scripts:
            active_scripts = ["Latin"]

        # Primary script is the one with highest count
        primary = max(counts, key=counts.get)
        if counts[primary] == 0:
            primary = "Latin"

        # Mixed script if there is significant presence of both Indic and Latin
        indic_count = sum(count for s, count in counts.items() if s != "Latin")
        is_mixed = counts["Latin"] > 0 and indic_count > 0

        return {
            "primary_script": primary,
            "scripts": active_scripts,
            "is_mixed_script": is_mixed,
            "script_counts": {s: c for s, c in counts.items() if c > 0},
        }
