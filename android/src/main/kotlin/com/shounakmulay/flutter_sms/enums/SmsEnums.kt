package com.shounakmulay.flutter_sms.enums

import android.net.Uri

enum class SmsQuery(val id : String) {
  GET_INBOX("getAllInboxSms"),
  GET_SENT("getAllSentSms"),
  GET_DRAFT("getAllDraftSms"),
  NO_SUCH_METHOD("noSuchMethod");

 companion object {
   fun fromMethod(method: String): SmsQuery {
     return when (method) {
       GET_INBOX.id -> GET_INBOX
       GET_SENT.id -> GET_SENT
       GET_DRAFT.id -> GET_DRAFT
       else -> NO_SUCH_METHOD
     }
   }
 }
}

enum class SmsUri(val uri: String) {
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