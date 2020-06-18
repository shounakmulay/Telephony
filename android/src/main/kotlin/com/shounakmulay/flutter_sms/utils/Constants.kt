package com.shounakmulay.flutter_sms.utils

import android.provider.Telephony

object Constants {
  
  // Permissions
  const val READ_SMS = android.Manifest.permission.READ_SMS
  const val SEND_SMS = android.Manifest.permission.SEND_SMS
  const val RECEIVE_SMS = android.Manifest.permission.RECEIVE_SMS
  
  // Request Codes
  const val SMS_QUERY_REQUEST_CODE = 1
  const val SMS_SEND_REQUEST_CODE = 2
  
  // Method Call Arguments
  const val RETURN_TYPE = "return_type"
  const val PROJECTION = "projection"
  
  const val JSON = "json"
  const val MAP = "map"

  val DEFAULT_PROJECTION =  listOf(Telephony.Sms.ADDRESS, Telephony.Sms.BODY, Telephony.Sms.DATE)
  
  const val PERMISSION_DENIED = "permission_denied"
  const val PERMISSION_DENIED_MESSAGE = "Permission Request Denied By User"
}