package com.shounakmulay.flutter_sms.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel

class SmsReceiveStreamHandler: EventChannel.StreamHandler, BroadcastReceiver() {

  private lateinit var sink: EventChannel.EventSink

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    if (events != null) {
      sink = events
    }
  }

  override fun onCancel(arguments: Any?) {

  }

  override fun onReceive(context: Context?, intent: Intent?) {
    TODO()
  }

}
