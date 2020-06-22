import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSms {
  static const MethodChannel _channel =
      const MethodChannel('plugins.shounakmulay.com/sendSMS');
  static const EventChannel _eventChannel = const EventChannel('plugins.shounakmulay.com/sendSmsStream');

  static Stream<dynamic> get sendSms {
    final Map args = Map();
    args.putIfAbsent('address', () => '9004640268');
    args.putIfAbsent('message_body', () => 'Hello from Flutter!');
    args.putIfAbsent('listen_status', () => true);
    final Stream<dynamic> sendResult = _eventChannel.receiveBroadcastStream();
    sendResult.listen((event) {
      print(event);
    });
    _channel.invokeMethod('sendSmsIntent', args);
    return sendResult;
  }

}
