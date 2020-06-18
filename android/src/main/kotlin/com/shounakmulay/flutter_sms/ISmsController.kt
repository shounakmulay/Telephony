package com.shounakmulay.flutter_sms

import com.shounakmulay.flutter_sms.utils.Constants.DEFAULT_PROJECTION
import com.shounakmulay.flutter_sms.utils.enums.ContentUri



interface ISmsController {
  
  fun getMessages(contentUri: ContentUri, projection: List<String> = DEFAULT_PROJECTION): List<HashMap<String, String>>

  fun sendSms(destinationAddress: String?, messageBody: String = "")
}
