package com.example.scamego

import android.content.Intent
import android.os.Build
import android.telecom.Call
import android.telecom.CallScreeningService
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.N)
class CallScreeningServiceImpl : CallScreeningService() {

    override fun onScreenCall(callDetails: Call.Details) {
        val phoneNumber = getPhoneNumber(callDetails)
        
        // Launch Flutter MainActivity to show custom Incoming Call UI
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("incoming_call_number", phoneNumber)
        }
        startActivity(intent)

        // Allow the call to ring on the system side (do not block by default)
        val response = CallResponse.Builder()
            .setDisallowCall(false)
            .setRejectCall(false)
            .setSkipCallLog(false)
            .setSkipNotification(false)
            .build()
        
        respondToCall(callDetails, response)
    }

    private fun getPhoneNumber(callDetails: Call.Details): String {
        val handle = callDetails.handle
        return if (handle != null && handle.scheme == "tel") {
            handle.schemeSpecificPart
        } else {
            "Unknown"
        }
    }
}
