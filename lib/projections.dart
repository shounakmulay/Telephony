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
  COUNT,
  ID,
  ADDRESS,
  BODY,
  CREATOR,
  DATE,
  DATE_SENT,
  ERROR_CODE,
  LOCKED,
  MESSAGE_TYPE_ALL,
  MESSAGE_TYPE_DRAFT,
  MESSAGE_TYPE_FAILED,
  MESSAGE_TYPE_INBOX,
  MESSAGE_TYPE_OUTBOX,
  MESSAGE_TYPE_QUEUED,
  MESSAGE_TYPE_SENT,
  PERSON,
  PROTOCOL,
  READ,
  REPLY_PATH_PRESENT,
  SEEN,
  SERVICE_CENTER,
  STATUS,
  STATUS_COMPLETE,
  STATUS_FAILED,
  STATUS_NONE,
  STATUS_PENDING,
  SUBJECT,
  SUBSCRIPTION_ID,
  THREAD_ID,
  TYPE
}

extension ColumnNames on SmsColumn {
  String get name {
    switch (this) {
      case SmsColumn.COUNT:
        return _SmsProjections.COUNT;
        break;
      case SmsColumn.ID:
        return _SmsProjections.ID;
        break;
      case SmsColumn.ADDRESS:
        return _SmsProjections.ADDRESS;
        break;
      case SmsColumn.BODY:
        return _SmsProjections.BODY;
        break;
      case SmsColumn.CREATOR:
        return _SmsProjections.CREATOR;
        break;
      case SmsColumn.DATE:
        return _SmsProjections.DATE;
        break;
      case SmsColumn.DATE_SENT:
        return _SmsProjections.DATE_SENT;
        break;
      case SmsColumn.ERROR_CODE:
        return _SmsProjections.ERROR_CODE;
        break;
      case SmsColumn.LOCKED:
        return _SmsProjections.LOCKED;
        break;
      case SmsColumn.MESSAGE_TYPE_ALL:
        return _SmsProjections.MESSAGE_TYPE_ALL.toString();
        break;
      case SmsColumn.MESSAGE_TYPE_DRAFT:
        return _SmsProjections.MESSAGE_TYPE_DRAFT.toString();
        break;
      case SmsColumn.MESSAGE_TYPE_FAILED:
        return _SmsProjections.MESSAGE_TYPE_FAILED.toString();
        break;
      case SmsColumn.MESSAGE_TYPE_INBOX:
        return _SmsProjections.MESSAGE_TYPE_INBOX.toString();
        break;
      case SmsColumn.MESSAGE_TYPE_OUTBOX:
        return _SmsProjections.MESSAGE_TYPE_OUTBOX.toString();
        break;
      case SmsColumn.MESSAGE_TYPE_QUEUED:
        return _SmsProjections.MESSAGE_TYPE_QUEUED.toString();
        break;
      case SmsColumn.MESSAGE_TYPE_SENT:
        return _SmsProjections.MESSAGE_TYPE_SENT.toString();
        break;
      case SmsColumn.PERSON:
        return _SmsProjections.PERSON;
        break;
      case SmsColumn.PROTOCOL:
        return _SmsProjections.PROTOCOL;
        break;
      case SmsColumn.READ:
        return _SmsProjections.READ;
        break;
      case SmsColumn.REPLY_PATH_PRESENT:
        return _SmsProjections.REPLY_PATH_PRESENT;
        break;
      case SmsColumn.SEEN:
        return _SmsProjections.SEEN;
        break;
      case SmsColumn.SERVICE_CENTER:
        return _SmsProjections.SERVICE_CENTER;
        break;
      case SmsColumn.STATUS:
        return _SmsProjections.STATUS;
        break;
      case SmsColumn.STATUS_COMPLETE:
        return _SmsProjections.STATUS_COMPLETE.toString();
        break;
      case SmsColumn.STATUS_FAILED:
        return _SmsProjections.STATUS_FAILED.toString();
        break;
      case SmsColumn.STATUS_NONE:
        return _SmsProjections.STATUS_NONE.toString();
        break;
      case SmsColumn.STATUS_PENDING:
        return _SmsProjections.STATUS_PENDING.toString();
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

const DEFAULT_SMS_COLUMNS = [SmsColumn.ID, SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE];
