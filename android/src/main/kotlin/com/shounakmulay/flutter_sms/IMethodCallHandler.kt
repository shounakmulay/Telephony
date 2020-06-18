package com.shounakmulay.flutter_sms

import android.app.Activity
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import com.shounakmulay.flutter_sms.utils.Constants.READ_SMS
import io.flutter.plugin.common.PluginRegistry

interface OnPermissionGrantedListener {
  fun onPermissionGranted(contentUri: ContentUri)
  fun onPermissionDenied(deniedPermissions: List<String>)
}


abstract class IMethodCallHandler(private val requestCode: Int) : PluginRegistry.RequestPermissionsResultListener, OnPermissionGrantedListener {
  private lateinit var permissionsController: PermissionsController
  private lateinit var contentUri: ContentUri


  fun setActivity(activity: Activity) {
    permissionsController = PermissionsController(activity)
  }

  @RequiresApi(Build.VERSION_CODES.M)
  fun checkOrRequestPermission(contentUri: ContentUri): Boolean {
    if (this::permissionsController.isInitialized) {
      this.contentUri = contentUri
      when (contentUri) {
        ContentUri.INBOX,
        ContentUri.SENT,
        ContentUri.DRAFT -> {
          permissionsController.apply {
            if (!hasRequiredPermissions(READ_SMS)) {
              permissionsController.requestPermissions(READ_SMS, requestCode)
              return false
            }
            return true
          }
        }
      }
    }
    return false
  }

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
      onPermissionGranted(contentUri)
      return true
    }

    onPermissionDenied(deniedPermissions)
    return false
  }
}