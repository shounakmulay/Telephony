package com.shounakmulay.flutter_sms

import android.content.Context
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

private const val CHANNEL_QUERY_SMS = "plugins.shounakmulay.com/querySMS"
private const val CHANNEL_SEND_SMS = "plugins.shounakmulay.com/sendSMS"

class FlutterSmsPlugin : FlutterPlugin, ActivityAware {

  private lateinit var smsQueryChannel: MethodChannel
  private lateinit var smsSendChannel: MethodChannel
  private lateinit var smsQueryMethodCallHandler: SmsQueryMethodCallHandler
  private lateinit var smsSendMethodCallHandler: SmsSendMethodCallHandler

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
    smsQueryMethodCallHandler = SmsQueryMethodCallHandler(context)
    smsSendMethodCallHandler = SmsSendMethodCallHandler(context)

    smsQueryChannel = MethodChannel(messenger, CHANNEL_QUERY_SMS)
    smsQueryChannel.setMethodCallHandler(smsQueryMethodCallHandler)
    
    smsSendChannel = MethodChannel(messenger, CHANNEL_SEND_SMS)
    smsSendChannel.setMethodCallHandler(smsSendMethodCallHandler)
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
    smsQueryMethodCallHandler.setActivity(binding.activity)
    binding.addRequestPermissionsResultListener(smsQueryMethodCallHandler)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }
}
