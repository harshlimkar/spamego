package com.example.scamego

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log

class SmsReceiver : BroadcastReceiver() {

    companion object {
        var onSmsReceived: ((String, String) -> Unit)? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            try {
                val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
                if (messages.isEmpty()) return

                val sender = messages[0].originatingAddress ?: "Unknown"
                val fullBody = StringBuilder()
                for (sms in messages) {
                    fullBody.append(sms.messageBody ?: "")
                }

                val body = fullBody.toString()
                Log.d("ScameGo", "Received SMS from $sender: $body")

                onSmsReceived?.invoke(sender, body)
            } catch (e: Exception) {
                Log.e("ScameGo", "Error processing SMS", e)
            }
        }
    }
}