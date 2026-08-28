import re

from .schema import EntityExtraction

PHONE_RE = re.compile(r"(?<!\d)(?:\+?91[- ]?)?[6-9]\d{9}(?!\d)")
UPI_RE = re.compile(r"[a-zA-Z0-9][a-zA-Z0-9._-]{2,29}@[a-zA-Z]{2,10}")
AMOUNT_UNIT_RE = re.compile(r"(?P<num>[0-9][0-9,]*)\s*(?P<unit>lakh|lakhs|thousand|k|cr|crores|crore|hundred)\b", re.IGNORECASE)
URL_RE = re.compile(r"(?:https?://|www\.)[a-zA-Z0-9._~:/?#\[\]@!$&'()*+,;=%-]+")

BANK_ORGS = [
    "sbi", "state bank", "hdfc", "icici", "axis", "kotak", "pnb", "punjab national",
    "canara", "idbi", "indusind", "yes bank", "rbi", "reserve bank", "union bank",
    "bank of baroda", "bob", "airtel", "jio", "vi", "vodafone", "paytm", "phonepe", "gpay", "google pay",
    "npci", "upi", "epfo", "esic", "income tax", "gst", "passport seva", "aadhaar", "uidai", "mygov", "gov",
]

APPS = [
    "anydesk", "teamviewer", "quicksupport", "rapid", "screen", "cashapp", "paytm", "phonepe",
]

TRUSTED_DOMAINS = {
    "sbi.co.in", "onlinesbi.sbi", "hdfcbank.com", "icicibank.com", "axisbank.com",
    "kotak.com", "pnbindia.in", "canarabank.com", "idbi.online.my.id", "indusind.com",
    "yesbank.in", "rbi.org.in", "npci.org.in", "upi.org.in", "mygov.in", "umang.gov.in",
    "incometax.gov.in", "onlineservices.nsdl.com", "epfindia.gov.in", "uidai.gov.in",
    "airtel.in", "jio.com", "paytm.com", "phonepe.com", "googlepay.google", "irctc.co.in",
    "indiapost.gov.in", "passportindia.gov.in", "gst.gov.in", "acko.com", "policybazaar.com",
}

SUSPICIOUS_TLDS = {
    "xyz", "top", "click", "online", "site", "link", "info", "buzz", "icu",
    "tk", "ml", "ga", "cf", "gq", "men", "review", "stream", "win", "monster",
    "support", "accountant", "loan", "live", "shop",
}

_BRAND_HINTS = ["sbi", "hdfc", "icici", "axis", "kotak", "pnb", "bank", "upi", "paytm", "phonepe", "gpay", "googlepay", "irctc", "aadhaar", "uidai", "mygov", "gov", "income-tax", "incometax", "gst", "epfo", "electricity", "passport"]


class LdDistance:
    @staticmethod
    def distance(a, b):
        if a == b:
            return 0
        la, lb = len(a), len(b)
        if la == 0 or lb == 0:
            return max(la, lb)
        prev = list(range(lb + 1))
        for i in range(1, la + 1):
            cur = [i]
            for j in range(1, lb + 1):
                cost = 0 if a[i - 1] == b[j - 1] else 1
                cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost))
            prev = cur
        return prev[lb]


def _registrable_domain(host):
    parts = host.rsplit(".", 2)
    if len(parts) == 1:
        return host
    if len(parts) == 2:
        return ".".join(parts)
    if parts[-2] in {"co", "com", "gov", "org", "net", "ac", "org", "nic", "in"} and len(parts[-1]) == 2:
        return ".".join(parts[-3:])
    return ".".join(parts[-2:])


class EntityExtractor:
    def extract(self, text):
        url_matches = URL_RE.findall(text) if text else []
        urls = [u if u.startswith("http") else "https://" + u for u in url_matches]
        phones = PHONE_RE.findall(text) if text else []
        upis = UPI_RE.findall(text) if text else []
        amounts = set()
        for m in AMOUNT_UNIT_RE.finditer(text or ""):
            num = int(m.group("num").replace(",", ""))
            unit = m.group("unit").lower()
            multiplier = {"lakh": 100000, "thousand": 1000, "k": 1000, "cr": 10000000, "crore": 10000000}[unit]
            if "lakhs" in unit or "lakh" in unit:
                multiplier = 100000
            amounts.add(num * multiplier)
        for m in re.finditer(r"(?:rs\.?|inr|₹|ரூ|रु)\s*([0-9][0-9,]*)", text or "", re.IGNORECASE):
            amounts.add(int(m.group(1).replace(",", "")))
        apps = [a for a in APPS if a in (text or "").lower()]
        org_claims = [o for o in BANK_ORGS if o in (text or "").lower()]
        return EntityExtraction(
            phone_numbers=phones,
            upi_ids=list(dict.fromkeys(upis)),
            amounts_inr=sorted(amounts),
            urls=list(dict.fromkeys(urls)),
            apps=apps,
            organization_claims=list(dict.fromkeys(org_claims)),
        )


class LinkAnalyzer:
    def __init__(self, trusted_domains=None):
        self.trusted = set(trusted_domains or TRUSTED_DOMAINS)

    def _host(self, url):
        clean = url.split("?")[0].split("#")[0]
        if "://" in clean:
            clean = clean.split("://")[1]
        host = clean.split("/")[0].split(":")[0].lower().lstrip("www.")
        return host

    def analyze(self, url):
        host = self._host(url)
        reg = _registrable_domain(host)
        exact_trusted = reg in self.trusted
        tld = reg.rsplit(".", 1)[-1] if "." in reg else ""
        suspicious_tld = tld in SUSPICIOUS_TLDS
        brand_squat = False
        reason = []
        if exact_trusted:
            reason.append("Matches a known official domain.")
        lookalike = None
        for trusted in self.trusted:
            dist = LdDistance.distance(host, trusted)
            if 0 < dist <= 2:
                lookalike = trusted
                brand_squat = True
                break
            if dist <= 3 and len(trusted) >= 8:
                lookalike = trusted
                brand_squat = True
                break
        lower = host.lower()
        for hint in _BRAND_HINTS:
            if hint in lower and not exact_trusted:
                brand_squat = brand_squat or True
        is_suspicious = suspicious_tld or brand_squat and not exact_trusted
        if suspicious_tld:
            reason.append("Registered on a frequently-abused top-level domain (.%s)." % tld)
        if brand_squat and not exact_trusted:
            reason.append("Domain resembles or contains a trusted brand name but is not the official domain.")
        verdict = "safe" if exact_trusted else ("suspicious" if is_suspicious else "unverified")
        return {
            "url": url,
            "normalized_url": "https://" + host,
            "domain": host,
            "registrable_domain": reg,
            "is_suspicious": bool(is_suspicious),
            "reason": " ".join(reason),
            "matches_trusted": exact_trusted,
            "verdict": verdict,
            "confidence": 0.95 if exact_trusted or is_suspicious else 0.5,
        }

    def analyze_many(self, urls):
        return [self.analyze(u) for u in urls]


entity_extractor = EntityExtractor()
link_analyzer = LinkAnalyzer()