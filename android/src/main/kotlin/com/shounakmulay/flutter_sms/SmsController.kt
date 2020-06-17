package com.shounakmulay.flutter_sms

import android.content.Context
import com.shounakmulay.flutter_sms.enums.SmsUri

private val DEFAULT_PROJECTION =  listOf("subject", "body", "_id", "address")

class SmsController(private val context: Context): ISmsController {

  override fun getInbox(projectionList: List<String>?): List<HashMap<String, String>> {
    return getMessages(SmsUri.INBOX, projectionList)
  }

  override fun getSent(projectionList: List<String>?): List<Map<String, Any>> {
    return getMessages(SmsUri.SENT, projectionList)
  }

  override fun getDraft(projectionList: List<String>?): List<Map<String, Any>> {
    return getMessages(SmsUri.DRAFT, projectionList)
  }
  
  private fun getMessages(queryUri: SmsUri, projectionList: List<String>? = null): MutableList<HashMap<String, String>> {
    val projection = projectionList ?: DEFAULT_PROJECTION
    val messages = mutableListOf<HashMap<String, String>>()

    val cursor = context.contentResolver.query(queryUri.toUri(), projection.toTypedArray(), null, null, null)

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