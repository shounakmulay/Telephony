import 'package:flutter/material.dart';
import 'dart:async';
import 'package:telephony/telephony.dart';

onBackgroundMessage(Map<String, dynamic> message) {
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
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
            child: FutureBuilder(
                future: Telephony.instance.getInboxSms(
                    filter: SmsFilter.where(SmsColumn.DATE)
                        .greaterThan("4")
                        .and(SmsColumn.BODY)
                        .not
                        .equals("equalTo")
                        .and(SmsColumn.BODY)
                        .like("%!%")),
                builder: (context, AsyncSnapshot<List<SmsMessage>> snapshot) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "${snapshot.data[index].address}: ${snapshot.data[index].body}"),
                      );
                    },
                  );
                })),
      ),
    );
  }
}
