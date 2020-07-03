import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';

typedef MessageHandler(Map<String, dynamic> message);

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
//  static const MethodChannel _channel =
//      const MethodChannel('plugins.shounakmulay.com/sendSMS');
//  static const EventChannel _eventChannel =
//      const EventChannel('plugins.shounakmulay.com/receiveSmsStream');

  final MethodChannel _foregroundChannel;
  final LocalPlatform _platform;

  factory FlutterSms() => _instance;

  FlutterSms.instance(MethodChannel methodChannel, LocalPlatform platform)
      : _foregroundChannel = methodChannel,
        _platform = platform;

  static final FlutterSms _instance = FlutterSms.instance(
      const MethodChannel('plugins.shounakmulay.com/foreground_sms_channel'),
      const LocalPlatform());

  MessageHandler _onNewMessages;
  MessageHandler _onBackgroundMessages;

  void listenIncoming(MessageHandler onNewMessages,
      MessageHandler onBackgroundMessage) {
    _onNewMessages = onNewMessages;
    _foregroundChannel.setMethodCallHandler(_handler);

    if (onBackgroundMessage != null) {
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
    debugPrint("Method Call Flutter: " + call.method.toString());
    switch (call.method) {
      case "onMessage":
        debugPrint("on_message activated on foreground dart");
        return _onNewMessages(call.arguments.cast<String, dynamic>());
    }
  }
}
