package com.shounakmulay.flutter_sms.sms

import com.shounakmulay.flutter_sms.BaseMethodCallHandler
import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_CONVERSATION_PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_SMS_PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.FAILED_FETCH
import com.shounakmulay.flutter_sms.utils.Constants.ILLEGAL_ARGUMENT
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED_MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.SELECTION
import com.shounakmulay.flutter_sms.utils.Constants.SELECTION_ARGS
import com.shounakmulay.flutter_sms.utils.Constants.SMS_QUERY_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.Constants.SORT_ORDER
import com.shounakmulay.flutter_sms.utils.Constants.WRONG_METHOD_TYPE
import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import com.shounakmulay.flutter_sms.utils.enums.SmsAction
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.IllegalArgumentException
import java.lang.RuntimeException

class SmsQueryMethodCallHandler(private val smsController: SmsController)
  : BaseMethodCallHandler(SMS_QUERY_REQUEST_CODE), BaseMethodCallHandler.OnPermissionDeniedListener {

  private lateinit var result: MethodChannel.Result

  private var projection: List<String>? = null
  private var selection: String? = null
  private var selectionArgs: List<String>? = null
  private var sortOrder: String? = null

  init {
    setOnPermissionDeniedListener(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    this.result = result

    projection = call.argument(PROJECTION)
    selection = call.argument(SELECTION)
    selectionArgs = call.argument(SELECTION_ARGS)
    sortOrder = call.argument(SORT_ORDER)

    val action = SmsAction.fromMethod(call.method)

    if (action == SmsAction.NO_SUCH_METHOD) {
      result.notImplemented()
    } else {
      handleMethod(action)
    }
  }

  override fun execute(smsAction: SmsAction) {
    try {
      returnMessagesInReturnType(smsAction)
    } catch (e: IllegalArgumentException) {
      result.error(ILLEGAL_ARGUMENT, WRONG_METHOD_TYPE, null)
    } catch (e: RuntimeException) {
      result.error(FAILED_FETCH, e.message, null)
    }
  }

  @Throws(RuntimeException::class, IllegalArgumentException::class)
  private fun returnMessagesInReturnType(smsAction: SmsAction) {
    if (projection == null) {
      projection = if (smsAction == SmsAction.GET_CONVERSATIONS) DEFAULT_CONVERSATION_PROJECTION else DEFAULT_SMS_PROJECTION
    }
    val contentUri = when (smsAction) {
      SmsAction.GET_INBOX -> ContentUri.INBOX
      SmsAction.GET_SENT -> ContentUri.SENT
      SmsAction.GET_DRAFT -> ContentUri.DRAFT
      SmsAction.GET_CONVERSATIONS -> ContentUri.CONVERSATIONS
      else -> throw IllegalArgumentException()
    }
    val messages = smsController.getMessages(contentUri, projection!!, selection, selectionArgs, sortOrder)
    result.success(messages)
  }

  override fun onPermissionDenied(deniedPermissions: List<String>) {
    result.error(PERMISSION_DENIED, PERMISSION_DENIED_MESSAGE, deniedPermissions)
  }


}