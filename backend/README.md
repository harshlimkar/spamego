# Live Call Scam Detection Backend

This is the backend component of the live call scam detection module. It accepts live phone calls via Twilio Voice, streams the audio for Speech-to-Text, and scores the conversation risk using a local Ollama (Qwen) model. 

The frontend Flutter app acts as the **Native Default Phone Dialer** on Android. When you make a call, it intercepts the call, natively dials your Twilio number, and uses Twilio to forward the call to the destination while extracting the audio stream for the AI Sentinel.

## Prerequisites
1. **Twilio Account**: You need an active Twilio phone number. (If using a free Trial account, the destination numbers you call must be verified in your Twilio console!)
2. **ngrok**: To expose the local FastAPI server to Twilio.

## Setup

1. **Environment Variables**: 
Create a `.env` file in this directory with the following variables:
```
GROQ_API_KEY=your_groq_api_key
OLLAMA_URL=http://localhost:11434/api/generate
OLLAMA_MODEL=qwen
```

2. **Start the backend**:
Make sure the virtual environment is active, then run:
```bash
python main.py
```
The server will start on port `8000`.

3. **Expose with ngrok**:
Run ngrok to expose port 8000:
```bash
ngrok http 8000
```
Note the `https://...` forwarding URL.

4. **Configure Twilio Webhook**:
In your Twilio console, go to your Active Number, and set the **"A CALL COMES IN"** Webhook to:
`https://<your-ngrok-id>.ngrok-free.app/twilio/voice` (HTTP POST)

## Testing the Full Flow
1. Run the Flutter App on your Android device. 
2. Enter a phone number (e.g., `8778080037`) and tap **Connect Call**.
3. Accept the prompt to "Set as default phone app" if asked.
4. The app will natively dial your Twilio bridge.
5. Twilio intercepts the call, forwards it to the destination, and streams the live audio to this Python backend.
6. Check your Flutter app screen—the live AI Scam Risk score will start streaming on the screen!
