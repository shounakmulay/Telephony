package com.shounakmulay.flutter_sms

import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import com.shounakmulay.flutter_sms.sms.BaseHandler
import com.shounakmulay.flutter_sms.utils.enums.SmsAction
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


abstract class BaseMethodCallHandler: PluginRegistry.RequestPermissionsResultListener, MethodChannel.MethodCallHandler, BaseHandler() {
  private lateinit var action: SmsAction
  private var requestCode: Int = -1

  private lateinit var onPermissionDeniedListener: OnPermissionDeniedListener
  private lateinit var onPermissionGrantedListener: OnPermissionGrantedListener



  interface OnPermissionGrantedListener {
    fun onPermissionGranted(action: SmsAction)
  }

  interface OnPermissionDeniedListener {
    fun onPermissionDenied(deniedPermissions: List<String>)
  }



  fun setOnPermissionDeniedListener(listener: OnPermissionDeniedListener) {
    onPermissionDeniedListener = listener
  }

  fun setOnPermissionGrantedListener(listener: OnPermissionDeniedListener) {
    onPermissionDeniedListener = listener
  }


  /**
   * Calls the [execute] method after checking if the necessary permissions are granted.
   *
   * If not granted then it will request the permission from the user.
   *
   * Implement the [OnPermissionGrantedListener] to get notified when the requested permission is granted or denied.
   *
   * @see OnPermissionGrantedListener
   * @param smsAction The [SmsAction] to be performed
   */
  fun handleMethod(smsAction: SmsAction, requestCode: Int) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || checkOrRequestPermission(smsAction, requestCode)) {
      execute(smsAction)
    }
  }

  /**
   * This function is called by [handleMethod] after checking the permissions.
   *
   * #####
   *
   * If permission was not previously granted, [handleMethod] will request the user for permission
   *
   * Once user grants the permission this method will be executed.
   *
   * #####
   *
   * To handle the execution after the permission has been granted yourself, implement the [OnPermissionGrantedListener]
   * and call this method in [OnPermissionGrantedListener.onPermissionGranted]
   *
   * #####
   */
  abstract fun execute(smsAction: SmsAction)

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
        SmsAction.SEND_SMS_INTENT -> {
          val permissions = PermissionsController.getSmsPermissions()
          return checkOrRequestPermission(permissions, requestCode)
        }
        SmsAction.NO_SUCH_METHOD -> noop()
      }
    return false
  }

  /* no-op */
  private fun noop() {}

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

    if (allPermissionGranted) {
      if (this::onPermissionGrantedListener.isInitialized) {
        onPermissionGrantedListener.onPermissionGranted(action)
      } else {
        execute(action)
      }
      return true
    }

    if (this::onPermissionDeniedListener.isInitialized) {
      onPermissionDeniedListener.onPermissionDenied(deniedPermissions)
    }
    return false
  }
}
