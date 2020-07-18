
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:platform/platform.dart";
import "package:telephony/telephony.dart";

main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannel methodChannel;
  Telephony telephony;
  final List<MethodCall> log = <MethodCall>[];
  SmsSendStatusListener listener;

  setUp(() {
    methodChannel = MethodChannel("testChannel");
    telephony = Telephony.private(
        methodChannel, FakePlatform(operatingSystem: "android"));
    methodChannel.setMockMethodCallHandler((call) {
      log.add(call);
      if (call.method == SMS_SENT) {
        listener(SendStatus.SENT);
      }
      return;
    });
  });

  tearDown(() {
    methodChannel.setMockMethodCallHandler(null);
    log.clear();
  });


  group("should listen to", () {
    test("sms sent status", () async {
      listener = (status) {
        expect(status, SendStatus.SENT);
      };

      final args = {
        "address": "0000000000",
        "message_body": "Test message",
        "listen_status": true
      };

      telephony.sendSms(
          to: "0000000000", message: "Test message", statusListener: listener);

      expect(log, [isMethodCall(SEND_SMS, arguments: args)]);

      // called by native side
      methodChannel.invokeMethod(SMS_SENT);

      expect(log.length, 2);
      expect(log.last, isMethodCall(SMS_SENT, arguments: null));
    });
  });
}
