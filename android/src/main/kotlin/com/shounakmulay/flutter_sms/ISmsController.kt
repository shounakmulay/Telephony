package com.shounakmulay.flutter_sms

import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import org.json.JSONObject


interface ISmsController {
  fun sendSms(destinationAddress: String?, messageBody: String = "")
  fun getMessages(contentUri: ContentUri, projection: List<String>, selection: String?, selectionArgs: List<String>?, sortOrder: String?): List<HashMap<String, String>>
  fun getMessagesInJSON(contentUri: ContentUri, projection: List<String>, selection: String?, selectionArgs: List<String>?, sortOrder: String?): List<JSONObject>
}
