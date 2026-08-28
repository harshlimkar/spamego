import hashlib
import json
import math
import os
import re

BASE = os.path.dirname(os.path.abspath(__file__))
WEIGHTS_PATH = os.path.join(BASE, "edge_weights.json")

N_FEATURES = 1 << 16
N_GRAM_SIZES = (2, 3, 4)

FALLBACK_KEYWORDS = {
    "otp": 25, "kyc": 22, "block": 20, "atm": 15, "pin": 22, "password": 20,
    "urgent": 12, "immediately": 12, "expire": 16, "expired": 16, "link": 10,
    "transfer": 18, "refund": 14, "prize": 14, "win": 12, "lottery": 14,
    "investment": 12, "double": 12, "anydesk": 25, "teamviewer": 25,
    "police": 15, "arrest": 20, "court": 15, "frozen": 18, "suspended": 16,
    "verify": 8, "update": 8, "helpline": 8, "click": 8, "share": 12, "tell": 6,
    "congratulations": 6, "upgrade": 10, "aadhaar": 10, "pan": 8,
    "ஒடிபி": 25, "சொல்லுங்க": 20, "கணக்கு": 10, "வங்கி": 10, "உடனே": 12,
    "ब्लॉक": 20, "बैंक": 12, "लॉटरी": 14, "पैसे": 12,
    "करें": 6, "नहीं": 6, "जल्दी": 12,
}


def _features(text):
    tokens = re.findall(r"[a-zA-Z0-9\u0900-\u0BFF]+", text.lower())
    features = set()
    for tok in tokens:
        if len(tok) >= 3:
            features.add("w:" + tok)
        if len(tok) >= 4:
            features.add("w4:" + tok[:4])
    chars = text.lower()
    for size in N_GRAM_SIZES:
        for i in range(0, len(chars) - size + 1):
            features.add("c%d:%s" % (size, chars[i:i + size]))
    return features


def _hash(feature):
    digest = hashlib.md5(feature.encode("utf-8")).digest()
    return int.from_bytes(digest[:4], "little") % N_FEATURES


class EdgeModel:
    def __init__(self, weights_path=WEIGHTS_PATH):
        self.weights = None
        self.bias = 0.0
        self.loaded_from = ""
        if os.path.exists(weights_path):
            try:
                with open(weights_path, "r", encoding="utf-8") as fh:
                    data = json.load(fh)
                self.weights = {int(k): float(v) for k, v in data.get("weights", {}).items()}
                self.bias = float(data.get("bias", 0.0))
                self.loaded_from = weights_path
            except Exception:
                self.weights = None

    def is_trained(self):
        return self.weights is not None

    def score(self, text):
        if not text:
            return 0
        if self.weights is None:
            return self._fallback(text)
        feats = _features(text)
        acc = self.bias
        for f in feats:
            h = _hash(f)
            w = self.weights.get(h)
            if w:
                acc += w
        prob = 1.0 / (1.0 + math.exp(-acc))
        return int(round(prob * 100))

    def _fallback(self, text):
        lowered = text.lower()
        total = 0.0
        for kw, weight in FALLBACK_KEYWORDS.items():
            if kw in lowered:
                total += weight
        return max(0, min(100, total))


edge_model = EdgeModel()