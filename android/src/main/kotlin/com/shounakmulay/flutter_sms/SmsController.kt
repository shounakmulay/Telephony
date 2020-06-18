package com.shounakmulay.flutter_sms

import android.content.Context
import com.shounakmulay.flutter_sms.utils.enums.ContentUri


class SmsController(private val context: Context): ISmsController {

  override fun sendSms(destinationAddress: String?, messageBody: String) {
    TODO("Not yet implemented")
  }

  override fun getMessages(contentUri: ContentUri, projection: List<String>): List<HashMap<String, String>> {
    val messages = mutableListOf<HashMap<String, String>>()

    val cursor = context.contentResolver.query(contentUri.toUri(), projection.toTypedArray(), null, null, null)

    while (cursor != null && cursor.moveToNext()) {
      val map: HashMap<String, String> = HashMap(projection.size)
      for (propName in projection) {
        map[propName] = cursor.getString(cursor.getColumnIndex(propName)) ?: ""
      }
      messages.add(map)
    }

    cursor?.close()
    return messages
  }

  
}