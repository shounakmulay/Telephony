package com.shounakmulay.flutter_sms

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_READ_SMS
import com.shounakmulay.flutter_sms.utils.Constants.PERMISSION_SEND_SMS
import com.shounakmulay.flutter_sms.utils.enums.SmsAction
import io.flutter.plugin.common.PluginRegistry

interface OnPermissionGrantedListener {
  fun onPermissionGranted(action: SmsAction)
  fun onPermissionDenied(deniedPermissions: List<String>)
}


abstract class IMethodCallHandler(private val requestCode: Int) : PluginRegistry.RequestPermissionsResultListener, OnPermissionGrantedListener {
  private lateinit var permissionsController: PermissionsController
  private lateinit var action: SmsAction


  fun setActivity(activity: Activity) {
    permissionsController = PermissionsController(activity)
  }

  /**
   * Should check for platform version and necessary permissions before executing the method
   *
   * - Call [checkOrRequestPermission] to check if permissions are granted or request them if necessary
   *
   * - Implement [OnPermissionGrantedListener] to get the result of requested permissions
   *
   * @param smsAction Action to check permissions for
   */
  abstract fun handleMethod(smsAction: SmsAction)

  @RequiresApi(Build.VERSION_CODES.M)
  fun checkOrRequestPermission(smsAction: SmsAction): Boolean {
    if (this::permissionsController.isInitialized) {
      this.action = smsAction
      when (smsAction) {
        SmsAction.GET_INBOX,
        SmsAction.GET_SENT,
        SmsAction.GET_DRAFT,
        SmsAction.GET_CONVERSATIONS -> {
          checkOrRequestPermission(PERMISSION_READ_SMS)
        }
        SmsAction.SEND_SMS,
        SmsAction.SEND_MULTIPART_SMS,
        SmsAction.SEND_SMS_INTENT -> {
          checkOrRequestPermission(PERMISSION_SEND_SMS)
        }
        SmsAction.NO_SUCH_METHOD -> noop()
      }
    }
    return false
  }

  private fun checkOrRequestPermission(permission: String): Boolean {
    permissionsController.apply {
      if (!hasRequiredPermissions(permission)) {
        permissionsController.requestPermissions(permission, requestCode)
        return false
      }
      return true
    }
  }

  /* no-op */
  private fun noop() {}

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
    val deniedPermissions = mutableListOf<String>()
    if (requestCode != this.requestCode) {
      return false
    }
    val allPermissionGranted = grantResults?.foldIndexed(true) { i, acc, result ->
      if (result == PackageManager.PERMISSION_DENIED) {
        permissions?.let { deniedPermissions.add(it[i]) }
      }
      return@foldIndexed acc && result == PackageManager.PERMISSION_GRANTED
    } ?: false

    if (allPermissionGranted) {
      onPermissionGranted(action)
      return true
    }

    onPermissionDenied(deniedPermissions)
    return false
  }
}