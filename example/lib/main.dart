import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_sms/flutter_sms.dart';
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

  onSendStatus(SendStatus status) {
    setState(() {
      _message = status == SendStatus.SENT ? "sent" : "delivered";
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    var sms = FlutterSms.instance;

    sms.sendSmsByDefaultApp(
        to: "+919004640268",
        message: "Sent from flutter",
    );
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
