package com.shounakmulay.flutter_sms

import android.content.Context
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar

private const val CHANNEL_QUERY_SMS = "plugins.shounakmulay.com/querySMS"

class FlutterSmsPlugin : FlutterPlugin {

  private lateinit var smsQueryChannel: MethodChannel
  private lateinit var smsQueryMethodCallHandler: SmsQueryMethodCallHandler
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

    smsQueryChannel = MethodChannel(messenger, CHANNEL_QUERY_SMS)
    smsQueryChannel.setMethodCallHandler(smsQueryMethodCallHandler)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    smsQueryChannel.setMethodCallHandler(null)
  }
}
