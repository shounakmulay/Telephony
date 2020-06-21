package com.shounakmulay.flutter_sms.utils.enums

import android.net.Uri
import android.provider.Telephony

enum class SmsAction(private val methodName : String) {
  GET_INBOX("getAllInboxSms"),
  GET_SENT("getAllSentSms"),
  GET_DRAFT("getAllDraftSms"),
  GET_CONVERSATIONS("getAllConversations"),
  SEND_SMS("sendSms"),
  SEND_MULTIPART_SMS("sendMultipartSms"),
  SEND_SMS_INTENT("sendSmsIntent"),
  NO_SUCH_METHOD("noSuchMethod");

 companion object {
   fun fromMethod(method: String): SmsAction {
     for (action in values()) {
       if (action.methodName == method) {
         return action
       }
     }
     return NO_SUCH_METHOD
   }
 }
}

enum class ContentUri(val uri: Uri) {
  INBOX(Telephony.Sms.Inbox.CONTENT_URI),
  SENT(Telephony.Sms.Sent.CONTENT_URI),
  DRAFT(Telephony.Sms.Draft.CONTENT_URI),
  CONVERSATIONS(Telephony.Sms.Conversations.CONTENT_URI);
}