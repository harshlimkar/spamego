package com.example.scamego

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.app.Notification
import android.util.Log

class ScamNotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        
        // We only care about messaging apps (SMS, WhatsApp, etc)
        // Ignoring system UI, our own app, etc.
        if (packageName == "android" || packageName == "com.android.systemui" || packageName == "com.example.scamego") {
            return
        }

        val extras = sbn.notification.extras
        val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
        val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""

        if (text.isNotBlank()) {
            Log.d("ScameGo", "Intercepted Notification from $packageName | Title: $title | Text: $text")
            
            // Pass the intercepted text directly to our engine!
            val dbHelper = DatabaseHelper(this)
            
            // For the hackathon demo, if the title contains letters (like a saved contact name), 
            // SmsManager might fail to reply. We assume the title is a raw phone number.
            processRealSms(this, dbHelper, title, text)
        }
    }
}
