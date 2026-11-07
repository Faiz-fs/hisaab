package com.zynapse.hisaab

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/**
 * Forwards incoming SMS to Flutter (EventChannel "hisaab/sms") while the app is
 * running. When the app is closed nothing is lost: it rescans the last days of
 * SMS on launch and resume. Message bodies are never logged.
 */
class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isNullOrEmpty()) return

        // Multi-part SMS arrive as several PDUs from the same sender: join them.
        val sender = messages[0].displayOriginatingAddress ?: return
        val body = messages.joinToString("") { it.messageBody ?: "" }
        HisaabSmsPlugin.push(sender, body, messages[0].timestampMillis)
    }
}
