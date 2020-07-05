package com.shounakmulay.flutter_sms.sms

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import com.shounakmulay.flutter_sms.PermissionsController
import com.shounakmulay.flutter_sms.utils.ActionType
import com.shounakmulay.flutter_sms.utils.Constants
import com.shounakmulay.flutter_sms.utils.Constants.ADDRESS
import com.shounakmulay.flutter_sms.utils.Constants.BACKGROUND_HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_CONVERSATION_PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_SMS_PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.FAILED_FETCH
import com.shounakmulay.flutter_sms.utils.Constants.ILLEGAL_ARGUMENT
import com.shounakmulay.flutter_sms.utils.Constants.LISTEN_STATUS
import com.shounakmulay.flutter_sms.utils.Constants.MESSAGE_BODY
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_DENIED_MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.PROJECTION
import com.shounakmulay.flutter_sms.utils.Constants.SELECTION
import com.shounakmulay.flutter_sms.utils.Constants.SELECTION_ARGS
import com.shounakmulay.flutter_sms.utils.Constants.SETUP_HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.SMS_BACKGROUND_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.Constants.SMS_DELIVERED
import com.shounakmulay.flutter_sms.utils.Constants.SMS_QUERY_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.Constants.SMS_SEND_REQUEST_CODE
import com.shounakmulay.flutter_sms.utils.Constants.SMS_SENT
import com.shounakmulay.flutter_sms.utils.Constants.SORT_ORDER
import com.shounakmulay.flutter_sms.utils.Constants.WRONG_METHOD_TYPE
import com.shounakmulay.flutter_sms.utils.ContentUri
import com.shounakmulay.flutter_sms.utils.SmsAction
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class SmsMethodCallHandler(private val context: Context, private val smsController: SmsController)
  : PluginRegistry.RequestPermissionsResultListener, MethodChannel.MethodCallHandler, BroadcastReceiver() {

  private lateinit var result: MethodChannel.Result
  private lateinit var action: SmsAction
  private lateinit var foregroundChannel: MethodChannel

  private var projection: List<String>? = null
  private var selection: String? = null
  private var selectionArgs: List<String>? = null
  private var sortOrder: String? = null

  private lateinit var messageBody: String
  private lateinit var address: String
  private var listenStatus: Boolean = false

  private var setupHandle: Long = -1
  private var backgroundHandle: Long = -1

  private var requestCode: Int = -1

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    this.result = result

    action = SmsAction.fromMethod(call.method)

    if (action == SmsAction.NO_SUCH_METHOD) {
      result.notImplemented()
      return
    }

    when (action.toActionType()) {
      ActionType.GET -> {
        projection = call.argument(PROJECTION)
        selection = call.argument(SELECTION)
        selectionArgs = call.argument(SELECTION_ARGS)
        sortOrder = call.argument(SORT_ORDER)

        handleMethod(action, SMS_QUERY_REQUEST_CODE)
      }
      ActionType.SEND -> {
        if (call.hasArgument(MESSAGE_BODY)
            && call.hasArgument(ADDRESS)) {
          val messageBody = call.argument<String>(MESSAGE_BODY)
          val address = call.argument<String>(ADDRESS)
          if (messageBody.isNullOrBlank() || address.isNullOrBlank()) {
            result.error(ILLEGAL_ARGUMENT, Constants.MESSAGE_OR_ADDRESS_CANNOT_BE_NULL, null)
            return
          }

          this.messageBody = messageBody
          this.address = address

          listenStatus = call.argument(LISTEN_STATUS) ?: false
        }
        handleMethod(action, SMS_SEND_REQUEST_CODE)
      }
      ActionType.BACKGROUND -> {
        if (call.hasArgument(SETUP_HANDLE)
            && call.hasArgument(BACKGROUND_HANDLE)) {
          val setupHandle = call.argument<Long>(SETUP_HANDLE)
          val backgroundHandle = call.argument<Long>(BACKGROUND_HANDLE)
          if (setupHandle == null || backgroundHandle == null) {
            result.error(ILLEGAL_ARGUMENT, "Setuphandle or background handle missing", null)
            return
          }

          this.setupHandle = setupHandle
          this.backgroundHandle = backgroundHandle
        }
        handleMethod(action, SMS_BACKGROUND_REQUEST_CODE)
      }
    }
  }

  /**
   * Called by [handleMethod] after checking the permissions.
   *
   * #####
   *
   * If permission was not previously granted, [handleMethod] will request the user for permission
   *
   * Once user grants the permission this method will be executed.
   *
   * #####
   */
  private fun execute(smsAction: SmsAction) {
    try {
      when (action.toActionType()) {
        ActionType.GET -> {
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
        ActionType.SEND -> {
          if (listenStatus) {
            val intentFilter = IntentFilter().apply {
              addAction(Constants.ACTION_SMS_SENT)
              addAction(Constants.ACTION_SMS_DELIVERED)
            }
            context.applicationContext.registerReceiver(this, intentFilter)
          }
          when (smsAction) {
            SmsAction.SEND_SMS -> smsController.sendSms(address, messageBody, listenStatus)
            SmsAction.SEND_MULTIPART_SMS -> smsController.sendMultipartSms(address, messageBody, listenStatus)
            SmsAction.SEND_SMS_INTENT -> smsController.sendSmsIntent(address, messageBody)
            else -> throw IllegalArgumentException()
          }
        }
        ActionType.BACKGROUND -> {
          when (smsAction) {
            SmsAction.START_BACKGROUND_SERVICE -> {
              IncomingSmsHandler.setBackgroundSetupHandle(context, setupHandle)
              IncomingSmsHandler.setBackgroundMessageHandle(context, backgroundHandle)
            }
            SmsAction.BACKGROUND_SERVICE_INITIALIZED -> {
              IncomingSmsHandler.onInitialized()
            }
            else -> throw IllegalArgumentException()
          }
        }
      }
    } catch (e: IllegalArgumentException) {
      result.error(ILLEGAL_ARGUMENT, WRONG_METHOD_TYPE, null)
    } catch (e: RuntimeException) {
      result.error(FAILED_FETCH, e.message, null)
    }
  }


  /**
   * Calls the [execute] method after checking if the necessary permissions are granted.
   *
   * If not granted then it will request the permission from the user.
   */
  private fun handleMethod(smsAction: SmsAction, requestCode: Int) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || checkOrRequestPermission(smsAction, requestCode)) {
      execute(smsAction)
    }
  }

  /* no-op */
  private fun noop() {}

  /**
   * Check and request if necessary for all the SMS permissions listed in the manifest
   */
  @RequiresApi(Build.VERSION_CODES.M)
  fun checkOrRequestPermission(smsAction: SmsAction, requestCode: Int): Boolean {
    this.action = smsAction
    this.requestCode = requestCode
    when (smsAction) {
      SmsAction.GET_INBOX,
      SmsAction.GET_SENT,
      SmsAction.GET_DRAFT,
      SmsAction.GET_CONVERSATIONS,
      SmsAction.SEND_SMS,
      SmsAction.SEND_MULTIPART_SMS,
      SmsAction.SEND_SMS_INTENT,
      SmsAction.START_BACKGROUND_SERVICE,
      SmsAction.BACKGROUND_SERVICE_INITIALIZED -> {
        val permissions = PermissionsController.getSmsPermissions()
        return checkOrRequestPermission(permissions, requestCode)
      }
      SmsAction.NO_SUCH_METHOD -> noop()
    }
    return false
  }

  @RequiresApi(Build.VERSION_CODES.M)
  private fun checkOrRequestPermission(permissions: List<String>, requestCode: Int): Boolean {
    PermissionsController.apply {
      if (!hasRequiredPermissions(permissions)) {
        requestPermissions(permissions, requestCode)
        return false
      }
      return true
    }
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {

    PermissionsController.isRequestingPermission = false

    val deniedPermissions = mutableListOf<String>()
    if (requestCode != this.requestCode && !this::action.isInitialized) {
      return false
    }

    val allPermissionGranted = grantResults?.foldIndexed(true) { i, acc, result ->
      if (result == PackageManager.PERMISSION_DENIED) {
        permissions?.let { deniedPermissions.add(it[i]) }
      }
      return@foldIndexed acc && result == PackageManager.PERMISSION_GRANTED
    } ?: false

    return if (allPermissionGranted) {
      execute(action)
      true
    } else {
      onPermissionDenied(deniedPermissions)
      false
    }
  }

  private fun onPermissionDenied(deniedPermissions: List<String>) {
    result.error(PERMISSION_DENIED, PERMISSION_DENIED_MESSAGE, deniedPermissions)
  }

  fun setForegroundChannel(channel: MethodChannel) {
    foregroundChannel = channel
  }

  override fun onReceive(ctx: Context?, intent: Intent?) {
    if (intent != null) {
      when (intent.action) {
        Constants.ACTION_SMS_SENT -> foregroundChannel.invokeMethod(SMS_SENT, null)
        Constants.ACTION_SMS_DELIVERED -> {
          foregroundChannel.invokeMethod(SMS_DELIVERED, null)
          context.unregisterReceiver(this)
        }
      }
    }
  }
}
