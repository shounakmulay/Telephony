package com.shounakmulay.flutter_sms

import android.app.Activity
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Build
import androidx.annotation.RequiresApi

class PermissionsController(private var activity: Activity) {

  fun hasRequiredPermissions(permissions: List<String>): Boolean {
    var hasPermissions = true
    for (permission in permissions) {
      hasPermissions = hasPermissions && checkPermission(permission)
    }
    return hasPermissions
  }

  fun hasRequiredPermissions(permission: String): Boolean {
    return checkPermission(permission)
  }

  private fun checkPermission(permission: String): Boolean {
    return Build.VERSION.SDK_INT < Build.VERSION_CODES.M || activity.checkSelfPermission(permission) == PERMISSION_GRANTED
  }

  @RequiresApi(Build.VERSION_CODES.M)
  fun requestPermissions(permissions: List<String>, requestCode: Int) {
    activity.requestPermissions(permissions.toTypedArray(), requestCode)
  }

  @RequiresApi(Build.VERSION_CODES.M)
  fun requestPermissions(permission: String, requestCode: Int) {
    activity.requestPermissions(arrayOf(permission), requestCode)
  }
  
  @RequiresApi(Build.VERSION_CODES.M)
  fun shouldShowRequestPermissionRationale(permission: String) {
    activity.shouldShowRequestPermissionRationale(permission)
  }

}