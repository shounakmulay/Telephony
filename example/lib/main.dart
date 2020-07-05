import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_sms/projections.dart';
import 'package:flutter_sms/sms_message.dart';
import 'package:vibration/vibration.dart';

onBackgroundMessage(Map<String, dynamic> message) {
  debugPrint("onBackgroundMessage called");
  Vibration.vibrate(duration: 1000);
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  onMessage(Map<String, dynamic> message) async {
    setState(() {
      _message = message.toString();
    });
    await Vibration.vibrate(duration: 5000, repeat: 2);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    var sms = FlutterSms.instance;

    var messages = await sms.getInboxSms(
        columns: [
          SmsColumn.DATE,
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.READ
        ],
        filter: SmsFilter.where(SmsColumn.DATE)
            .greaterThanOrEqualTo("1593865041625")
            .and(SmsColumn.READ)
            .equals("0"),
        sortOrder: [OrderBy(SmsColumn.BODY, sort: Sort.ASC), OrderBy(SmsColumn.DATE, sort: Sort.ASC),]);
    messages;
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(child: Text('Running on: $_message\n')),
      ),
    );
  }
}
