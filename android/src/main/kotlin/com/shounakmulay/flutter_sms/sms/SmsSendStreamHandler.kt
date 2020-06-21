package com.shounakmulay.flutter_sms.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import com.shounakmulay.flutter_sms.utils.Constants.ACTION_SMS_DELIVERED
import com.shounakmulay.flutter_sms.utils.Constants.ACTION_SMS_SENT
import io.flutter.plugin.common.EventChannel

class SmsSendStreamHandler(private val context: Context): EventChannel.StreamHandler, BroadcastReceiver() {

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    registerBroadcastReceiver()
  }

  override fun onCancel(arguments: Any?) {
    context.unregisterReceiver(this)
  }

  private fun registerBroadcastReceiver() {
    val intentFilter = IntentFilter().apply { 
      addAction(ACTION_SMS_SENT)
      addAction(ACTION_SMS_DELIVERED)
    }
    context.registerReceiver(this, intentFilter)
  }

  override fun onReceive(context: Context?, intent: Intent?) {
    TODO()
  }

}
