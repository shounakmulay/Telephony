import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

part 'constants.dart';

typedef MessageHandler(Map<String, dynamic> message);
typedef SmsSendStatusListener(SendStatus status);

enum SendStatus { SENT, DELIVERED }

void _flutterSmsSetupBackgroundChannel(
    {MethodChannel backgroundChannel = const MethodChannel(
        'plugins.shounakmulay.com/background_sms_channel')}) async {
  WidgetsFlutterBinding.ensureInitialized();

  backgroundChannel.setMethodCallHandler((call) async {
    if (call.method == 'handleBackgroundMessage') {
      final CallbackHandle handle =
          CallbackHandle.fromRawHandle(call.arguments['handle']);
      final Function handlerFunction =
          PluginUtilities.getCallbackFromHandle(handle);
      try {
        await handlerFunction(
            Map<String, dynamic>.from(call.arguments['message']));
      } catch (e) {
        print('Unable to handle incoming background message.');
        print(e);
      }
      return Future<void>.value();
    }
  });

  backgroundChannel.invokeMethod<void>('backgroundServiceInitialized');
}

class Telephony {
  final MethodChannel _foregroundChannel;
  final LocalPlatform _platform;

  MessageHandler _onNewMessages;
  MessageHandler _onBackgroundMessages;
  SmsSendStatusListener _statusListener;

  Telephony(this._foregroundChannel, this._platform);

  static Telephony get instance => _instance;

  Telephony._newInstance(MethodChannel methodChannel, LocalPlatform platform)
      : _foregroundChannel = methodChannel,
        _platform = platform {
    _foregroundChannel.setMethodCallHandler(_handler);
  }

  static final Telephony _instance = Telephony._newInstance(
      const MethodChannel('plugins.shounakmulay.com/foreground_sms_channel'),
      const LocalPlatform());

  void listenIncomingSms(
      {@required MessageHandler onNewMessages,
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

    _onNewMessages = onNewMessages;

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
    }
  }

  Future<dynamic> _handler(MethodCall call) async {
    switch (call.method) {
      case "onMessage":
        return _onNewMessages(call.arguments.cast<String, dynamic>());
        break;
      case "smsSent":
        return _statusListener(SendStatus.SENT);
        break;
      case "smsDelivered":
        return _statusListener(SendStatus.DELIVERED);
        break;
    }
  }

  Future<List<SmsMessage>> getInboxSms(
      {List<SmsColumn> columns = DEFAULT_SMS_COLUMNS,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    final args = _getArguments(columns, filter, sortOrder);

    final List<dynamic> messages =
        await _foregroundChannel.invokeMethod('getAllInboxSms', args);

    return messages
        .map((message) => SmsMessage._fromMap(message, columns))
        .toList(growable: false);
  }

  Future<List<SmsMessage>> getSentSms(
      {List<SmsColumn> columns,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    final args = _getArguments(columns, filter, sortOrder);

    final List<dynamic> messages =
        await _foregroundChannel.invokeMethod('getAllSentSms', args);

    return messages
        .map((message) => SmsMessage._fromMap(message, columns))
        .toList(growable: false);
  }

  Future<List<SmsMessage>> getDraftSms(
      {List<SmsColumn> columns,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    final args = _getArguments(columns, filter, sortOrder);

    final List<dynamic> messages =
        await _foregroundChannel.invokeMethod('getAllDraftSms', args);

    return messages
        .map((message) => SmsMessage._fromMap(message, columns))
        .toList(growable: false);
  }

  Future<List<SmsConversation>> getConversations(
      {List<ConversationColumn> columns,
      ConversationFilter filter,
      List<OrderBy> sortOrder}) async {
    final args = _getArguments(columns, filter, sortOrder);

    final List<dynamic> conversations =
        await _foregroundChannel.invokeMethod('getAllConversations');

    return conversations
        .map((conversation) => SmsConversation._fromMap(conversation))
        .toList(growable: false);
  }

  Map<String, dynamic> _getArguments(
      List<Column> columns, Filter filter, List<OrderBy> sortOrder) {
    final Map<String, dynamic> args = {};

    if (columns != null) {
      args["projection"] = columns.map((c) => c._name).toList();
    }

    if (filter != null) {
      args["selection"] = filter._selection;
      args["selection_args"] = filter._selectionArgs;
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
    final String method = isMultipart ? "sendMultipartSms" : "sendSms";
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
    _foregroundChannel.invokeMethod("sendSmsIntent", args);
  }

  Future<bool> get isSmsCapable =>
      _foregroundChannel.invokeMethod<bool>("isSmsCapable");

  Future<DataState> get cellularDataState async {
    final int dataState =
        await _foregroundChannel.invokeMethod<int>("getCellularDataState");
    if (dataState == -1) {
      return DataState.UNKNOWN;
    } else {
      return DataState.values[dataState];
    }
  }

  Future<CallState> get callState async {
    final int state =
        await _foregroundChannel.invokeMethod<int>("getCallState");
    return CallState.values[state];
  }

  Future<DataActivity> get dataActivity async {
    final int activity =
        await _foregroundChannel.invokeMethod<int>("getDataActivity");
    return DataActivity.values[activity];
  }

  Future<String> get networkOperator =>
      _foregroundChannel.invokeMethod<String>("getNetworkOperator");

  Future<String> get networkOperatorName =>
      _foregroundChannel.invokeMethod<String>("getNetworkOperatorName");

  Future<NetworkType> get dataNetworkType async {
    final int type =
        await _foregroundChannel.invokeMethod<int>("getDataNetworkType");
    return NetworkType.values[type];
  }

  Future<PhoneType> get phoneType async {
    final int type = await _foregroundChannel.invokeMethod<int>("getPhoneType");
    return PhoneType.values[type];
  }

  Future<String> get simOperator =>
      _foregroundChannel.invokeMethod<String>("getSimOperator");

  Future<String> get simOperatorName =>
      _foregroundChannel.invokeMethod<String>("getSimOperatorName");

  Future<SimState> get simState async {
    final int state = await _foregroundChannel.invokeMethod<int>("getSimState");
    return SimState.values[state];
  }

  Future<bool> get isNetworkRoaming =>
      _foregroundChannel.invokeMethod<bool>("isNetworkRoaming");

  Future<List<SignalStrength>> get signalStrengths async {
    final List<dynamic> strengths =
        await _foregroundChannel.invokeMethod("getSignalStrength");
    return strengths
        .map((s) => SignalStrength.values[s])
        .toList(growable: false);
  }

  Future<ServiceState> get serviceState async {
    final int state =
        await _foregroundChannel.invokeMethod<int>("getServiceState");
    return ServiceState.values[state];
  }
}

abstract class Filter<T, K> {
  T and(K column);

  String get _selection;

  List<String> get _selectionArgs;
}

class SmsFilter implements Filter<SmsFilterStatement, SmsColumn> {
  final String _filter;
  final List<String> _filterArgs;

  SmsFilter._(this._filter, this._filterArgs);

  static SmsFilterStatement where(SmsColumn column) =>
      SmsFilterStatement._(column._columnName);

  SmsFilterStatement and(SmsColumn column) {
    return SmsFilterStatement._withPreviousFilter(
        "$_filter AND", column._name, List.from(_filterArgs, growable: true));
  }

  @override
  String get _selection => _filter;

  @override
  List<String> get _selectionArgs => _filterArgs;
}

class ConversationFilter extends Filter<ConversationFilterStatement, ConversationColumn> {
  final String _filter;
  final List<String> _filterArgs;

  ConversationFilter._(this._filter, this._filterArgs);

  static ConversationFilterStatement where(ConversationColumn column) =>
      ConversationFilterStatement._(column._columnName);

  @override
  ConversationFilterStatement and(ConversationColumn column) {
    return ConversationFilterStatement._withPreviousFilter(
        "$_filter AND", column._name, List.from(_filterArgs, growable: true));
  }

  @override
  String get _selection => _filter;

  @override
  List<String> get _selectionArgs => _filterArgs;
}

abstract class FilterStatement<T extends Filter> {
  String _column;
  String _previousFilter;
  List<String> _previousFilterArgs;

  FilterStatement._(this._column);

  FilterStatement._withPreviousFilter(
      String previousFilter, String column, List<String> previousFilterArgs)
      : _previousFilter = previousFilter,
        _column = column,
        _previousFilterArgs = previousFilterArgs;

  T equals(String equalTo) {
    return _createFilter(equalTo, "=");
  }

  T greaterThan(String value) {
    return _createFilter(value, ">");
  }

  T lessThan(String value) {
    return _createFilter(value, "<");
  }

  T greaterThanOrEqualTo(String value) {
    return _createFilter(value, ">=");
  }

  T lessThanOrEqualTo(String value) {
    return _createFilter(value, "<=");
  }

  T notEqualTo(String value) {
    return _createFilter(value, "!=");
  }

  T like(String value) {
    return _createFilter(value, "LIKE");
  }

  T inValues(List<String> values) {
    final String filterValues = values.join(",");
    return _createFilter("($filterValues)", "IN");
  }

  T between(String from, String to) {
    final String filterValue = "$from AND $to";
    return _createFilter(filterValue, "BETWEEN");
  }

  T _createFilter(String value, String operator);
}

class SmsFilterStatement extends FilterStatement<SmsFilter> {
  SmsFilterStatement._(String column) : super._(column);

  SmsFilterStatement._withPreviousFilter(
      String previousFilter, String column, List<String> previousFilterArgs)
      : super._withPreviousFilter(previousFilter, column, previousFilterArgs);

  @override
  SmsFilter _createFilter(String value, String operator) {
    if (_previousFilter != null) {
      return SmsFilter._("$_previousFilter $_column $operator ?",
          _previousFilterArgs..add(value));
    } else {
      return SmsFilter._("$_column $operator ?", [value]);
    }
  }
}

class ConversationFilterStatement extends FilterStatement<ConversationFilter> {
  ConversationFilterStatement._(String column) : super._(column);

  ConversationFilterStatement._withPreviousFilter(
      String previousFilter, String column, List<String> previousFilterArgs)
      : super._withPreviousFilter(previousFilter, column, previousFilterArgs);

  @override
  ConversationFilter _createFilter(String value, String operator) {
    if (_previousFilter != null) {
      return ConversationFilter._("$_previousFilter $_column $operator ?",
          _previousFilterArgs..add(value));
    } else {
      return ConversationFilter._("$_column $operator ?", [value]);
    }
  }
}

class OrderBy {
  final String _column;
  Sort _sort = Sort.DESC;

  OrderBy(this._column, {Sort sort}) {
    if (sort != null) {
      _sort = sort;
    }
  }

  String get _value => "$_column ${_sort.value}";
}

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
