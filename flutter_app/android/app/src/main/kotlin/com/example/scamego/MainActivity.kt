package com.example.scamego

import android.Manifest
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.app.role.RoleManager
import android.provider.Settings
import android.provider.Telephony
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.HashMap

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "scamego/platform"
    private val SMS_EVENT_CHANNEL = "scamego/sms_stream"
    private val CALL_EVENT_CHANNEL = "scamego/call_stream"
    private val NOTIFICATION_EVENT_CHANNEL = "scamego/notification_stream"

    private var smsReceiver: SmsReceiver? = null
    private var eventSink: EventSink? = null
    private var callEventSink: EventSink? = null
    private var notificationEventSink: EventSink? = null
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var callEventChannel: EventChannel? = null
    private var notificationEventChannel: EventChannel? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel?.setMethodCallHandler(MethodCallHandler { call, result ->
            handleMethodCall(call, result)
        })

        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_EVENT_CHANNEL)
        eventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                eventSink = events
                registerSmsReceiver()
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                unregisterSmsReceiver()
            }
        })

        callEventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_EVENT_CHANNEL)
        callEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                callEventSink = events
                // Notify dart immediately if the activity was launched with a call
                intent.getStringExtra("incoming_call_number")?.let {
                    sendCallEvent(it)
                    intent.removeExtra("incoming_call_number")
                }
            }
            override fun onCancel(arguments: Any?) {
                callEventSink = null
            }
        })

        notificationEventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, NOTIFICATION_EVENT_CHANNEL)
        notificationEventChannel?.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink) {
                notificationEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                notificationEventSink = null
            }
        })

        SmsReceiver.onSmsReceived = { sender, body ->
            sendSmsEvent(sender, body)
        }

        ScameGoNotificationListenerService.onNotificationReceived = { notificationMap ->
            sendNotificationEvent(notificationMap)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra("incoming_call_number")?.let {
            sendCallEvent(it)
            intent.removeExtra("incoming_call_number")
        }
    }

    private fun handleMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "checkPermissions" -> {
                val permissions = checkPermissions()
                result.success(permissions)
            }
            "requestPermissions" -> {
                requestPermissions()
                result.success(null)
            }
            "requestCallScreeningRole" -> {
                requestCallScreeningRole()
                result.success(null)
            }
            "openNotificationListenerSettings" -> {
                openNotificationListenerSettings()
                result.success(null)
            }
            "isNotificationListenerEnabled" -> {
                result.success(isNotificationListenerEnabled())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun isNotificationListenerEnabled(): Boolean {
        val packageName = applicationContext.packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (flat != null && flat.contains(packageName)) {
            return true
        }
        val enabledPackages = NotificationManagerCompat.getEnabledListenerPackages(this)
        return enabledPackages.contains(packageName)
    }

    private fun checkPermissions(): Map<String, Any> {
        val perms = HashMap<String, Any>()
        perms["sms"] = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED
        perms["notification"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
        
        var isCallScreening = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            isCallScreening = roleManager.isRoleHeld(RoleManager.ROLE_CALL_SCREENING)
        }
        
        perms["isDefaultDialer"] = isCallScreening
        perms["notificationListener"] = isNotificationListenerEnabled()
        return perms
    }

    private fun requestPermissions() {
        val permissions = mutableListOf<String>()
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) != PackageManager.PERMISSION_GRANTED) {
            permissions.add(Manifest.permission.READ_SMS)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }
        if (permissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissions.toTypedArray(), 100)
        }
    }

    private fun requestCallScreeningRole() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val roleManager = getSystemService(Context.ROLE_SERVICE) as RoleManager
            if (roleManager.isRoleAvailable(RoleManager.ROLE_CALL_SCREENING)) {
                val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
                startActivityForResult(intent, 101)
            }
        }
    }

    private fun openNotificationListenerSettings() {
        try {
            val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        } catch (e: Exception) {
            // Fallback for older devices
            val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun registerSmsReceiver() {
        if (smsReceiver == null) {
            smsReceiver = SmsReceiver()
            val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
            filter.priority = 999
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(smsReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
            } else {
                registerReceiver(smsReceiver, filter)
            }
        }
    }

    private fun unregisterSmsReceiver() {
        smsReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (e: Exception) {
                // Ignore
            }
            smsReceiver = null
        }
    }

    private fun sendSmsEvent(sender: String, body: String) {
        eventSink?.let { sink ->
            CoroutineScope(Dispatchers.Main).launch {
                val event = HashMap<String, Any>()
                event["id"] = System.currentTimeMillis().toString()
                event["channel"] = "sms"
                event["timestamp"] = System.currentTimeMillis()
                event["sender"] = sender
                event["text"] = body
                event["normalized"] = body
                event["language"] = "en"
                event["verdict"] = "SCANNING"
                event["headline"] = "New SMS Received"
                event["risk"] = mapOf(
                    "score" to 0,
                    "level" to "safe",
                    "confidence" to 0.0
                )
                event["campaign"] = mapOf(
                    "campaignId" to "",
                    "riskScore" to 0,
                    "riskLevel" to "safe"
                )
                event["intervention"] = mapOf(
                    "action" to "none",
                    "title" to "",
                    "message" to ""
                )
                event["familyAlert"] = mapOf(
                    "alertSent" to false,
                    "recipient" to "",
                    "risk" to "",
                    "messagePreview" to ""
                )
                sink.success(event)
            }
        }
    }

    private fun sendNotificationEvent(notificationMap: Map<String, Any>) {
        notificationEventSink?.let { sink ->
            CoroutineScope(Dispatchers.Main).launch {
                sink.success(notificationMap)
            }
        }
    }

    private fun sendCallEvent(number: String) {
        callEventSink?.let { sink ->
            CoroutineScope(Dispatchers.Main).launch {
                sink.success(number)
            }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 100) {
            methodChannel?.invokeMethod("onPermissionsChanged", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 101) {
            if (resultCode == Activity.RESULT_OK) {
                methodChannel?.invokeMethod("onPermissionsChanged", null)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Notify Dart of permission changes when app resumes (e.g. returning from settings)
        methodChannel?.invokeMethod("onPermissionsChanged", null)
    }

    override fun onDestroy() {
        unregisterSmsReceiver()
        SmsReceiver.onSmsReceived = null
        ScameGoNotificationListenerService.onNotificationReceived = null
        super.onDestroy()
    }
}