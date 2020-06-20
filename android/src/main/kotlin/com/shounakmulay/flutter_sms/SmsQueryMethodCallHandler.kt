package com.shounakmulay.flutter_sms

import android.content.Context
import android.os.Build
import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_CONVERSATION_PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_SMS_PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.FAILED_FETCH
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED_MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.SELECTION
import com.shounakmulay.flutter_sms.utils.Constants.SELECTION_ARGS
import com.shounakmulay.flutter_sms.utils.Constants.SMS_QUERY_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.Constants.SORT_ORDER
import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import com.shounakmulay.flutter_sms.utils.enums.SmsQuery
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.RuntimeException

class SmsQueryMethodCallHandler(context: Context) : MethodChannel.MethodCallHandler, IMethodCallHandler(SMS_QUERY_REQUEST_CODE) {
  private val smsController: SmsController = SmsController(context)

  private lateinit var result: MethodChannel.Result

  private var projection: List<String>? = null
  private var selection: String? = null
  private var selectionArgs: List<String>? = null
  private var sortOrder: String? = null


  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    this.result = result

    projection = call.argument(PROJECTION)
    selection = call.argument(SELECTION)
    selectionArgs = call.argument(SELECTION_ARGS)
    sortOrder = call.argument(SORT_ORDER)

    when (SmsQuery.fromMethod(call.method)) {
      SmsQuery.GET_INBOX -> handleMethod(ContentUri.INBOX)
      SmsQuery.GET_SENT -> handleMethod(ContentUri.SENT)
      SmsQuery.GET_DRAFT -> handleMethod(ContentUri.DRAFT)
      SmsQuery.GET_CONVERSATIONS -> handleMethod(ContentUri.CONVERSATIONS)
      SmsQuery.NO_SUCH_METHOD -> result.notImplemented()
    }
  }

  private fun handleMethod(contentUri: ContentUri) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || checkOrRequestPermission(contentUri)) {
      returnMessagesInReturnType(contentUri)
    }
  }

  private fun returnMessagesInReturnType(contentUri: ContentUri) {
    try {
      projection = when (contentUri) {
        ContentUri.INBOX,
        ContentUri.SENT,
        ContentUri.DRAFT ->
          projection ?: DEFAULT_SMS_PROJECTION
        ContentUri.CONVERSATIONS ->
          projection ?: DEFAULT_CONVERSATION_PROJECTION
      }
      val messages = smsController.getMessages(contentUri, projection!!, selection, selectionArgs, sortOrder)
      result.success(messages)
    } catch (e: RuntimeException) {
      result.error(FAILED_FETCH, e.message, null)
    }
  }

  override fun onPermissionGranted(contentUri: ContentUri) {
    returnMessagesInReturnType(contentUri)
  }

  override fun onPermissionDenied(deniedPermissions: List<String>) {
    result.error(PERMISSION_DENIED, PERMISSION_DENIED_MESSAGE, deniedPermissions)
  }


}