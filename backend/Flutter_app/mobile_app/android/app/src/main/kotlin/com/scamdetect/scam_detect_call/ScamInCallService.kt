package com.scamdetect.scam_detect_call

import android.telecom.Call
import android.telecom.InCallService
import android.util.Log

class ScamInCallService : InCallService() {
    companion object {
        private const val TAG = "ScamInCallService"
    }

    override fun onCallAdded(call: Call) {
        super.onCallAdded(call)
        Log.d(TAG, "Call added: ${call.details.handle}")
        
        call.registerCallback(object : Call.Callback() {
            override fun onStateChanged(c: Call, state: Int) {
                Log.d(TAG, "Call state changed: $state")
            }
        })
    }

    override fun onCallRemoved(call: Call) {
        super.onCallRemoved(call)
        Log.d(TAG, "Call removed")
    }
}
