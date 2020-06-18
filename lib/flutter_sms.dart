import 'dart:async';

import 'package:flutter/services.dart';

class FlutterSms {
  static const MethodChannel _channel =
      const MethodChannel('plugins.shounakmulay.com/querySMS');

  static Future<String> get platformVersion async {
    final Map messages = await _channel.invokeMethod('getAllInboxSms');
    print(messages.toString());
    return messages.toString();
  }
}
