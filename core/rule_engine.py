class RuleEngine:
    def __init__(self):
        # Configurable rules
        self.rules = [
            {
                "rule_id": "RULE_OTP_REQUEST",
                "conditions": {"categories": ["Credential Theft"]},
                "risk_added": 25
            },
            {
                "rule_id": "RULE_KYC_URGENCY",
                "conditions": {"categories": ["KYC Scam", "Urgency"]},
                "risk_added": 30
            },
            {
                "rule_id": "RULE_BANK_IMPERSONATION_OTP",
                "conditions": {"categories": ["Bank Impersonation", "Credential Theft"]},
                "risk_added": 40
            },
            {
                "rule_id": "RULE_POLICE_PAYMENT",
                "conditions": {"categories": ["Police Impersonation", "Payment Scam"]},
                "risk_added": 50
            },
            {
                "rule_id": "RULE_REMOTE_ACCESS_URGENCY",
                "conditions": {"categories": ["Remote Access", "Urgency"]},
                "risk_added": 40
            }
        ]

    def evaluate_rules(self, detected_categories, keyword_results):
        triggered_rules = []
        rule_risk_score = 0
        
        # simple list to check subsets
        cat_set = set(detected_categories)

        for rule in self.rules:
            req_cats = set(rule["conditions"].get("categories", []))
            
            # If all required categories for this rule are present in the text
            if req_cats and req_cats.issubset(cat_set):
                triggered_rules.append(rule["rule_id"])
                rule_risk_score += rule["risk_added"]
                
        return {
            "triggered_rules": triggered_rules,
            "rule_risk_score": rule_risk_score
        }
