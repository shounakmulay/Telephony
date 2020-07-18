part of 'telephony.dart';

const FOREGROUND_CHANNEL = 'plugins.shounakmulay.com/foreground_sms_channel';
const BACKGROUND_CHANNEL = 'plugins.shounakmulay.com/background_sms_channel';

const HANDLE_BACKGROUND_MESSAGE = "handleBackgroundMessage";
const BACKGROUND_SERVICE_INITIALIZED = "backgroundServiceInitialized";
const GET_ALL_INBOX_SMS = "getAllInboxSms";
const GET_ALL_SENT_SMS = "getAllSentSms";
const GET_ALL_DRAFT_SMS = "getAllDraftSms";
const GET_ALL_CONVERSATIONS = "getAllConversations";
const SEND_SMS = "sendSms";
const SEND_MULTIPART_SMS = "sendMultipartSms";
const SEND_SMS_INTENT = "sendSmsIntent";
const IS_SMS_CAPABLE = "isSmsCapable";
const GET_CELLULAR_DATA_STATE = "getCellularDataState";
const GET_CALL_STATE = "getCallState";
const GET_DATA_ACTIVITY = "getDataActivity";
const GET_NETWORK_OPERATOR = "getNetworkOperator";
const GET_NETWORK_OPERATOR_NAME = "getNetworkOperatorName";
const GET_DATA_NETWORK_TYPE = "getDataNetworkType";
const GET_PHONE_TYPE = "getPhoneType";
const GET_SIM_OPERATOR = "getSimOperator";
const GET_SIM_OPERATOR_NAME = "getSimOperatorName";
const GET_SIM_STATE = "getSimState";
const IS_NETWORK_ROAMING = "isNetworkRoaming";
const GET_SIGNAL_STRENGTH = "getSignalStrength";
const GET_SERVICE_STATE = "getServiceState";
const REQUEST_SMS_PERMISSION = "requestSmsPermissions";
const REQUEST_PHONE_PERMISSION = "requestPhonePermissions";
const REQUEST_PHONE_AND_SMS_PERMISSION = "requestPhoneAndSmsPermissions";

const ON_MESSAGE = "onMessage";
const SMS_SENT = "smsSent";
const SMS_DELIVERED = "smsDelivered";

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

enum ServiceState { IN_SERVICE, OUT_OF_SERVICE, EMERGENCY_ONLY, POWER_OFF }

enum SignalStrength { NONE_OR_UNKNOWN, POOR, MODERATE, GOOD, GREAT }

enum Sort { ASC, DESC }

extension Value on Sort {
  String get value {
    switch (this) {
      case Sort.ASC:
        return "ASC";
        break;
      case Sort.DESC:
      default:
        return "DESC";
        break;
    }
  }
}

enum SendStatus { SENT, DELIVERED }
