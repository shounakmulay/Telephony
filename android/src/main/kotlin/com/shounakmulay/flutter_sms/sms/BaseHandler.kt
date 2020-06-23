package com.shounakmulay.flutter_sms.sms

import android.os.Build
import androidx.annotation.RequiresApi
import com.shounakmulay.flutter_sms.PermissionsController

abstract class BaseHandler {

  @RequiresApi(Build.VERSION_CODES.M)
  protected fun checkOrRequestPermission(permissions: List<String>, requestCode: Int): Boolean {
    PermissionsController.apply {
      if (!hasRequiredPermissions(permissions)) {
        requestPermissions(permissions, requestCode)
        return false
      }
      return true
    }
  }
}
