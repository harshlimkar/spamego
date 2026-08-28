package com.scamdetect.scam_detect_call

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel

class AudioRecorderService : EventChannel.StreamHandler {
    companion object {
        private const val TAG = "AudioRecorderService"
        const val EVENT_CHANNEL = "com.scamdetect.call/audio_stream"

        // 16 kHz, 16-bit mono – Groq Whisper works great with this
        private const val SAMPLE_RATE = 16000
        private const val CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_MONO
        private const val AUDIO_FORMAT = AudioFormat.ENCODING_PCM_16BIT
    }

    // ── Must post to main thread to talk to Flutter ──────────────
    private val mainHandler = Handler(Looper.getMainLooper())

    private var audioRecord: AudioRecord? = null
    @Volatile private var isRecording = false
    private var recordingThread: Thread? = null
    private var eventSink: EventChannel.EventSink? = null

    // ── EventChannel.StreamHandler ────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "onListen – starting mic recording")
        startRecording()
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "onCancel – stopping mic recording")
        stopRecording()
        eventSink = null
    }

    // ── Recording ──────────────────────────────────────────────────

    fun startRecording() {
        if (isRecording) return

        val minBuffer = AudioRecord.getMinBufferSize(SAMPLE_RATE, CHANNEL_CONFIG, AUDIO_FORMAT)
        // ~0.5 s per chunk at 16 kHz, 16-bit (1 frame = 2 bytes)
        val bufferSize = maxOf(minBuffer * 4, SAMPLE_RATE * 2 / 2)

        try {
            val ar = AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                CHANNEL_CONFIG,
                AUDIO_FORMAT,
                bufferSize
            )
            if (ar.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(TAG, "AudioRecord failed to initialise – check RECORD_AUDIO permission")
                sendError("INIT_ERROR", "AudioRecord not initialised. Grant RECORD_AUDIO permission.")
                ar.release()
                return
            }
            audioRecord = ar
            ar.startRecording()
            isRecording = true
            Log.d(TAG, "Recording started: $SAMPLE_RATE Hz, buffer=$bufferSize bytes")

            recordingThread = Thread({
                val buf = ByteArray(bufferSize)
                while (isRecording) {
                    val read = ar.read(buf, 0, buf.size)
                    if (read > 0) {
                        val chunk = buf.copyOf(read)
                        // ⚠️  EventSink MUST be called on the main thread
                        mainHandler.post {
                            eventSink?.success(chunk)
                        }
                    }
                }
                Log.d(TAG, "Recording thread exiting")
            }, "AudioRecordThread")
            recordingThread!!.priority = Thread.MAX_PRIORITY
            recordingThread!!.start()

        } catch (se: SecurityException) {
            Log.e(TAG, "RECORD_AUDIO permission denied: $se")
            sendError("PERMISSION_DENIED", "Microphone permission denied")
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error: $e")
            sendError("RECORDING_ERROR", e.message ?: "Unknown error")
        }
    }

    fun stopRecording() {
        isRecording = false
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (_: Exception) {}
        audioRecord = null
        try {
            recordingThread?.join(2000)
        } catch (_: InterruptedException) {}
        recordingThread = null
        Log.d(TAG, "Recording stopped")
    }

    // ── Private helpers ────────────────────────────────────────────

    private fun sendError(code: String, msg: String) {
        mainHandler.post {
            eventSink?.error(code, msg, null)
        }
    }
}
