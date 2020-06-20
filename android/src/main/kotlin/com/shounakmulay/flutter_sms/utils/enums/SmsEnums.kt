package com.shounakmulay.flutter_sms.utils.enums

import android.net.Uri
import android.provider.Telephony
import android.telecom.TelecomManager

enum class SmsQuery(private val methodName : String) {
  GET_INBOX("getAllInboxSms"),
  GET_SENT("getAllSentSms"),
  GET_DRAFT("getAllDraftSms"),
  GET_CONVERSATIONS("getAllConversations"),
  NO_SUCH_METHOD("noSuchMethod");

 companion object {
   fun fromMethod(method: String): SmsQuery {
     return when (method) {
       GET_INBOX.methodName -> GET_INBOX
       GET_SENT.methodName -> GET_SENT
       GET_DRAFT.methodName -> GET_DRAFT
       GET_CONVERSATIONS.methodName -> GET_CONVERSATIONS
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

enum class ContentUri(val uri: Uri) {
  INBOX(Telephony.Sms.Inbox.CONTENT_URI),
  SENT(Telephony.Sms.Sent.CONTENT_URI),
  DRAFT(Telephony.Sms.Draft.CONTENT_URI),
  CONVERSATIONS(Telephony.Sms.Conversations.CONTENT_URI);
}