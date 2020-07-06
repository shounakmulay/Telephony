part of 'flutter_sms.dart';

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

enum SmsColumn {
  ID,
  ADDRESS,
  BODY,
  DATE,
  DATE_SENT,
  READ,
  SEEN,
  STATUS,
  SUBJECT,
  SUBSCRIPTION_ID,
  THREAD_ID,
  TYPE
}

extension ColumnNames on SmsColumn {
  String get name {
    switch (this) {
      case SmsColumn.ID:
        return _SmsProjections.ID;
        break;
      case SmsColumn.ADDRESS:
        return _SmsProjections.ADDRESS;
        break;
      case SmsColumn.BODY:
        return _SmsProjections.BODY;
        break;
      case SmsColumn.DATE:
        return _SmsProjections.DATE;
        break;
      case SmsColumn.DATE_SENT:
        return _SmsProjections.DATE_SENT;
        break;
      case SmsColumn.READ:
        return _SmsProjections.READ;
        break;
      case SmsColumn.SEEN:
        return _SmsProjections.SEEN;
        break;
      case SmsColumn.STATUS:
        return _SmsProjections.STATUS;
        break;
      case SmsColumn.SUBJECT:
        return _SmsProjections.SUBJECT;
        break;
      case SmsColumn.SUBSCRIPTION_ID:
        return _SmsProjections.SUBSCRIPTION_ID;
        break;
      case SmsColumn.THREAD_ID:
        return _SmsProjections.THREAD_ID;
        break;
      case SmsColumn.TYPE:
        return _SmsProjections.TYPE;
        break;
      default:
        return null;
    }
  }

  SmsColumn fromName(String name) {
    for (var column in SmsColumn.values) {
      if (column.name == name) {
        return this;
      }
    }
    return null;
  }
}

const DEFAULT_SMS_COLUMNS = [
  SmsColumn.ID,
  SmsColumn.ADDRESS,
  SmsColumn.BODY,
  SmsColumn.DATE
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
  String subscriptionId;
  String threadId;
  SmsType type;
  SmsStatus status;

  SmsMessage(
      this.id,
      this.address,
      this.body,
      this.date,
      this.read,
      this.seen,
      this.subject,
      this.subscriptionId,
      this.threadId,
      this.dateSent,
      this.type,
      this.status);

  SmsMessage._fromMap(Map<String, dynamic> message, List<SmsColumn> columns) {
    for (var column in columns) {
      final value = message[column.name];
      switch (column) {
        case SmsColumn.ID:
          this.id = int.tryParse(value);
          break;
        case SmsColumn.ADDRESS:
          this.address = value;
          break;
        case SmsColumn.BODY:
          this.body = value;
          break;
        case SmsColumn.DATE:
          this.date = int.tryParse(value);
          break;
        case SmsColumn.DATE_SENT:
          this.dateSent = int.tryParse(value);
          break;
        case SmsColumn.READ:
          this.read = int.tryParse(value) == 0 ? false : true;
          break;
        case SmsColumn.SEEN:
          this.seen = int.tryParse(value) == 0 ? false : true;
          break;
        case SmsColumn.STATUS:
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
        case SmsColumn.SUBJECT:
          this.subject = value;
          break;
        case SmsColumn.SUBSCRIPTION_ID:
          this.subscriptionId = value;
          break;
        case SmsColumn.THREAD_ID:
          this.threadId = value;
          break;
        case SmsColumn.TYPE:
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
