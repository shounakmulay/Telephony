package com.shounakmulay.flutter_sms

import android.content.Context
import com.shounakmulay.flutter_sms.enums.SmsQuery
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SmsQueryMethodCallHandler(private val smsController: SmsController) : MethodChannel.MethodCallHandler {
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (SmsQuery.fromMethod(call.method)) {
      SmsQuery.GET_INBOX -> result.success(smsController.getInbox())
      SmsQuery.GET_SENT -> result.success(smsController.getSent())
      SmsQuery.GET_DRAFT -> result.success(smsController.getDraft())
      SmsQuery.NO_SUCH_METHOD -> result.notImplemented()
    }
  }
}