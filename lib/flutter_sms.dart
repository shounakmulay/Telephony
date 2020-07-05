import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sms/projections.dart';
import 'package:platform/platform.dart';

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

class FlutterSms {
  final MethodChannel _foregroundChannel;
  final LocalPlatform _platform;

  MessageHandler _onNewMessages;
  MessageHandler _onBackgroundMessages;

  static FlutterSms get instance => _instance;

  FlutterSms._newInstance(MethodChannel methodChannel, LocalPlatform platform)
      : _foregroundChannel = methodChannel,
        _platform = platform {
    _foregroundChannel.setMethodCallHandler(_handler);
  }

  static final FlutterSms _instance = FlutterSms._newInstance(
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
        .map((message) => SmsMessage._fromMap(
            Map.castFrom<dynamic, dynamic, String, dynamic>(message), columns))
        .toList();
  }

  Future<List<SmsMessage>> getSentSms(
      {List<SmsColumn> columns,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    final args = _getArguments(columns, filter, sortOrder);

    final List<Map<String, dynamic>> messages =
        await _foregroundChannel.invokeMethod('getAllSentSms', args);

    return messages.map((message) => SmsMessage._fromMap(message, columns));
  }

  Future<List<SmsMessage>> getDraftSms(
      {List<SmsColumn> columns,
      SmsFilter filter,
      List<OrderBy> sortOrder}) async {
    final args = _getArguments(columns, filter, sortOrder);

    final List<Map<String, dynamic>> messages =
        await _foregroundChannel.invokeMethod('getAllDraftSms', args);

    return messages.map((message) => SmsMessage._fromMap(message, columns));
  }

  Map<String, dynamic> _getArguments(
      List<SmsColumn> columns, SmsFilter filter, List<OrderBy> sortOrder) {
    final Map<String, dynamic> args = {};

    if (columns != null) {
      args["projection"] = columns.map((c) => c.name).toList();
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
  String subscriptionId;
  String threadId;
  SmsType type;
  bool timed;
  bool deleted;
  int errorCode;
  int status;

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
      this.timed,
      this.deleted,
      this.errorCode,
      this.status);

  SmsMessage._fromMap(Map<String, dynamic> message, List<SmsColumn> columns) {
    for (var column in columns) {
      final value = message[column.name];
      switch (column) {
        case SmsColumn.COUNT:
          // TODO: Handle this case.
          break;
        case SmsColumn.ID:
          this.id = int.tryParse(value);
          break;
        case SmsColumn.ADDRESS:
          this.address = value;
          break;
        case SmsColumn.BODY:
          this.body = value;
          break;
        case SmsColumn.CREATOR:
          // TODO: Handle this case.
          break;
        case SmsColumn.DATE:
          this.date = int.tryParse(value);
          break;
        case SmsColumn.DATE_SENT:
          this.dateSent = value;
          break;
        case SmsColumn.ERROR_CODE:
          this.errorCode = value;
          break;
        case SmsColumn.LOCKED:
          // TODO: Handle this case.
          break;
        case SmsColumn.MESSAGE_TYPE_ALL:
          // TODO: Handle this case.
          break;
        case SmsColumn.MESSAGE_TYPE_DRAFT:
          // TODO: Handle this case.
          break;
        case SmsColumn.MESSAGE_TYPE_FAILED:
          // TODO: Handle this case.
          break;
        case SmsColumn.MESSAGE_TYPE_INBOX:
          // TODO: Handle this case.
          break;
        case SmsColumn.MESSAGE_TYPE_OUTBOX:
          // TODO: Handle this case.
          break;
        case SmsColumn.MESSAGE_TYPE_QUEUED:
          // TODO: Handle this case.
          break;
        case SmsColumn.MESSAGE_TYPE_SENT:
          // TODO: Handle this case.
          break;
        case SmsColumn.PERSON:
          // TODO: Handle this case.
          break;
        case SmsColumn.PROTOCOL:
          // TODO: Handle this case.
          break;
        case SmsColumn.READ:
          this.read = int.tryParse(value) == 0 ? false : true;
          break;
        case SmsColumn.REPLY_PATH_PRESENT:
          // TODO: Handle this case.
          break;
        case SmsColumn.SEEN:
          this.seen = value;
          break;
        case SmsColumn.SERVICE_CENTER:
          // TODO: Handle this case.
          break;
        case SmsColumn.STATUS:
          this.status = value;
          break;
        case SmsColumn.STATUS_COMPLETE:
          // TODO: Handle this case.
          break;
        case SmsColumn.STATUS_FAILED:
          // TODO: Handle this case.
          break;
        case SmsColumn.STATUS_NONE:
          // TODO: Handle this case.
          break;
        case SmsColumn.STATUS_PENDING:
          // TODO: Handle this case.
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
          // TODO: Handle this case.
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

class SmsFilter {
  final String _filter;
  final List<String> _filterArgs;

  SmsFilter._(this._filter, this._filterArgs);

  static FilterStatement where(SmsColumn column) => FilterStatement._(column);

  FilterStatement and(SmsColumn column) {
    return FilterStatement._withPreviousFilter(
        "$_filter AND", column, List.from(_filterArgs, growable: true));
  }

  String get _selection => _filter;

  List<String> get _selectionArgs => _filterArgs;
}

class FilterStatement {
  final SmsColumn _column;
  String _previousFilter;
  List<String> _previousFilterArgs;

  FilterStatement._(this._column);

  FilterStatement._withPreviousFilter(
      String previousFilter, SmsColumn column, List<String> previousFilterArgs)
      : _previousFilter = previousFilter,
        _column = column,
        _previousFilterArgs = previousFilterArgs;

  SmsFilter equals(String equalTo) {
    return _createFilter(equalTo, "=");
  }

  SmsFilter greaterThan(String value) {
    return _createFilter(value, ">");
  }

  SmsFilter lessThan(String value) {
    return _createFilter(value, "<");
  }

  SmsFilter greaterThanOrEqualTo(String value) {
    return _createFilter(value, ">=");
  }

  SmsFilter lessThanOrEqualTo(String value) {
    return _createFilter(value, "<=");
  }

  SmsFilter notEqualTo(String value) {
    return _createFilter(value, "!=");
  }

  SmsFilter like(String value) {
    return _createFilter(value, "LIKE");
  }

  SmsFilter inValues(List<String> values) {
    final String filterValues = values.join(",");
    return _createFilter("($filterValues)", "IN");
  }

  SmsFilter between(String from, String to) {
    final String filterValue = "$from AND $to";
    return _createFilter(filterValue, "BETWEEN");
  }

  // TODO: Probably should add () to every filter
  SmsFilter _createFilter(String value, String operator) {
    if (_previousFilter != null) {
      return SmsFilter._("$_previousFilter ${_column.name} $operator ?",
          _previousFilterArgs..add(value));
    } else {
      return SmsFilter._("${_column.name} $operator ?", [value]);
    }
  }
}

class OrderBy {
  final SmsColumn _column;
  Sort _sort = Sort.DESC;

  OrderBy(this._column, {Sort sort}) {
    if (sort != null) {
      _sort = sort;
    }
  }

  String get _value => "${_column.name} ${_sort.value}";
}

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

enum Sort { ASC, DESC }
