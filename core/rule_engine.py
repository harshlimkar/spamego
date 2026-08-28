class RuleEngine:
    def __init__(self):
        # Behavioral combinatory rules
        self.rules = [
            {
                "rule_id": "IMPERSONATION_+REQUEST_URGENCY",
                "conditions": {
                    "behaviors": ["URGENCY"],
                    "domains": ["LEGAL", "FINANCIAL", "MEDICAL", "DELIVERY"]
                },
                "requires_request": True, # Needs PAYMENT_REQUEST, CREDENTIAL_REQUEST, or REMOTE_ACCESS
                "risk_added": 50
            },
            {
                "rule_id": "THREAT_ISOLATION",
                "conditions": {
                    "behaviors": ["THREAT", "ISOLATION"]
                },
                "requires_request": False,
                "risk_added": 60
            },
            {
                "rule_id": "EMERGENCY_PAYMENT",
                "conditions": {
                    "behaviors": ["EMERGENCY_CLAIM", "PAYMENT_REQUEST"]
                },
                "requires_request": False,
                "risk_added": 50
            },
            {
                "rule_id": "REMOTE_ACCESS_MALWARE",
                "conditions": {
                    "behaviors": ["REMOTE_ACCESS_REQUEST"]
                },
                "requires_request": False,
                "risk_added": 40
            },
            {
                "rule_id": "OTP_CREDENTIAL_THEFT",
                "conditions": {
                    "behaviors": ["CREDENTIAL_REQUEST"],
                    "domains": ["FINANCIAL", "DELIVERY", "TELECOM"]
                },
                "requires_request": False,
                "risk_added": 45
            }
        ]

    def evaluate_rules(self, categories, keywords_detected, context_data=None):
        # We now accept domains, behaviors, scam_types directly from KeywordEngine via kwargs,
        # but to keep backward compatibility or signature simplicity, we'll parse them.
        # Actually, let's assume we receive the full kw_result dict instead.
        pass
        
    def evaluate_behavioral_rules(self, kw_result, context_data=None):
        triggered_rules = []
        rule_risk_score = 0
        
        domains_set = set(kw_result.get("domains", []))
        behaviors_set = set(kw_result.get("behaviors", []))
        
        has_request = bool({"PAYMENT_REQUEST", "CREDENTIAL_REQUEST", "REMOTE_ACCESS_REQUEST", "IDENTITY_REQUEST", "LINK_REQUEST"}.intersection(behaviors_set))

        # Check context for past behaviors
        if context_data:
            past_cats = context_data.get("previous_categories", set())
            # We treat past_cats as containing past behaviors and domains for simplicity
            domains_set.update([c for c in past_cats if c in ["FINANCIAL", "LEGAL", "MEDICAL", "DELIVERY", "EMPLOYMENT"]])
            behaviors_set.update([c for c in past_cats if c in ["URGENCY", "THREAT", "ISOLATION", "EMERGENCY_CLAIM", "PAYMENT_REQUEST", "CREDENTIAL_REQUEST"]])
            has_request = has_request or bool({"PAYMENT_REQUEST", "CREDENTIAL_REQUEST", "REMOTE_ACCESS_REQUEST", "IDENTITY_REQUEST"}.intersection(past_cats))

        for rule in self.rules:
            req_behaviors = set(rule["conditions"].get("behaviors", []))
            req_domains = set(rule["conditions"].get("domains", []))
            
            behavior_match = req_behaviors.issubset(behaviors_set) if req_behaviors else True
            domain_match = bool(req_domains.intersection(domains_set)) if req_domains else True
            request_match = has_request if rule.get("requires_request") else True
            
            if behavior_match and domain_match and request_match:
                triggered_rules.append(rule["rule_id"])
                rule_risk_score += rule["risk_added"]
                
        return {
            "triggered_rules": triggered_rules,
            "rule_risk_score": rule_risk_score
        }
