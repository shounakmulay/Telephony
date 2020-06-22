package com.shounakmulay.flutter_sms.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import com.shounakmulay.flutter_sms.utils.Constants.ACTION_SMS_DELIVERED
import com.shounakmulay.flutter_sms.utils.Constants.ACTION_SMS_SENT
import com.shounakmulay.flutter_sms.utils.Constants.SMS_DELIVERED
import com.shounakmulay.flutter_sms.utils.Constants.SMS_SENT
import io.flutter.plugin.common.EventChannel

class SmsSendStreamHandler(private val context: Context): EventChannel.StreamHandler, BroadcastReceiver() {

  private lateinit var sink: EventChannel.EventSink

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (events != null) {
      sink = events
    }
    val intentFilter = IntentFilter().apply {
      addAction(ACTION_SMS_SENT)
      addAction(ACTION_SMS_DELIVERED)
    }
    context.applicationContext.registerReceiver(this, intentFilter)
  }

  override fun onCancel(arguments: Any?) {
    context.unregisterReceiver(this)
  }

  override fun onReceive(ctx: Context?, intent: Intent?) {
    if (intent != null) {
      when (intent.action) {
        ACTION_SMS_SENT -> sink.success(SMS_SENT)
        ACTION_SMS_DELIVERED -> {
          sink.success(SMS_DELIVERED)
          sink.endOfStream()
        }
      }
    }
  }
}

