# Normalization Service for Multilingual ScameGo Pipeline

import re

class NormalizationService:
    @staticmethod
    def deobfuscate(text: str) -> str:
        if not text:
            return ""
            
        res = text
        # Remove zero-width spaces and control characters
        res = re.sub(r'[\u200B-\u200D\uFEFF]', '', res)
        
        # Obfuscated word replacements (0 -> o)
        res = re.sub(r'\bt0\b', 'to', res, flags=re.I)
        res = re.sub(r'\b0n\b', 'on', res, flags=re.I)
        res = re.sub(r'\bB0nus\b', 'Bonus', res, flags=re.I)
        res = re.sub(r'\bY0u\b', 'You', res, flags=re.I)
        res = re.sub(r'\bY0ur\b', 'Your', res, flags=re.I)
        res = re.sub(r'\bL0an\b', 'Loan', res, flags=re.I)
        res = re.sub(r'\bN0\b', 'No', res, flags=re.I)
        res = re.sub(r'\bAcc\b', 'Account', res, flags=re.I)
        
        # Obfuscated zero digits (e.g., Rs.38,OOO -> Rs.38,000, 51OOO -> 51000)
        res = re.sub(r'(Rs\.?|INR|₹|\b)(\d+[, ]*[O0]{2,6})\b', lambda m: m.group(1) + m.group(2).replace('O', '0').replace('o', '0'), res, flags=re.I)
        
        # Clean extra spaces
        res = re.sub(r'\s+', ' ', res).strip()
        return res

    @staticmethod
    def extract_protected_tokens(text: str) -> list:
        """Extracts critical scam tokens (OTP, KYC, UPI IDs, amounts, URLs) so they are preserved without distortion."""
        tokens = []
        if re.search(r'\botp\b', text, re.I): tokens.append("OTP")
        if re.search(r'\bkyc\b', text, re.I): tokens.append("KYC")
        if re.search(r'\bupi\b', text, re.I): tokens.append("UPI")
        if re.search(r'\bpin\b', text, re.I): tokens.append("PIN")
        if re.search(r'\bcvv\b', text, re.I): tokens.append("CVV")
        if re.search(r'\bpan\b', text, re.I): tokens.append("PAN")
        if re.search(r'\baadhaar\b', text, re.I): tokens.append("Aadhaar")
        if "₹" in text or "rs." in text.lower(): tokens.append("INR_AMOUNT")
        return tokens
