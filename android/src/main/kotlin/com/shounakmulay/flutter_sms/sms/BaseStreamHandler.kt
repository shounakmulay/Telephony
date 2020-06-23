package com.shounakmulay.flutter_sms.sms

import android.os.Build
import com.shounakmulay.flutter_sms.PermissionsController
import io.flutter.plugin.common.EventChannel

abstract class BaseStreamHandler: EventChannel.StreamHandler, BaseHandler() {

  fun checkOrRequestPermission(requestCode: Int): Boolean {
    return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      true
    } else {
      val permissions = PermissionsController.getSmsPermissions()
      checkOrRequestPermission(permissions, requestCode)
    }
  }

}
