import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

part 'constants.dart';

part 'filter.dart';

typedef MessageHandler(SmsMessage message);
typedef SmsSendStatusListener(SendStatus status);

void _flutterSmsSetupBackgroundChannel(
    {MethodChannel backgroundChannel =
        const MethodChannel(BACKGROUND_CHANNEL)}) async {
  WidgetsFlutterBinding.ensureInitialized();

  backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == HANDLE_BACKGROUND_MESSAGE) {
      final CallbackHandle handle =
          CallbackHandle.fromRawHandle(call.arguments['handle']);
      final Function handlerFunction =
          PluginUtilities.getCallbackFromHandle(handle);
      try {
        await handlerFunction(
            SmsMessage.fromMap(call.arguments['message'], INCOMING_SMS_COLUMNS));
      } catch (e) {
        print('Unable to handle incoming background message.');
        print(e);
      }
      return Future<void>.value();
    }
  });

  backgroundChannel.invokeMethod<void>(BACKGROUND_SERVICE_INITIALIZED);
}

class Telephony {
  final MethodChannel _foregroundChannel;
  final Platform _platform;

  MessageHandler _onNewMessage;
  MessageHandler _onBackgroundMessages;
  SmsSendStatusListener _statusListener;

  static Telephony get instance => _instance;

  @visibleForTesting
  Telephony.private(MethodChannel methodChannel, Platform platform)
      : _foregroundChannel = methodChannel,
        _platform = platform;

  Telephony._newInstance(MethodChannel methodChannel, LocalPlatform platform)
      : _foregroundChannel = methodChannel,
        _platform = platform {
    _foregroundChannel.setMethodCallHandler(handler);
  }

  static final Telephony _instance = Telephony._newInstance(
      const MethodChannel(FOREGROUND_CHANNEL), const LocalPlatform());

  void listenIncomingSms(
      {@required MessageHandler onNewMessage,
      MessageHandler onBackgroundMessage,
      bool listenInBackground = true}) {
    assert(_platform.isAndroid == true, "Can only be called on Android.");
    assert(
        listenInBackground
            ? onBackgroundMessage != null
            : onBackgroundMessage == null,
        listenInBackground
            ? "`onBackgroundMessage` cannot be null when `listenInBackground` is true. Set `listenInBackground` to false if you don't need background processing."
            : "You have set `listenInBackground` to false. `onBackgroundMessage` can only be set when `listenInBackground` is true");

    _onNewMessage = onNewMessage;

    if (listenInBackground && onBackgroundMessage != null) {
      _onBackgroundMessages = onBackgroundMessage;
      final CallbackHandle backgroundSetupHandle =
          PluginUtilities.getCallbackHandle(_flutterSmsSetupBackgroundChannel);
      final CallbackHandle backgroundMessageHandle =
          PluginUtilities.getCallbackHandle(_onBackgroundMessages);

      if (backgroundMessageHandle == null) {
        throw ArgumentError(
          '''Failed to setup background message handler! `onBackgroundMessage`
          should be a TOP-LEVEL OR STATIC FUNCTION and should NOT be tied to a
          class or an anonymous function.''',
        );
      }

      _foregroundChannel.invokeMethod<bool>(
        'startBackgroundService',
        <String, dynamic>{
          'setupHandle': backgroundSetupHandle.toRawHandle(),
          'backgroundHandle': backgroundMessageHandle.toRawHandle()
        },
      );
    } else {
      _foregroundChannel.invokeMethod('disableBackgroundService');
    }
  }

  @visibleForTesting
  Future<dynamic> handler(MethodCall call) async {
    switch (call.method) {
      case ON_MESSAGE:
        final message = call.arguments["message"];
        return _onNewMessage(
            SmsMessage.fromMap(message, INCOMING_SMS_COLUMNS));
        break;
      case SMS_SENT:
        return _statusListener(SendStatus.SENT);
        break;
      case SMS_DELIVERED:
        return _statusListener(SendStatus.DELIVERED);
        break;
    }
  }

  Future<List<SmsMessage>> getInboxSms(
      {List<SmsColumn> columns = DEFAULT_SMS_COLUMNS,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    assert(_platform.isAndroid == true, "Can only be called on Android.");
    final args = _getArguments(columns, filter, sortOrder);

    final List<dynamic> messages =
        await _foregroundChannel.invokeMethod(GET_ALL_INBOX_SMS, args);

    return messages
        .map((message) => SmsMessage.fromMap(message, columns))
        .toList(growable: false);
  }

  Future<List<SmsMessage>> getSentSms(
      {List<SmsColumn> columns = DEFAULT_SMS_COLUMNS,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    assert(_platform.isAndroid == true, "Can only be called on Android.");
    final args = _getArguments(columns, filter, sortOrder);

    final List<dynamic> messages =
        await _foregroundChannel.invokeMethod(GET_ALL_SENT_SMS, args);

    return messages
        .map((message) => SmsMessage.fromMap(message, columns))
        .toList(growable: false);
  }

  Future<List<SmsMessage>> getDraftSms(
      {List<SmsColumn> columns = DEFAULT_SMS_COLUMNS,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    assert(_platform.isAndroid == true, "Can only be called on Android.");
    final args = _getArguments(columns, filter, sortOrder);

    final List<dynamic> messages =
        await _foregroundChannel.invokeMethod(GET_ALL_DRAFT_SMS, args);

    return messages
        .map((message) => SmsMessage.fromMap(message, columns))
        .toList(growable: false);
  }

  Future<List<SmsConversation>> getConversations(
      {ConversationFilter filter, List<OrderBy> sortOrder}) async {
    assert(_platform.isAndroid == true, "Can only be called on Android.");
    final args = _getArguments(DEFAULT_CONVERSATION_COLUMNS, filter, sortOrder);

    final List<dynamic> conversations =
        await _foregroundChannel.invokeMethod(GET_ALL_CONVERSATIONS, args);

    return conversations
        .map((conversation) => SmsConversation.fromMap(conversation))
        .toList(growable: false);
  }

  Map<String, dynamic> _getArguments(
      List<_TelephonyColumn> columns, Filter filter, List<OrderBy> sortOrder) {
    final Map<String, dynamic> args = {};

    if (columns != null) {
      args["projection"] = columns.map((c) => c._name).toList();
    }

    if (filter != null) {
      args["selection"] = filter.selection;
      args["selection_args"] = filter.selectionArgs;
    }

    if (sortOrder != null && sortOrder.isNotEmpty) {
      args["sort_order"] = sortOrder.map((o) => o._value).join(",");
    }

    return args;
  }

  void sendSms({
    @required String to,
    @required String message,
    SmsSendStatusListener statusListener,
    bool isMultipart = false,
  }) {
    assert(_platform.isAndroid == true, "Can only be called on Android.");
    bool listenStatus = false;
    if (statusListener != null) {
      _statusListener = statusListener;
      listenStatus = true;
    }
    final Map<String, dynamic> args = {
      "address": to,
      "message_body": message,
      "listen_status": listenStatus
    };
    final String method = isMultipart ? SEND_MULTIPART_SMS : SEND_SMS;
    _foregroundChannel.invokeMethod(method, args);
  }

  void sendSmsByDefaultApp({
    @required String to,
    @required String message,
  }) {
    final Map<String, dynamic> args = {
      "address": to,
      "message_body": message,
    };
    _foregroundChannel.invokeMethod(SEND_SMS_INTENT, args);
  }

  Future<bool> get isSmsCapable =>
      _foregroundChannel.invokeMethod<bool>(IS_SMS_CAPABLE);

  Future<DataState> get cellularDataState async {
    final int dataState =
        await _foregroundChannel.invokeMethod<int>(GET_CELLULAR_DATA_STATE);
    if (dataState == -1) {
      return DataState.UNKNOWN;
    } else {
      return DataState.values[dataState];
    }
  }

  Future<CallState> get callState async {
    final int state =
        await _foregroundChannel.invokeMethod<int>(GET_CALL_STATE);
    return CallState.values[state];
  }

  Future<DataActivity> get dataActivity async {
    final int activity =
        await _foregroundChannel.invokeMethod<int>(GET_DATA_ACTIVITY);
    return DataActivity.values[activity];
  }

  Future<String> get networkOperator =>
      _foregroundChannel.invokeMethod<String>(GET_NETWORK_OPERATOR);

  Future<String> get networkOperatorName =>
      _foregroundChannel.invokeMethod<String>(GET_NETWORK_OPERATOR_NAME);

  Future<NetworkType> get dataNetworkType async {
    final int type =
        await _foregroundChannel.invokeMethod<int>(GET_DATA_NETWORK_TYPE);
    return NetworkType.values[type];
  }

  Future<PhoneType> get phoneType async {
    final int type = await _foregroundChannel.invokeMethod<int>(GET_PHONE_TYPE);
    return PhoneType.values[type];
  }

  Future<String> get simOperator =>
      _foregroundChannel.invokeMethod<String>(GET_SIM_OPERATOR);

  Future<String> get simOperatorName =>
      _foregroundChannel.invokeMethod<String>(GET_SIM_OPERATOR_NAME);

  Future<SimState> get simState async {
    final int state = await _foregroundChannel.invokeMethod<int>(GET_SIM_STATE);
    return SimState.values[state];
  }

  Future<bool> get isNetworkRoaming =>
      _foregroundChannel.invokeMethod<bool>(IS_NETWORK_ROAMING);

  Future<List<SignalStrength>> get signalStrengths async {
    final List<dynamic> strengths =
        await _foregroundChannel.invokeMethod(GET_SIGNAL_STRENGTH);
    return strengths
        .map((s) => SignalStrength.values[s])
        .toList(growable: false);
  }

  Future<ServiceState> get serviceState async {
    final int state =
        await _foregroundChannel.invokeMethod<int>(GET_SERVICE_STATE);
    return ServiceState.values[state];
  }

  Future<bool> get requestSmsPermissions =>
      _foregroundChannel.invokeMethod<bool>(REQUEST_SMS_PERMISSION);

  Future<bool> get requestPhonePermissions =>
      _foregroundChannel.invokeMethod<bool>(REQUEST_PHONE_PERMISSION);

  Future<bool> get requestPhoneAndSmsPermissions =>
      _foregroundChannel.invokeMethod<bool>(REQUEST_PHONE_AND_SMS_PERMISSION);
}

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

  @visibleForTesting
  SmsMessage.fromMap(Map rawMessage, List<SmsColumn> columns) {
    final message = Map.castFrom<dynamic, dynamic, String, dynamic>(rawMessage);
    for (var column in columns) {
      final value = message[column._columnName];
      switch (column._columnName) {
        case _SmsProjections.ID:
          this.id = int.tryParse(value);
          break;
        case _SmsProjections.ORIGINATING_ADDRESS:
        case _SmsProjections.ADDRESS:
          this.address = value;
          break;
        case _SmsProjections.MESSAGE_BODY:
        case _SmsProjections.BODY:
          this.body = value;
          break;
        case _SmsProjections.DATE:
        case _SmsProjections.TIMESTAMP:
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

  @visibleForTesting
  bool equals(SmsMessage other) {
    return this.id == other.id &&
        this.address == other.address &&
        this.body == other.body &&
        this.date == other.date &&
        this.dateSent == other.dateSent &&
        this.read == other.read &&
        this.seen == other.seen &&
        this.subject == other.subject &&
        this.subscriptionId == other.subscriptionId &&
        this.threadId == other.threadId &&
        this.type == other.type &&
        this.status == other.status;
  }
}

class SmsConversation {
  String snippet;
  int threadId;
  int messageCount;

  @visibleForTesting
  SmsConversation.fromMap(Map rawConversation) {
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

  @visibleForTesting
  bool equals(SmsConversation other) {
    return this.threadId == other.threadId &&
        this.snippet == other.snippet &&
        this.messageCount == other.messageCount;
  }
}
