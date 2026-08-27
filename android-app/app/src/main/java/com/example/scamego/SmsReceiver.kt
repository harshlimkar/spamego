package com.example.scamego

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.util.Log
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.os.Build
import androidx.core.app.NotificationCompat

class SmsReceiver : BroadcastReceiver() {

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
                
                // Process the offline risk
                val risk = analyzeOffline(body)
                
                if (risk.score >= 50) {
                    Log.d("ScameGo", "Scam Detected: ${risk.level} - Score: ${risk.score}")
                    
                    // Store in local DB
                    val db = DatabaseHelper(context)
                    db.logScam(sender, body, risk.score, risk.level)
                    
                    // Show notification
                    showNotification(context, sender, risk.level)
                }
            } catch (e: Exception) {
                Log.e("ScameGo", "Error processing SMS", e)
            }
        }
    }
    
    data class RiskResult(val score: Int, val level: String)
    
    private fun analyzeOffline(text: String): RiskResult {
        var score = 0
        val t = text.lowercase()
        
        // Lightweight Python port of KeywordEngine & RuleEngine
        if (t.contains("otp")) score += 25
        if (t.contains("kyc")) score += 15
        if (t.contains("pan")) score += 10
        if (t.contains("block")) score += 20
        if (t.contains("urgent") || t.contains("immediately") || t.contains("udane")) score += 10
        if (t.contains("prize") || t.contains("lottery")) score += 40
        if (t.contains("click") || t.contains("http") || t.contains(".com")) score += 20
        
        // Base score for unknown number (simplified)
        score += 10 
        
        if (t.contains("kyc") && t.contains("block")) score += 30 // Rule combination
        if (t.contains("otp") && (t.contains("urgent") || t.contains("immediately"))) score += 30
        
        val finalScore = score.coerceAtMost(100)
        
        val level = when {
            finalScore >= 85 -> "CRITICAL"
            finalScore >= 70 -> "HIGH"
            finalScore >= 50 -> "MEDIUM"
            finalScore >= 30 -> "LOW"
            else -> "SAFE"
        }
        
        return RiskResult(finalScore, level)
    }
    
    private fun showNotification(context: Context, sender: String, riskLevel: String) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "scamego_alerts"
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "Scam Alerts", NotificationManager.IMPORTANCE_HIGH)
            manager.createNotificationChannel(channel)
        }
        
        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE)
        
        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setContentTitle("ScameGo: $riskLevel Scam Detected!")
            .setContentText("Suspicious SMS intercepted from $sender")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            
        manager.notify(System.currentTimeMillis().toInt(), builder.build())
    }
}
