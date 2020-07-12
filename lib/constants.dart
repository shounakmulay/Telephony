part of 'telephony.dart';

class _SmsProjections {
  static const String COUNT = "_count";
  static const String ID = "_id";
  static const String ADDRESS = "address";
  static const String BODY = "body";
  static const String CREATOR = "creator";
  static const String DATE = "date";
  static const String DATE_SENT = "date_sent";
  static const String ERROR_CODE = "error_code";
  static const String LOCKED = "locked";
  static const int MESSAGE_TYPE_ALL = 0;
  static const int MESSAGE_TYPE_DRAFT = 3;
  static const int MESSAGE_TYPE_FAILED = 5;
  static const int MESSAGE_TYPE_INBOX = 1;
  static const int MESSAGE_TYPE_OUTBOX = 4;
  static const int MESSAGE_TYPE_QUEUED = 6;
  static const int MESSAGE_TYPE_SENT = 2;
  static const String PERSON = "person";
  static const String PROTOCOL = "protocol";
  static const String READ = "read";
  static const String REPLY_PATH_PRESENT = "reply_path_present";
  static const String SEEN = "seen";
  static const String SERVICE_CENTER = "service_center";
  static const String STATUS = "status";
  static const int STATUS_COMPLETE = 0;
  static const int STATUS_FAILED = 64;
  static const int STATUS_NONE = -1;
  static const int STATUS_PENDING = 32;
  static const String SUBJECT = "subject";
  static const String SUBSCRIPTION_ID = "sub_id";
  static const String THREAD_ID = "thread_id";
  static const String TYPE = "type";
}

class _ConversationProjections {
  static const String SNIPPET = "snippet";
  static const String THREAD_ID = "thread_id";
  static const String MSG_COUNT = "msg_count";
}

abstract class Column {

  const Column();

  String get _name;
}

class SmsColumn extends Column {
  final String _columnName;

  const SmsColumn._(this._columnName);

  static const ID = SmsColumn._(_SmsProjections.ID);
  static const ADDRESS = SmsColumn._(_SmsProjections.ADDRESS);
  static const BODY = SmsColumn._(_SmsProjections.BODY);
  static const DATE = SmsColumn._(_SmsProjections.DATE);
  static const DATE_SENT = SmsColumn._(_SmsProjections.DATE_SENT);
  static const READ = SmsColumn._(_SmsProjections.READ);
  static const SEEN = SmsColumn._(_SmsProjections.SEEN);
  static const STATUS = SmsColumn._(_SmsProjections.STATUS);
  static const SUBJECT = SmsColumn._(_SmsProjections.SUBJECT);
  static const SUBSCRIPTION_ID = SmsColumn._(_SmsProjections.SUBSCRIPTION_ID);
  static const THREAD_ID = SmsColumn._(_SmsProjections.THREAD_ID);
  static const TYPE = SmsColumn._(_SmsProjections.TYPE);

  @override
  String get _name => _columnName;
}

class ConversationColumn extends Column {
  final String _columnName;

  const ConversationColumn._(this._columnName);

  static const SNIPPET = ConversationColumn._(_ConversationProjections.SNIPPET);
  static const THREAD_ID =
      ConversationColumn._(_ConversationProjections.THREAD_ID);
  static const MSG_COUNT =
      ConversationColumn._(_ConversationProjections.MSG_COUNT);

  @override
  String get _name => _columnName;
}

const DEFAULT_SMS_COLUMNS = [
  SmsColumn.ID,
  SmsColumn.ADDRESS,
  SmsColumn.BODY,
  SmsColumn.DATE
];

const DEFAULT_CONVERSATION_COLUMNS = [
  ConversationColumn.SNIPPET,
  ConversationColumn.THREAD_ID,
  ConversationColumn.MSG_COUNT
];

class SmsMessage {
  int id;
  String address;
  String body;
  int date;
  int dateSent;
  bool read;
  bool seen;
  String subject;
  int subscriptionId;
  int threadId;
  SmsType type;
  SmsStatus status;

  SmsMessage._fromMap(
      Map rawMessage, List<SmsColumn> columns) {
    final message = Map.castFrom<dynamic, dynamic, String, dynamic>(rawMessage);
    for (var column in columns) {
      final value = message[column._columnName];
      switch (column._columnName) {
        case _SmsProjections.ID:
          this.id = int.tryParse(value);
          break;
        case _SmsProjections.ADDRESS:
          this.address = value;
          break;
        case _SmsProjections.BODY:
          this.body = value;
          break;
        case _SmsProjections.DATE:
          this.date = int.tryParse(value);
          break;
        case _SmsProjections.DATE_SENT:
          this.dateSent = int.tryParse(value);
          break;
        case _SmsProjections.READ:
          this.read = int.tryParse(value) == 0 ? false : true;
          break;
        case _SmsProjections.SEEN:
          this.seen = int.tryParse(value) == 0 ? false : true;
          break;
        case _SmsProjections.STATUS:
          switch (int.tryParse(value)) {
            case 0:
              this.status = SmsStatus.STATUS_COMPLETE;
              break;
            case 32:
              this.status = SmsStatus.STATUS_PENDING;
              break;
            case 64:
              this.status = SmsStatus.STATUS_FAILED;
              break;
            case -1:
            default:
              this.status = SmsStatus.STATUS_NONE;
              break;
          }
          break;
        case _SmsProjections.SUBJECT:
          this.subject = value;
          break;
        case _SmsProjections.SUBSCRIPTION_ID:
          this.subscriptionId = int.tryParse(value);
          break;
        case _SmsProjections.THREAD_ID:
          this.threadId = int.tryParse(value);
          break;
        case _SmsProjections.TYPE:
          this.type = SmsType.values[value];
          break;
      }
    }
  }
}

enum SmsType {
  MESSAGE_TYPE_ALL,
  MESSAGE_TYPE_INBOX,
  MESSAGE_TYPE_SENT,
  MESSAGE_TYPE_DRAFT,
  MESSAGE_TYPE_OUTBOX,
  MESSAGE_TYPE_FAILED,
  MESSAGE_TYPE_QUEUED
}

enum SmsStatus { STATUS_COMPLETE, STATUS_FAILED, STATUS_NONE, STATUS_PENDING }

class SmsConversation {
  String snippet;
  int threadId;
  int messageCount;

  SmsConversation._fromMap(Map rawConversation) {
    final conversation =
        Map.castFrom<dynamic, dynamic, String, dynamic>(rawConversation);
    for (var column in DEFAULT_CONVERSATION_COLUMNS) {
      final String value = conversation[column._columnName];
      switch (column._columnName) {
        case _ConversationProjections.SNIPPET:
          this.snippet = value;
          break;
        case _ConversationProjections.THREAD_ID:
          this.threadId = int.tryParse(value);
          break;
        case _ConversationProjections.MSG_COUNT:
          this.messageCount = int.tryParse(value);
          break;
      }
    }
  }
}

enum DataState { DISCONNECTED, CONNECTING, CONNECTED, SUSPENDED, UNKNOWN }

enum CallState { IDLE, RINGING, OFFHOOK }

enum DataActivity { NONE, IN, OUT, INOUT, DORMANT }

enum NetworkType {
  UNKNOWN,
  GPRS,
  EDGE,
  UMTS,
  CDMA,
  EVDO_0,
  EVDO_A,
  TYPE_1xRTT,
  HSDPA,
  HSUPA,
  HSPA,
  IDEN,
  EVDO_B,
  LTE,
  EHRPD,
  HSPAP,
  GSM,
  TD_SCDMA,
  IWLAN,
  LTE_CA,
  NR,
}

enum PhoneType { NONE, GSM, CDMA, SIP }

enum SimState {
  UNKNOWN,
  ABSENT,
  PIN_REQUIRED,
  PUK_REQUIRED,
  NETWORK_LOCKED,
  READY,
  NOT_READY,
  PERM_DISABLED,
  CARD_IO_ERROR,
  CARD_RESTRICTED,
  LOADED,
  PRESENT
}

enum ServiceState { IN_SERVICE, OUT_OF_SERVICE, EMERGENCY_ONLY, POWER_OFF }

enum SignalStrength { NONE_OR_UNKNOWN, POOR, MODERATE, GOOD, GREAT }
