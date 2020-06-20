package com.shounakmulay.flutter_sms

import android.content.Context
import android.provider.Telephony
import android.util.Log
import com.shounakmulay.flutter_sms.utils.enums.ContentUri
import org.json.JSONArray
import org.json.JSONObject
import java.lang.RuntimeException


class SmsController(private val context: Context) : ISmsController {
 

  override fun getConversations(
      contentUri: ContentUri, 
      projection: List<String>, 
      selection: String?, 
      selectionArgs: List<String>?, 
      sortOrder: String?
  ): List<HashMap<String, String?>> {
    return getQueryResult(contentUri, projection, selection, selectionArgs, sortOrder)
  }

  override fun getMessages(
      contentUri: ContentUri,
      projection: List<String>,
      selection: String?,
      selectionArgs: List<String>?,
      sortOrder: String?
  ): List<HashMap<String, String?>> {
    return getQueryResult(contentUri, projection, selection, selectionArgs, sortOrder)
  }

  override fun sendSms(destinationAddress: String?, messageBody: String) {
    TODO("Not yet implemented")
  }

  private fun getQueryResult(
      contentUri: ContentUri,
      projection: List<String>,
      selection: String?,
      selectionArgs: List<String>?,
      sortOrder: String?
  ): MutableList<HashMap<String, String?>> {
    val messages = mutableListOf<HashMap<String, String?>>()

    val cursor = context.contentResolver.query(
        contentUri.uri,
        null,
        selection,
        selectionArgs?.toTypedArray(),
        sortOrder
    )

    while (cursor != null && cursor.moveToNext()) {
      val dataObject = HashMap<String, String?>(projection.size)
      for (columnName in cursor.columnNames) {
        val value = cursor.getString(cursor.getColumnIndex(columnName))
        dataObject[columnName] = value
      }
      messages.add(dataObject)
    }

    cursor?.close()

    return messages

  }
}