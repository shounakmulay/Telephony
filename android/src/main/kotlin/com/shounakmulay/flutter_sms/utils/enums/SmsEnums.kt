package com.shounakmulay.flutter_sms.utils.enums

import android.net.Uri

enum class SmsQuery(private val methodName : String) {
  GET_INBOX("getAllInboxSms"),
  GET_SENT("getAllSentSms"),
  GET_DRAFT("getAllDraftSms"),
  NO_SUCH_METHOD("noSuchMethod");

 companion object {
   fun fromMethod(method: String): SmsQuery {
     return when (method) {
       GET_INBOX.methodName -> GET_INBOX
       GET_SENT.methodName -> GET_SENT
       GET_DRAFT.methodName -> GET_DRAFT
       else -> NO_SUCH_METHOD
     }
   }
 }
}

enum class SmsSend(val methodName: String) {
  SEND_SMS("sendSms"),
  NO_SUCH_METHOD("noSuchMethod");

  companion object {
    fun fromMethod(method: String): SmsSend {
      return when (method) {
        SEND_SMS.methodName -> SEND_SMS
        else -> NO_SUCH_METHOD
      }
    }
  }
}

enum class ContentUri(private val uri: String) {
  INBOX("content://sms/inbox"),
  SENT("content://sms/sent"),
  DRAFT("content://sms/draft");

  fun toUri(): Uri {
    return when (this) {
      INBOX -> Uri.parse(INBOX.uri)
      SENT -> Uri.parse(SENT.uri)
      DRAFT -> Uri.parse(DRAFT.uri)
    }
  }
}