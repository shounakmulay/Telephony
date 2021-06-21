import 'dart:io';

import 'package:flutter/material.dart';
import 'package:telephony/flutter_sms_platform_ios.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

onBackgroundMessage(SmsMessage message) {
  debugPrint("onBackgroundMessage called");
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  final telephony = Telephony.instance;
  List<String> people = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(SmsMessage message) async {
    setState(() {
      _message = message.body ?? "Error reading message body.";
    });
  }

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    final bool? result = await telephony.requestPhoneAndSmsPermissions;

    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage, onBackgroundMessage: onBackgroundMessage);
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Latest received SMS: $_message")),
          TextButton(
              onPressed: () async {
                if (Platform.isIOS) {
                  people.add('123478236');
                  _sendSMS(people);
                } else {
                  await telephony.openDialer("123478236");
                }
              },
              child: Text('Open Dialer'))
        ],
      ),
    ));
  }

  Future<void> _sendSMS(List<String> recipients) async {
    try {
      String _result = await FlutterSmsPlatformiOS.instance
          .sendSMS(message: 'test', recipients: recipients);

      setState(() => _message = _result);
    } catch (error) {
      setState(() => _message = error.toString());
    }
  }
}
