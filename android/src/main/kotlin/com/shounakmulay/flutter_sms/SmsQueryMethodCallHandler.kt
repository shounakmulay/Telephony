package com.shounakmulay.flutter_sms

import android.content.Context
import android.os.Build
import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED_MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.RETURN_TYPE
import com.shounakmulay.flutter_sms.utils.Constants.SMS_QUERY_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import com.shounakmulay.flutter_sms.utils.enums.ReturnType
import com.shounakmulay.flutter_sms.utils.enums.SmsQuery
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray

class SmsQueryMethodCallHandler(context: Context) : MethodChannel.MethodCallHandler, IMethodCallHandler(SMS_QUERY_REQUEST_CODE) {
  private val smsController: SmsController = SmsController(context)
  private lateinit var returnType: ReturnType
  private lateinit var result: MethodChannel.Result
  private lateinit var projection: List<String>


  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    returnType = ReturnType.fromString(call.argument(RETURN_TYPE))
    projection = call.argument<List<String>>(PROJECTION) ?: DEFAULT_PROJECTION
    this.result = result

    when (SmsQuery.fromMethod(call.method)) {
      SmsQuery.GET_INBOX -> handleMethod(ContentUri.INBOX)
      SmsQuery.GET_SENT -> handleMethod(ContentUri.SENT)
      SmsQuery.GET_DRAFT -> handleMethod(ContentUri.DRAFT)
      SmsQuery.NO_SUCH_METHOD -> result.notImplemented()
    }
  }

  private fun handleMethod(contentUri: ContentUri) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      returnMessagesInReturnType(contentUri)
      return
    }

    if (checkOrRequestPermission(contentUri)) {
      returnMessagesInReturnType(contentUri)
    }
  }

  private fun returnMessagesInReturnType(contentUri: ContentUri) {
    val messages = smsController.getMessages(contentUri, projection)
    if (returnType == ReturnType.JSON) {
      result.success(JSONArray(messages).toString())
      return
    }
    result.success(messages[0])
  }

  override fun onPermissionGranted(contentUri: ContentUri) {
    returnMessagesInReturnType(contentUri)
  }

  override fun onPermissionDenied(deniedPermissions: List<String>) {
    result.error(PERMISSION_DENIED, PERMISSION_DENIED_MESSAGE, deniedPermissions)
  }


}