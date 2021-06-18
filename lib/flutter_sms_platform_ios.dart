import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('plugins.shounakmulay.com/background_sms_channel');

class FlutterSmsPlatformiOS extends PlatformInterface {
  /// Constructs a FlutterSmsPlatform.
  FlutterSmsPlatformiOS() : super(token: _token);

  static final Object _token = Object();

  static FlutterSmsPlatformiOS _instance = FlutterSmsPlatformiOS();

  /// The default instance of [FlutterSmsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSmsPlatform].
  static FlutterSmsPlatformiOS get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FlutterSmsPlatform] when they register themselves.
  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(FlutterSmsPlatformiOS instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> sendSMS({
    required String message,
    required List<String> recipients,
  }) {
    final mapData = <dynamic, dynamic>{};
    mapData['message'] = message;
    if (!kIsWeb && Platform.isIOS) {
      mapData['recipients'] = recipients;
      return _channel
          .invokeMethod<String>('sendSMS', mapData)
          .then((value) => value ?? 'Error sending sms');
    } else {
      String _phones = recipients.join(';');
      mapData['recipients'] = _phones;
      return _channel
          .invokeMethod<String>('sendSMS', mapData)
          .then((value) => value ?? 'Error sending sms');
    }
  }
}
