import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSms {
  static const MethodChannel _channel =
      const MethodChannel('flutter_sms');

  static Future<String> get platformVersion async {
    final List messages = await _channel.invokeMethod('getAllInboxSms');
    print(messages.toString());
    return messages.toString();
  }
}
