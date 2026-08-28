package com.example.scamego

import android.app.Notification
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import java.util.HashMap

/**
 * Native Android NotificationListenerService for ScameGo.
 * Safely extracts notification content from supported apps (Messaging, Banking, Social, SMS)
 * and forwards events to Flutter via EventChannel.
 */
class ScameGoNotificationListenerService : NotificationListenerService() {

    companion object {
        private const val TAG = "ScameGoNotifListener"

        // Thread-safe callback for forwarding notifications to MainActivity -> Flutter
        var onNotificationReceived: ((Map<String, Any>) -> Unit)? = null
        var isServiceConnected: Boolean = false
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        isServiceConnected = true
        Log.d(TAG, "ScameGo Notification Listener Service Connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        isServiceConnected = false
        Log.d(TAG, "ScameGo Notification Listener Service Disconnected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        super.onNotificationPosted(sbn)

        if (sbn == null) return

        try {
            val packageName = sbn.packageName ?: return

            // Ignore our own notifications to avoid recursion
            if (packageName == applicationContext.packageName) {
                return
            }

            val notification = sbn.notification ?: return
            val extras = notification.extras ?: Bundle()

            // Safe extraction of title, text, subtext, and big text
            val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""
            var text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
            val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""
            val subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString() ?: ""
            val infoText = extras.getCharSequence(Notification.EXTRA_INFO_TEXT)?.toString() ?: ""

            // Prefer big text if available and longer
            if (bigText.isNotEmpty() && bigText.length > text.length) {
                text = bigText
            }

            // If text is still empty, try summary or subtext
            if (text.isEmpty() && subText.isNotEmpty()) {
                text = subText
            }

            // Ignore completely empty notifications
            if (title.isEmpty() && text.isEmpty()) {
                return
            }

            // Get package manager to extract app label
            val pm = applicationContext.packageManager
            val appName = try {
                val appInfo = pm.getApplicationInfo(packageName, 0)
                pm.getApplicationLabel(appInfo).toString()
            } catch (e: Exception) {
                packageName
            }

            val timestamp = sbn.postTime

            val event = HashMap<String, Any>()
            event["id"] = "notif_${sbn.id}_$timestamp"
            event["packageName"] = packageName
            event["appName"] = appName
            event["title"] = title
            event["text"] = text
            event["subText"] = subText
            event["infoText"] = infoText
            event["timestamp"] = timestamp
            event["isOngoing"] = sbn.isOngoing
            event["isClearable"] = sbn.isClearable

            Log.d(TAG, "Notification intercepted: $appName ($packageName): $title - $text")

            // Send to Flutter
            onNotificationReceived?.invoke(event)

        } catch (e: Exception) {
            Log.e(TAG, "Error parsing notification: ${e.message}", e)
        }
    }
}
