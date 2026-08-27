import uuid
import time
import requests
from hardware.adapters import SmsAdapter, MockSmsAdapter

class RemoteIntelligenceClient:
    def __init__(self):
        # We use a mocked SMS adapter to simulate the GSM network transmission.
        self.sms_adapter = MockSmsAdapter()
        # In a real deployment, the SMS is sent to a shortcode or gateway number.
        self.server_number = "55555" 
        # For our local simulation, we send it to our FastAPI webhook over HTTP.
        self.simulation_webhook_url = "http://127.0.0.1:8000/api/sms_webhook"

    def _generate_request_id(self):
        return f"REQ{str(uuid.uuid4().int)[:5]}"

    def query_server(self, sender_number, categories):
        """
        Phase 2, 3, 4: Creates request, tracks ID, sends via SMS adapter.
        """
        request_id = self._generate_request_id()
        cat_string = ",".join(categories) if categories else "NONE"
        
        # Phase 3: Create SMS request generator
        sms_body = f"SCG|CHECK|{request_id}|{sender_number}|{cat_string}"
        
        print(f"[GSM/SMS SIMULATION] Feature Phone sending SMS to {self.server_number}: {sms_body}")
        
        # Actually send via hardware adapter (simulated)
        self.sms_adapter.send_sms(self.server_number, sms_body)

        # Simulate waiting for the SMS response. We use an HTTP call to our local FastAPI server
        # to simulate the GSM network delivering the SMS and returning the response SMS.
        try:
            # 5 second timeout for "Mode A (Offline Fallback)" testing
            response = requests.post(
                self.simulation_webhook_url, 
                json={"sender": "user_phone", "body": sms_body},
                timeout=5
            )
            
            if response.status_code == 200:
                response_sms = response.json().get("response_sms", "")
                print(f"[GSM/SMS SIMULATION] Feature Phone received SMS: {response_sms}")
                return self.parse_response(response_sms, request_id)
            else:
                print(f"[GSM/SMS SIMULATION] Server returned error: {response.status_code}")
                return None
        except requests.exceptions.RequestException as e:
            print("[GSM/SMS SIMULATION] Server unavailable or timeout (Offline Fallback).")
            return None

    def parse_response(self, response_sms, expected_request_id):
        """
        Phase 9: Create phone response parser
        Response format: SCG|RESULT|REQ12345|HIGH|UNVERIFIED|KYC_OTP|88
        """
        parts = response_sms.split("|")
        
        if len(parts) >= 7 and parts[0] == "SCG" and parts[1] == "RESULT":
            req_id = parts[2]
            
            # Phase 4: Request ID Tracking Validation
            if req_id != expected_request_id:
                print(f"[REMOTE CLIENT ERROR] Mismatched Request ID. Expected {expected_request_id}, got {req_id}")
                return None
                
            risk_level = parts[3]
            number_status = parts[4]
            category = parts[5]
            risk_score = int(parts[6])
            
            reason = parts[7] if len(parts) > 7 else ""
            
            return {
                "risk_level": risk_level,
                "number_status": number_status,
                "category": category,
                "risk_score": risk_score,
                "reason": reason
            }
        
        print("[REMOTE CLIENT ERROR] Malformed response.")
        return None

    def sync_threat_intelligence(self):
        """
        Phase 13: Mode C - Connected Update
        """
        print("[DATA SYNC] Connecting to ScameGo Server for threat intelligence update...")
        try:
            # We assume data connectivity (GPRS/4G) for this operation, not SMS.
            response = requests.get("http://127.0.0.1:8000/api/sync_threat_intelligence", timeout=5)
            if response.status_code == 200:
                data = response.json()
                from database.repository import NumberRepository
                
                # Update local cache with fetched reported numbers
                for reported in data.get("reported_numbers", []):
                    NumberRepository.cache_remote_result(reported["number"], "REPORTED_SCAM", reported["scam_type"])
                    
                print(f"[DATA SYNC] Successfully updated database to Server Version: {data.get('server_version')}")
            else:
                print(f"[DATA SYNC] Sync failed with status: {response.status_code}. Keeping old database.")
        except requests.exceptions.RequestException:
            print("[DATA SYNC] Server unavailable. Sync failed. Continuing with existing local database.")
