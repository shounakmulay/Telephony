package com.shounakmulay.flutter_sms

import android.content.Context
import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import org.json.JSONObject
import java.lang.RuntimeException


class SmsController(private val context: Context) : ISmsController {

  override fun sendSms(destinationAddress: String?, messageBody: String) {
    TODO("Not yet implemented")
  }

  @Throws(RuntimeException::class)
  override fun getMessages(
      contentUri: ContentUri,
      projection: List<String>,
      selection: String?,
      selectionArgs: List<String>?,
      sortOrder: String?
  ): List<HashMap<String, String>> {
    val messages = mutableListOf<HashMap<String, String>>()

    val cursor = context.contentResolver.query(
        contentUri.toUri(),
        projection.toTypedArray(),
        selection,
        selectionArgs?.toTypedArray(),
        sortOrder
    )

    while (cursor != null && cursor.moveToNext()) {
      val map: HashMap<String, String> = HashMap(projection.size)
      for (propName in projection) {
        // Can throw exception. Handle Exceptions
        map[propName] = cursor.getString(cursor.getColumnIndex(propName)) ?: ""
      }
      messages.add(map)
    }

    cursor?.close()
    return messages
  }

  @Throws(RuntimeException::class)
  override fun getMessagesInJSON(contentUri: ContentUri, projection: List<String>, selection: String?, selectionArgs: List<String>?, sortOrder: String?): List<JSONObject> {
    val messages = mutableListOf<JSONObject>()

    val cursor = context.contentResolver.query(
        contentUri.toUri(),
        projection.toTypedArray(),
        selection,
        selectionArgs?.toTypedArray(),
        sortOrder
    )

    while (cursor != null && cursor.moveToNext()) {
      val sms = JSONObject()
      for (propName in projection) {
        // Can throw exception. Handle Exceptions
        sms.put(propName, cursor.getString(cursor.getColumnIndex(propName)))
      }
      messages.add(sms)
    }

    cursor?.close()
    return messages
  }
}