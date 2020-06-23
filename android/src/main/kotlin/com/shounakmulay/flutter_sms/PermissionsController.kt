package com.shounakmulay.flutter_sms

import android.app.Activity
import android.content.pm.PackageManager
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Build
import androidx.annotation.RequiresApi
import com.shounakmulay.flutter_sms.utils.Constants

object PermissionsController {

  private lateinit var activity: Activity
  var isRequestingPermission: Boolean = false

  fun setActivity(activity: Activity) {
    this.activity = activity
  }

  fun hasRequiredPermissions(permissions: List<String>): Boolean {
    if (this::activity.isInitialized) {
      var hasPermissions = true
      for (permission in permissions) {
        hasPermissions = hasPermissions && checkPermission(permission)
      }
      return hasPermissions
    }
    return false
  }

  private fun checkPermission(permission: String): Boolean {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || activity.checkSelfPermission(permission) == PERMISSION_GRANTED
  }

  @RequiresApi(Build.VERSION_CODES.M)
  fun requestPermissions(permissions: List<String>, requestCode: Int) {
    if (this::activity.isInitialized && !isRequestingPermission) {
      isRequestingPermission = true
      activity.requestPermissions(permissions.toTypedArray(), requestCode)
    }
  }

  fun getSmsPermissions(): List<String> {
    val permissions = getListedPermissions()
    return permissions.filter { permission -> Constants.SMS_PERMISSIONS.contains(permission) }
  }

  private fun getListedPermissions(): Array<out String> {
    if (this::activity.isInitialized) {
      activity.applicationContext.apply {
        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
        return info.requestedPermissions ?: arrayOf()
      }
    }
    return arrayOf()
  }
}