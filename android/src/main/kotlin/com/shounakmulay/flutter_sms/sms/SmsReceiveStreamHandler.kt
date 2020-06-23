package com.shounakmulay.flutter_sms.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage
import com.shounakmulay.flutter_sms.utils.Constants.MESSAGE_BODY
import com.shounakmulay.flutter_sms.utils.Constants.ORIGINATING_ADDRESS
import com.shounakmulay.flutter_sms.utils.Constants.SMS_RECEIVE_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.Constants.STATUS
import com.shounakmulay.flutter_sms.utils.Constants.TIMESTAMP
import io.flutter.plugin.common.EventChannel

private var sink: EventChannel.EventSink? = null

class SmsReceiveStreamHandler(context: Context?) : BaseStreamHandler() {

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (events != null) {
      sink = events
    }
    checkOrRequestPermission(SMS_RECEIVE_REQUEST_CODE)
  }

  override fun onCancel(arguments: Any?) {
    sink = null
  }
}

class SmsReceiveBroadcastReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context?, intent: Intent?) {
    val smsList = Telephony.Sms.Intents.getMessagesFromIntent(intent)
    smsList.forEach { sms ->
      sink?.success(sms.toMap())
    }
  }
}

private fun SmsMessage.toMap(): HashMap<String, Any?> {
  val smsMap = HashMap<String, Any?>()
  this.apply {
    smsMap[MESSAGE_BODY] = messageBody
    smsMap[TIMESTAMP] = timestampMillis
    smsMap[ORIGINATING_ADDRESS] = originatingAddress
    smsMap[STATUS] = status
  }
  return smsMap
}
