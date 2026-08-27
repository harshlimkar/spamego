class TelephonyAdapter:
    def get_incoming_call(self):
        raise NotImplementedError

    def end_call(self):
        raise NotImplementedError

    def bridge_call(self, number):
        raise NotImplementedError

class SmsAdapter:
    def send_sms(self, to_number, message):
        raise NotImplementedError

    def read_latest_sms(self):
        raise NotImplementedError

class AudioAdapter:
    def play_audio(self, audio_id):
        raise NotImplementedError

    def get_speech_text(self):
        raise NotImplementedError

class KeypadAdapter:
    def get_keypress(self):
        raise NotImplementedError

# Mocks for demonstration
class MockTelephonyAdapter(TelephonyAdapter):
    def end_call(self):
        print("[HARDWARE] Call ended.")

    def bridge_call(self, number):
        print(f"[HARDWARE] Bridging call to {number}...")

class MockSmsAdapter(SmsAdapter):
    def send_sms(self, to_number, message):
        print(f"[HARDWARE] Sending SMS to {to_number}: {message}")

class MockAudioAdapter(AudioAdapter):
    def play_audio(self, audio_text):
        print(f"[AUDIO OUT] {audio_text}")

class MockKeypadAdapter(KeypadAdapter):
    def get_keypress(self):
        return input("[KEYPAD] Press a key: ")
