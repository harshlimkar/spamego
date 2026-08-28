package com.scamdetect.scam_detect_call

import android.app.role.RoleManager
import android.content.Context
import android.os.Build
import android.telecom.TelecomManager
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "com.scamdetect.call/native"
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private val audioRecorder = AudioRecorderService()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Method Channel (for dialer role & placing calls) ──────
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            android.util.Log.d("ScamDetect", "Method call: ${call.method}")
            when (call.method) {
                "requestDefaultDialer" -> { requestDefaultDialer(); result.success(null) }
                "placeCall" -> {
                    val number = call.argument<String>("number")
                    if (number != null) { placeCall(number); result.success(null) }
                    else result.error("INVALID_ARGS", "Number required", null)
                }
                "stopRecording" -> { audioRecorder.stopRecording(); result.success(null) }
                else -> result.notImplemented()
            }
        }

        // ── Event Channel (streams raw PCM audio bytes to Flutter) ──
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, AudioRecorderService.EVENT_CHANNEL)
        eventChannel.setStreamHandler(audioRecorder)
    }

    private fun requestDefaultDialer() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (!roleManager.isRoleHeld(RoleManager.ROLE_DIALER)) {
                startActivityForResult(roleManager.createRequestRoleIntent(RoleManager.ROLE_DIALER), 123)
            }
        } else {
            val intent = android.content.Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            intent.putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)
            startActivity(intent)
        }
    }

    private fun placeCall(number: String) {
        val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        val uri = Uri.fromParts("tel", number, null)
        try {
            telecomManager.placeCall(uri, android.os.Bundle())
        } catch (e: SecurityException) {
            e.printStackTrace()
        }
    }
}
