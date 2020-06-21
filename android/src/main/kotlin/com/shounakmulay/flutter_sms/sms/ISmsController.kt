package com.shounakmulay.flutter_sms.sms

import com.shounakmulay.flutter_sms.utils.enums.ContentUri


interface ISmsController {
  fun sendSms(destinationAddress: String, messageBody: String, listenStatus: Boolean = false)
  fun sendMultipartSms(destinationAddress: String, messageBody: String, listenStatus: Boolean = false)
  fun getConversations(contentUri: ContentUri, projection: List<String>, selection: String?, selectionArgs: List<String>?, sortOrder: String?): List<HashMap<String, String?>>
  fun getMessages(contentUri: ContentUri, projection: List<String>, selection: String?, selectionArgs: List<String>?, sortOrder: String?): List<HashMap<String, String?>>
  fun sendSmsIntent(destinationAddress: String, messageBody: String)
}
