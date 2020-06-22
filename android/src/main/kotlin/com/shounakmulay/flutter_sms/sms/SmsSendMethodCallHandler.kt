package com.shounakmulay.flutter_sms.sms

import com.shounakmulay.flutter_sms.BaseMethodCallHandler
import com.shounakmulay.flutter_sms.utils.Constants
import com.shounakmulay.flutter_sms.utils.Constants.ADDRESS
import com.shounakmulay.flutter_sms.utils.Constants.FAILED_FETCH
import com.shounakmulay.flutter_sms.utils.Constants.ILLEGAL_ARGUMENT
import com.shounakmulay.flutter_sms.utils.Constants.LISTEN_STATUS
import com.shounakmulay.flutter_sms.utils.Constants.MESSAGE_BODY
import com.shounakmulay.flutter_sms.utils.Constants.MESSAGE_OR_ADDRESS_CANNOT_BE_NULL
import com.shounakmulay.flutter_sms.utils.Constants.SMS_SEND_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.Constants.WRONG_METHOD_TYPE
import com.shounakmulay.flutter_sms.utils.enums.SmsAction
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.IllegalArgumentException
import java.lang.RuntimeException

class SmsSendMethodCallHandler(private val smsController: SmsController)
  : MethodChannel.MethodCallHandler, BaseMethodCallHandler.OnPermissionDeniedListener, BaseMethodCallHandler(SMS_SEND_REQUEST_CODE) {
  
  private lateinit var result: MethodChannel.Result

  private lateinit var messageBody: String
  private lateinit var address: String
  private var listenStatus: Boolean = false

  init {
    setOnPermissionDeniedListener(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {

    this.result = result
   
    if (call.hasArgument(MESSAGE_BODY) 
        && call.hasArgument(ADDRESS)) {
      val messageBody = call.argument<String>(MESSAGE_BODY)
      val address = call.argument<String>(ADDRESS)
      if (messageBody.isNullOrBlank() || address.isNullOrBlank()) {
        result.error(ILLEGAL_ARGUMENT, MESSAGE_OR_ADDRESS_CANNOT_BE_NULL, null)
        return
      }
      
      this.messageBody = messageBody
      this.address = address
      
    }
    
    listenStatus = call.argument(LISTEN_STATUS) ?: false

    val action = SmsAction.fromMethod(call.method)

    if (action == SmsAction.NO_SUCH_METHOD) {
      result.notImplemented()
      return
    }
    handleMethod(action)

  }

  override fun execute(smsAction: SmsAction) {
    try {
      when (smsAction) {
        SmsAction.SEND_SMS -> smsController.sendSms(address, messageBody, listenStatus)
        SmsAction.SEND_MULTIPART_SMS -> smsController.sendMultipartSms(address, messageBody, listenStatus)
        SmsAction.SEND_SMS_INTENT -> smsController.sendSmsIntent(address, messageBody)
        else -> throw IllegalArgumentException()
      }
    } catch (e: IllegalArgumentException) {
      result.error(ILLEGAL_ARGUMENT, WRONG_METHOD_TYPE, null)
    } catch (e: RuntimeException) {
      result.error(FAILED_FETCH, e.message, null)
    }
  }

  override fun onPermissionDenied(deniedPermissions: List<String>) {
    result.error(Constants.PERMISSION_DENIED, Constants.PERMISSION_DENIED_MESSAGE, deniedPermissions)
  }


}
