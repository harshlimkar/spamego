import json
import logging
from typing import Dict, Any, Optional, List
from dataclasses import dataclass
import httpx

from llm.config import config

logger = logging.getLogger(__name__)


@dataclass
class GroqResponse:
    success: bool
    content: Optional[str] = None
    error: Optional[str] = None
    raw_response: Optional[Dict] = None


class GroqClient:
    def __init__(self):
        self.api_key = config.groq_api_key
        self.model = config.groq_model
        self.enabled = config.groq_enabled and bool(self.api_key)
        self.timeout = config.groq_timeout
        self.base_url = "https://api.groq.com/openai/v1/chat/completions"
        
        if not self.enabled:
            logger.warning("Groq client disabled - API key not configured or GROQ_ENABLED=false")

    def _build_headers(self) -> Dict[str, str]:
        return {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }

    def _build_payload(self, messages: List[Dict[str, str]], temperature: float = 0.1, max_tokens: int = 1000) -> Dict[str, Any]:
        return {
            "model": self.model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": max_tokens,
            "response_format": {"type": "json_object"}
        }

    async def _make_request(self, payload: Dict[str, Any]) -> GroqResponse:
        if not self.enabled:
            return GroqResponse(success=False, error="Groq client not enabled")

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(
                    self.base_url,
                    headers=self._build_headers(),
                    json=payload
                )
                
                if response.status_code == 200:
                    data = response.json()
                    content = data.get("choices", [{}])[0].get("message", {}).get("content", "")
                    return GroqResponse(success=True, content=content, raw_response=data)
                else:
                    error_msg = f"Groq API error: {response.status_code} - {response.text}"
                    logger.error(error_msg)
                    return GroqResponse(success=False, error=error_msg, raw_response=response.json() if response.text else None)
                    
        except httpx.TimeoutException:
            error_msg = f"Groq request timeout after {self.timeout}s"
            logger.error(error_msg)
            return GroqResponse(success=False, error=error_msg)
        except Exception as e:
            error_msg = f"Groq request failed: {str(e)}"
            logger.error(error_msg)
            return GroqResponse(success=False, error=error_msg)

    async def analyze_scam_context(self, structured_signals: Dict[str, Any]) -> GroqResponse:
        """
        Analyze scam context using structured signals (not raw content).
        Returns contextual reasoning about the scam.
        """
        system_prompt = """You are a scam analysis expert. Given structured signals from a security system, provide:
1. Scam stage identification (DELIVERY, PRETEXTING, URGENCY, ISOLATION, CREDENTIAL_HARVESTING, EXPLOITATION, OBJECTIVE_COMPLETION, BENIGN, UNKNOWN)
2. Attacker intent (what they want the victim to do)
3. Plain-language explanation for the user
4. Recommended immediate action
5. Confidence in your assessment (0-1)

Return ONLY valid JSON with these fields:
{
  "stage": "STAGE_NAME",
  "intent": ["intent1", "intent2"],
  "explanation": "Plain language explanation for the user",
  "recommended_action": "ACTION_NAME",
  "confidence": 0.95,
  "reasoning": "Brief technical reasoning for the assessment"
}"""

        user_prompt = f"""Analyze these security signals:

ML Classification: {structured_signals.get('ml_classification', 'UNKNOWN')}
ML Confidence: {structured_signals.get('ml_confidence', 0)}
ML Risk Score: {structured_signals.get('ml_risk_score', 0)}

Rule Signals: {structured_signals.get('rule_signals', [])}
Keyword Categories: {structured_signals.get('keyword_categories', [])}
Triggered Rules: {structured_signals.get('triggered_rules', [])}

Sender Verification: {structured_signals.get('sender_verification', 'UNKNOWN')}
Sender Reputation: {structured_signals.get('sender_reputation', 'UNKNOWN')}

Campaign Context:
- Campaign ID: {structured_signals.get('campaign_id', 'NONE')}
- Campaign Stage: {structured_signals.get('campaign_stage', 'UNKNOWN')}
- Campaign Risk: {structured_signals.get('campaign_risk', 0)}
- Events in Campaign: {structured_signals.get('campaign_event_count', 0)}
- Stage Progression: {structured_signals.get('stage_progression', [])}

Exposure:
- Money: {structured_signals.get('money_exposure', 0)}
- Credentials: {structured_signals.get('credential_exposure', False)}
- OTP: {structured_signals.get('otp_exposure', False)}
- Device Access: {structured_signals.get('device_access_exposure', False)}

Intent Signals: {structured_signals.get('intent_signals', [])}
Progression Velocity: {structured_signals.get('progression_velocity', 'UNKNOWN')}"""

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]

        payload = self._build_payload(messages, temperature=0.1, max_tokens=1500)
        return await self._make_request(payload)

    async def generate_plain_explanation(self, signals: Dict[str, Any]) -> GroqResponse:
        """Generate a plain-language explanation for the user."""
        system_prompt = """You are a helpful security assistant. Convert technical scam signals into a clear, concise explanation for a non-technical user. 
Do NOT invent evidence. Only reference the signals provided.
Keep it under 3 sentences. Be direct and actionable."""

        user_prompt = f"""Signals detected:
- Stage: {signals.get('stage', 'UNKNOWN')}
- Intent: {signals.get('intent', [])}
- Key indicators: {signals.get('keyword_categories', [])}
- Sender status: {signals.get('sender_verification', 'UNKNOWN')}
- Exposure: Money={signals.get('money_exposure', 0)}, OTP={signals.get('otp_exposure', False)}, Credentials={signals.get('credential_exposure', False)}"""

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]

        payload = self._build_payload(messages, temperature=0.2, max_tokens=500)
        return await self._make_request(payload)

    async def assess_campaign_progression(self, campaign_events: List[Dict[str, Any]]) -> GroqResponse:
        """Assess how a campaign is progressing across events."""
        system_prompt = """Analyze the progression of a scam campaign across multiple events.
Identify the kill-chain stage progression and velocity.
Return JSON with:
{
  "current_stage": "STAGE_NAME",
  "progression_velocity": "RAPID|MODERATE|SLOW",
  "stage_transitions": [{"from": "STAGE", "to": "STAGE", "time_seconds": 120}],
  "escalation_risk": "LOW|MEDIUM|HIGH|CRITICAL",
  "reasoning": "Brief explanation"
}"""

        events_summary = []
        for e in campaign_events:
            events_summary.append({
                "timestamp": e.get("timestamp"),
                "stage": e.get("stage", "UNKNOWN"),
                "risk_score": e.get("risk_score", 0),
                "intent": e.get("intent", []),
                "channel": e.get("channel", "UNKNOWN")
            })

        user_prompt = f"Campaign events (chronological):\n{json.dumps(events_summary, indent=2)}"

        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ]

        payload = self._build_payload(messages, temperature=0.1, max_tokens=1000)
        return await self._make_request(payload)


groq_client = GroqClient()