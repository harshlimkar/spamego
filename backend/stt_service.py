import os
import io
import wave
import base64
import asyncio
import logging
import audioop
from groq import Groq
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger(__name__)

# How many Twilio audio chunks to buffer before sending to Groq.
# Each Twilio chunk is ~20ms of audio, so 100 chunks ≈ 2 seconds.
CHUNK_BUFFER_SIZE = 100


class STTService:
    def __init__(self):
        self.api_key = os.getenv("GROQ_API_KEY")
        if not self.api_key:
            logger.warning("No GROQ_API_KEY found! Operating in MOCK mode.")
        self.client = Groq(api_key=self.api_key) if self.api_key else None
        self.transcript_queue = asyncio.Queue()
        # Internal buffer: accumulates raw PCM audio bytes (16-bit, 8000Hz, mono)
        self._pcm_buffer = b""
        self._chunk_count = 0
        self._loop = None

    async def connect(self):
        """Nothing to connect for Groq REST — just capture the event loop."""
        self._loop = asyncio.get_event_loop()
        if self.client:
            logger.info("Groq Whisper STT service ready.")
        else:
            logger.warning("Groq STT operating in MOCK mode (no GROQ_API_KEY).")

    async def send_audio(self, twilio_payload_base64: str):
        """
        Accepts Twilio's base64 PCMU audio chunk.
        Buffers chunks and flushes to Groq every CHUNK_BUFFER_SIZE chunks.
        """
        try:
            # 1. Decode from Twilio base64
            pcmu_bytes = base64.b64decode(twilio_payload_base64)

            # 2. Convert PCMU (G.711 mu-law) → 16-bit linear PCM at 8000Hz
            pcm_bytes = audioop.ulaw2lin(pcmu_bytes, 2)

            # 3. Accumulate in the buffer
            self._pcm_buffer += pcm_bytes
            self._chunk_count += 1

            # 4. Every CHUNK_BUFFER_SIZE chunks, flush to Groq
            if self._chunk_count >= CHUNK_BUFFER_SIZE:
                await self._flush_to_groq()

        except Exception as e:
            logger.error(f"Error buffering audio: {e}")

    async def _flush_to_groq(self):
        """Sends the buffered PCM audio to Groq Whisper API and queues the transcript."""
        if not self.client or not self._pcm_buffer:
            self._pcm_buffer = b""
            self._chunk_count = 0
            return

        pcm_data = self._pcm_buffer
        self._pcm_buffer = b""
        self._chunk_count = 0

        # Run the blocking Groq API call in a thread pool to keep async loop clean
        loop = asyncio.get_event_loop()
        transcript = await loop.run_in_executor(None, self._call_groq_api, pcm_data)

        if transcript and transcript.strip():
            logger.info(f"[STT] Groq Transcript: {transcript.strip()}")
            await self.transcript_queue.put(transcript.strip())

    def _call_groq_api(self, pcm_data: bytes) -> str:
        """
        Synchronous call to Groq Whisper API.
        Wraps raw PCM bytes in a WAV container (Groq expects an audio file).
        """
        try:
            # Build a WAV file in-memory from raw PCM (8000Hz, 16-bit, mono)
            wav_buffer = io.BytesIO()
            with wave.open(wav_buffer, 'wb') as wf:
                wf.setnchannels(1)       # Mono
                wf.setsampwidth(2)       # 16-bit
                wf.setframerate(8000)    # 8kHz (Twilio's native sample rate)
                wf.writeframes(pcm_data)
            wav_buffer.seek(0)

            transcription = self.client.audio.transcriptions.create(
                file=("audio.wav", wav_buffer, "audio/wav"),
                model="whisper-large-v3-turbo",   # Fast & accurate
                response_format="text",
                language="en",
                temperature=0.0,
                prompt="This is a phone call. Listen for scam patterns, OTP requests, bank fraud, impersonation."
            )
            return transcription
        except Exception as e:
            logger.error(f"Groq API error: {e}")
            return ""

    async def receive_transcript(self, timeout=0.1) -> str | None:
        """Returns a transcript chunk from the queue if available."""
        try:
            return await asyncio.wait_for(self.transcript_queue.get(), timeout=timeout)
        except asyncio.TimeoutError:
            return None

    async def close(self):
        """Flush any remaining buffered audio before shutting down."""
        if self._pcm_buffer:
            logger.info("Flushing remaining audio buffer to Groq...")
            await self._flush_to_groq()
        logger.info("Groq STT service closed.")
