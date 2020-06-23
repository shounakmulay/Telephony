package com.shounakmulay.flutter_sms

import android.content.Context
import androidx.annotation.NonNull;
import com.shounakmulay.flutter_sms.sms.*
import com.shounakmulay.flutter_sms.utils.Constants.CHANNEL_QUERY_SMS
import com.shounakmulay.flutter_sms.utils.Constants.CHANNEL_RECEIVE_SMS_STREAM
import com.shounakmulay.flutter_sms.utils.Constants.CHANNEL_SEND_SMS
import com.shounakmulay.flutter_sms.utils.Constants.CHANNEL_SEND_SMS_STREAM

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar


class FlutterSmsPlugin : FlutterPlugin, ActivityAware {

  private lateinit var smsQueryChannel: MethodChannel
  private lateinit var smsSendChannel: MethodChannel
  private lateinit var smsSendEventChannel: EventChannel
  private lateinit var smsReceiveEventChannel: EventChannel
  
  private lateinit var smsQueryMethodCallHandler: SmsQueryMethodCallHandler
  private lateinit var smsSendMethodCallHandler: SmsSendMethodCallHandler
  private lateinit var smsSendStreamHandler: SmsSendStreamHandler
  private lateinit var smsReceiveStreamHandler: SmsReceiveStreamHandler
  
  private lateinit var smsController: SmsController
  
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    setupPlugin(flutterPluginBinding.applicationContext, flutterPluginBinding.binaryMessenger)
  }

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      FlutterSmsPlugin().setupPlugin(registrar.activeContext(), registrar.messenger())
    }
  }

  private fun setupPlugin(context: Context, messenger: BinaryMessenger) {
    smsController = SmsController(context)
    smsQueryMethodCallHandler = SmsQueryMethodCallHandler(smsController)
    smsSendMethodCallHandler = SmsSendMethodCallHandler(smsController)
    smsSendStreamHandler = SmsSendStreamHandler(context)
    smsReceiveStreamHandler = SmsReceiveStreamHandler(context)

    smsQueryChannel = MethodChannel(messenger, CHANNEL_QUERY_SMS)
    smsQueryChannel.setMethodCallHandler(smsQueryMethodCallHandler)

    smsSendEventChannel = EventChannel(messenger, CHANNEL_SEND_SMS_STREAM)
    smsSendEventChannel.setStreamHandler(smsSendStreamHandler)
    
    smsSendChannel = MethodChannel(messenger, CHANNEL_SEND_SMS)
    smsSendChannel.setMethodCallHandler(smsSendMethodCallHandler)

    smsReceiveEventChannel = EventChannel(messenger, CHANNEL_RECEIVE_SMS_STREAM)
    smsReceiveEventChannel.setStreamHandler(smsReceiveStreamHandler)
    
  }

  private fun tearDownPlugin() {
    smsQueryChannel.setMethodCallHandler(null)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    tearDownPlugin()
  }

  override fun onDetachedFromActivity() {
    tearDownPlugin()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    PermissionsController.setActivity(binding.activity)
    binding.addRequestPermissionsResultListener(smsQueryMethodCallHandler)
    binding.addRequestPermissionsResultListener(smsSendMethodCallHandler)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
}
