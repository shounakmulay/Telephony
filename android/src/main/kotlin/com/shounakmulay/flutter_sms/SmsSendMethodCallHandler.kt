package com.shounakmulay.flutter_sms

import android.content.Context
import com.shounakmulay.flutter_sms.utils.Constants.SMS_SEND_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import com.shounakmulay.flutter_sms.utils.enums.SmsSend
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

private const val DESTINATION_ADDRESS = "destination_address"
private const val MESSAGE_BODY = "message_body"

class SmsSendMethodCallHandler(private val context: Context) : MethodChannel.MethodCallHandler, IMethodCallHandler(SMS_SEND_REQUEST_CODE) {

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (SmsSend.fromMethod(call.method)) {
//      SmsSend.SEND_SMS -> smsController.sendSms(
//        destinationAddress = call.argument(DESTINATION_ADDRESS),
//        messageBody = call.argument(MESSAGE_BODY) ?: ""
//      )
      SmsSend.NO_SUCH_METHOD -> TODO()
    }
  }

  override fun onPermissionGranted(contentUri: ContentUri) {
    TODO("Not yet implemented")
  }

  override fun onPermissionDenied(deniedPermissions: List<String>) {
    TODO("Not yet implemented")
  }


}
