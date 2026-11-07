package com.zynapse.hisaab

import android.Manifest
import android.content.pm.PackageManager
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** Holds the live-SMS sink so [SmsReceiver] can push messages to Flutter. */
object HisaabSmsPlugin {
    @Volatile
    var eventSink: EventChannel.EventSink? = null
    private val main = Handler(Looper.getMainLooper())

    fun push(sender: String, body: String, timestamp: Long) {
        val sink = eventSink ?: return // App not running: the launch/resume rescan picks it up.
        main.post {
            sink.success(
                mapOf("sender" to sender, "body" to body, "timestamp" to timestamp)
            )
        }
    }
}

class MainActivity : FlutterActivity() {

    private val smsBackfillChannel = "hisaab/sms_backfill"
    private val smsLiveChannel = "hisaab/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, smsLiveChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    HisaabSmsPlugin.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    HisaabSmsPlugin.eventSink = null
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smsBackfillChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readRecentSms" -> {
                        if (ContextCompat.checkSelfPermission(
                                this, Manifest.permission.READ_SMS
                            ) != PackageManager.PERMISSION_GRANTED
                        ) {
                            result.error(
                                "SMS_PERMISSION_DENIED",
                                "READ_SMS permission has not been granted",
                                null
                            )
                        } else {
                            val days = (call.argument<Int>("days") ?: 15).coerceIn(1, 365)
                            try {
                                result.success(readRecentSms(days))
                            } catch (e: Exception) {
                                result.error("SMS_READ_FAILED", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun readRecentSms(days: Int): List<Map<String, Any>> {
        val cutoff = System.currentTimeMillis() - days.toLong() * 24 * 60 * 60 * 1000
        val messages = mutableListOf<Map<String, Any>>()

        val projection = arrayOf(
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE
        )

        contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            projection,
            "${Telephony.Sms.DATE} >= ?",
            arrayOf(cutoff.toString()),
            "${Telephony.Sms.DATE} DESC"
        )?.use { cursor ->
            val addressIndex = cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
            val bodyIndex = cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)
            val dateIndex = cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)

            while (cursor.moveToNext()) {
                messages.add(
                    mapOf(
                        "sender" to (cursor.getString(addressIndex) ?: ""),
                        "body" to (cursor.getString(bodyIndex) ?: ""),
                        "timestamp" to cursor.getLong(dateIndex)
                    )
                )
            }
        }
        return messages
    }
}
