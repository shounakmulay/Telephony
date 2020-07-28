import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/mockito.dart";
import "package:platform/platform.dart";
import "package:telephony/telephony.dart";
import 'package:collection/collection.dart';

import 'mocks/messages.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MockMethodChannel methodChannel;
  Telephony telephony;

  setUp(() {
    methodChannel = MockMethodChannel();
    telephony = Telephony.private(
        methodChannel, FakePlatform(operatingSystem: "android"));
  });

  tearDown(() {
    verifyNoMoreInteractions(methodChannel);
  });

  group("should request", () {
    test("sms permissions", () async {
      when(methodChannel.invokeMethod(REQUEST_SMS_PERMISSION))
          .thenAnswer((_) => Future<bool>.value(true));
      final permissionGranted = await telephony.requestSmsPermissions;
      verify(methodChannel.invokeMethod<bool>(REQUEST_SMS_PERMISSION));
      expect(permissionGranted, true);
    });

    test("phone permissions", () async {
      when(methodChannel.invokeMethod(REQUEST_PHONE_PERMISSION))
          .thenAnswer((_) => Future<bool>.value(true));
      final permissionGranted = await telephony.requestPhonePermissions;
      verify(methodChannel.invokeMethod<bool>(REQUEST_PHONE_PERMISSION));
      expect(permissionGranted, true);
    });

    test("phone and sms permissions", () async {
      when(methodChannel.invokeMethod(REQUEST_PHONE_AND_SMS_PERMISSION))
          .thenAnswer((_) => Future<bool>.value(true));
      final permissionGranted = await telephony.requestPhoneAndSmsPermissions;
      verify(
          methodChannel.invokeMethod<bool>(REQUEST_PHONE_AND_SMS_PERMISSION));
      expect(permissionGranted, true);
    });
  });

  group("should get", () {
    test("service state", () async {
      when(methodChannel.invokeMethod(GET_SERVICE_STATE))
          .thenAnswer((_) => Future<int>.value(1));
      final state = await telephony.serviceState;
      verify(methodChannel.invokeMethod<int>(GET_SERVICE_STATE));
      expect(state, ServiceState.OUT_OF_SERVICE);
    });

    test("signal strengths", () async {
      when(methodChannel.invokeMethod(GET_SIGNAL_STRENGTH))
          .thenAnswer((_) => Future<List>.value([0, 1]));
      final strengths = await telephony.signalStrengths;
      verify(methodChannel.invokeMethod(GET_SIGNAL_STRENGTH));
      expect(strengths, [SignalStrength.NONE_OR_UNKNOWN, SignalStrength.POOR]);
    });

    test("is network roaming", () async {
      when(methodChannel.invokeMethod<bool>(IS_NETWORK_ROAMING))
          .thenAnswer((_) => Future<bool>.value(false));
      final result = await telephony.isNetworkRoaming;
      verify(methodChannel.invokeMethod(IS_NETWORK_ROAMING));
      expect(result, false);
    });

    test("sim state", () async {
      when(methodChannel.invokeMethod(GET_SIM_STATE))
          .thenAnswer((_) => Future<int>.value(5));
      final state = await telephony.simState;
      verify(methodChannel.invokeMethod(GET_SIM_STATE));
      expect(state, SimState.READY);
    });

    test("sim operator name", () async {
      when(methodChannel.invokeMethod(GET_SIM_OPERATOR_NAME))
          .thenAnswer((_) => Future<String>.value("operatorName"));
      final name = await telephony.simOperatorName;
      verify(methodChannel.invokeMethod(GET_SIM_OPERATOR_NAME));
      expect(name, "operatorName");
    });

    test("sim operator", () async {
      when(methodChannel.invokeMethod(GET_SIM_OPERATOR))
          .thenAnswer((_) => Future<String>.value("operator"));
      final name = await telephony.simOperator;
      verify(methodChannel.invokeMethod(GET_SIM_OPERATOR));
      expect(name, "operator");
    });

    test("phone type", () async {
      when(methodChannel.invokeMethod(GET_PHONE_TYPE))
          .thenAnswer((_) => Future<int>.value(2));
      final type = await telephony.phoneType;
      verify(methodChannel.invokeMethod(GET_PHONE_TYPE));
      expect(type, PhoneType.CDMA);
    });

    test("data network type", () async {
      when(methodChannel.invokeMethod(GET_DATA_NETWORK_TYPE))
          .thenAnswer((_) => Future<int>.value(0));
      final type = await telephony.dataNetworkType;
      verify(methodChannel.invokeMethod(GET_DATA_NETWORK_TYPE));
      expect(type, NetworkType.UNKNOWN);
    });

    test("network operator name", () async {
      when(methodChannel.invokeMethod(GET_NETWORK_OPERATOR_NAME))
          .thenAnswer((_) => Future<String>.value("operator name"));
      final name = await telephony.networkOperatorName;
      verify(methodChannel.invokeMethod(GET_NETWORK_OPERATOR_NAME));
      expect(name, "operator name");
    });

    test("network operator", () async {
      when(methodChannel.invokeMethod(GET_NETWORK_OPERATOR))
          .thenAnswer((_) => Future<String>.value("operator"));
      final operator = await telephony.networkOperator;
      verify(methodChannel.invokeMethod(GET_NETWORK_OPERATOR));
      expect(operator, "operator");
    });

    test("data activity", () async {
      when(methodChannel.invokeMethod(GET_DATA_ACTIVITY))
          .thenAnswer((_) => Future<int>.value(1));
      final activity = await telephony.dataActivity;
      verify(methodChannel.invokeMethod(GET_DATA_ACTIVITY));
      expect(activity, DataActivity.IN);
    });

    test("call state", () async {
      when(methodChannel.invokeMethod(GET_CALL_STATE))
          .thenAnswer((_) => Future<int>.value(2));
      final state = await telephony.callState;
      verify(methodChannel.invokeMethod(GET_CALL_STATE));
      expect(state, CallState.OFFHOOK);
    });

    test("cellular data state", () async {
      when(methodChannel.invokeMethod(GET_CELLULAR_DATA_STATE))
          .thenAnswer((_) => Future<int>.value(0));
      final state = await telephony.cellularDataState;
      verify(methodChannel.invokeMethod(GET_CELLULAR_DATA_STATE));
      expect(state, DataState.DISCONNECTED);
    });

    test("is sms capable", () async {
      when(methodChannel.invokeMethod(IS_SMS_CAPABLE))
          .thenAnswer((_) => Future<bool>.value(true));
      final result = await telephony.isSmsCapable;
      verify(methodChannel.invokeMethod(IS_SMS_CAPABLE));
      expect(result, true);
    });
  });

  group("should send", () {
    test("sms", () async {
      telephony.sendSms(to: "0000000000", message: "Test message");
      verify(methodChannel.invokeMethod(SEND_SMS, {
        "address": "0000000000",
        "message_body": "Test message",
        "listen_status": false
      }));
    });

    test("multipart message", () async {
      telephony.sendSms(
          to: "123456", message: "some long message", isMultipart: true);

      final args = {
        "address": "123456",
        "message_body": "some long message",
        "listen_status": false
      };

      verifyNever(methodChannel.invokeMethod(SEND_SMS, args));

      verify(methodChannel.invokeMethod(SEND_MULTIPART_SMS, args));
    });

    test("sms by default app", () async {
      telephony.sendSmsByDefaultApp(to: "123456", message: "message");

      verify(methodChannel.invokeMethod(
          SEND_SMS_INTENT, {"address": "123456", "message_body": "message"}));
    });
  });

  group("should query", () {
    test("inbox", () async {
      final args = {
        "projection": ["_id", "address", "body", "date"],
      };

      when(methodChannel.invokeMethod(GET_ALL_INBOX_SMS, args))
          .thenAnswer((_) => Future<List>.value(mockMessages));

      final inbox = await telephony.getInboxSms();

      verify(methodChannel.invokeMethod(GET_ALL_INBOX_SMS, args));

      expect(
          inbox[0]
              .equals(SmsMessage.fromMap(mockMessages[0], DEFAULT_SMS_COLUMNS)),
          isTrue);
      expect(
          inbox[1]
              .equals(SmsMessage.fromMap(mockMessages[1], DEFAULT_SMS_COLUMNS)),
          isTrue);
    });

    test("inbox with filters", () async {
      final columns = [SmsColumn.ID, SmsColumn.ADDRESS];
      final filter = SmsFilter.where(SmsColumn.ID)
          .equals("3")
          .and(SmsColumn.ADDRESS)
          .like("mess");
      final sortOrder = [OrderBy(SmsColumn.ID, sort: Sort.ASC)];

      final args = {
        "projection": ["_id", "address"],
        "selection": "_id = ?  AND address LIKE ?",
        "selection_args": ["3", "mess"],
        "sort_order": "_id ASC"
      };

      when(methodChannel.invokeMethod(GET_ALL_INBOX_SMS, args))
          .thenAnswer((_) => Future<List>.value(mockMessages));

      final inbox = await telephony.getInboxSms(
          columns: columns, filter: filter, sortOrder: sortOrder);
      verify(await methodChannel.invokeMethod(GET_ALL_INBOX_SMS, args));
      expect(inbox[0].equals(SmsMessage.fromMap(mockMessages[0], columns)),
          isTrue);
      expect(inbox[1].equals(SmsMessage.fromMap(mockMessages[1], columns)),
          isTrue);
    });

    test("sent", () async {
      final args = {
        "projection": ["_id", "address", "body", "date"],
      };

      when(methodChannel.invokeMethod(GET_ALL_SENT_SMS, args))
          .thenAnswer((_) => Future<List>.value(mockMessages));

      final sent = await telephony.getSentSms();

      verify(methodChannel.invokeMethod(GET_ALL_SENT_SMS, args));

      expect(
          sent[0]
              .equals(SmsMessage.fromMap(mockMessages[0], DEFAULT_SMS_COLUMNS)),
          isTrue);
      expect(
          sent[1]
              .equals(SmsMessage.fromMap(mockMessages[1], DEFAULT_SMS_COLUMNS)),
          isTrue);
    });

    test("sent with filters", () async {
      final columns = [SmsColumn.ID, SmsColumn.ADDRESS];
      final filter = SmsFilter.where(SmsColumn.ID)
          .equals("4")
          .and(SmsColumn.DATE)
          .greaterThan("12");
      final sortOrder = [OrderBy(SmsColumn.ID, sort: Sort.ASC)];

      final args = {
        "projection": ["_id", "address"],
        "selection": "_id = ?  AND date > ?",
        "selection_args": ["4", "12"],
        "sort_order": "_id ASC"
      };

      when(methodChannel.invokeMethod(GET_ALL_SENT_SMS, args))
          .thenAnswer((_) => Future<List>.value(mockMessages));

      final sent = await telephony.getSentSms(
          columns: columns, filter: filter, sortOrder: sortOrder);
      verify(await methodChannel.invokeMethod(GET_ALL_SENT_SMS, args));
      expect(
          sent[0].equals(SmsMessage.fromMap(mockMessages[0], columns)), isTrue);
      expect(
          sent[1].equals(SmsMessage.fromMap(mockMessages[1], columns)), isTrue);
    });

    test("draft", () async {
      final args = {
        "projection": ["_id", "address", "body", "date"],
      };

      when(methodChannel.invokeMethod(GET_ALL_DRAFT_SMS, args))
          .thenAnswer((_) => Future<List>.value(mockMessages));

      final drafts = await telephony.getDraftSms();

      verify(methodChannel.invokeMethod(GET_ALL_DRAFT_SMS, args));

      expect(
          drafts[0]
              .equals(SmsMessage.fromMap(mockMessages[0], DEFAULT_SMS_COLUMNS)),
          isTrue);
      expect(
          drafts[1]
              .equals(SmsMessage.fromMap(mockMessages[1], DEFAULT_SMS_COLUMNS)),
          isTrue);
    });

    test("draft with filters", () async {
      final columns = [SmsColumn.ID, SmsColumn.ADDRESS];
      final filter = SmsFilter.where(SmsColumn.ID)
          .equals("4")
          .and(SmsColumn.DATE)
          .greaterThan("12");
      final sortOrder = [OrderBy(SmsColumn.ID, sort: Sort.ASC)];

      final args = {
        "projection": ["_id", "address"],
        "selection": "_id = ?  AND date > ?",
        "selection_args": ["4", "12"],
        "sort_order": "_id ASC"
      };

      when(methodChannel.invokeMethod(GET_ALL_DRAFT_SMS, args))
          .thenAnswer((_) => Future<List>.value(mockMessages));

      final drafts = await telephony.getDraftSms(
          columns: columns, filter: filter, sortOrder: sortOrder);
      verify(await methodChannel.invokeMethod(GET_ALL_DRAFT_SMS, args));
      expect(drafts[0].equals(SmsMessage.fromMap(mockMessages[0], columns)),
          isTrue);
      expect(drafts[1].equals(SmsMessage.fromMap(mockMessages[1], columns)),
          isTrue);
    });

    test("conversations", () async {
      final args = {
        "projection": ["snippet", "thread_id", "msg_count"]
      };

      when(methodChannel.invokeMethod(GET_ALL_CONVERSATIONS, args)).thenAnswer(
          (realInvocation) => Future<List>.value(mockConversations));

      final conversations = await telephony.getConversations();

      verify(methodChannel.invokeMethod(GET_ALL_CONVERSATIONS, args));
      expect(
          conversations[0]
              .equals(SmsConversation.fromMap(mockConversations[0])),
          isTrue);
      expect(
          conversations[1]
              .equals(SmsConversation.fromMap(mockConversations[1])),
          isTrue);
    });

    test("conversations with filter", () async {
      final filter = ConversationFilter.where(ConversationColumn.MSG_COUNT)
          .equals("4")
          .and(ConversationColumn.THREAD_ID)
          .greaterThan("12");
      final sortOrder = [OrderBy(ConversationColumn.THREAD_ID, sort: Sort.ASC)];

      final args = {
        "projection": ["snippet", "thread_id", "msg_count"],
        "selection": "msg_count = ?  AND thread_id > ?",
        "selection_args": ["4", "12"],
        "sort_order": "thread_id ASC"
      };

      when(methodChannel.invokeMethod(GET_ALL_CONVERSATIONS, args)).thenAnswer(
          (realInvocation) => Future<List>.value(mockConversations));

      final conversations = await telephony.getConversations(
          filter: filter, sortOrder: sortOrder);

      verify(await methodChannel.invokeMethod(GET_ALL_CONVERSATIONS, args));
      expect(
          conversations[0]
              .equals(SmsConversation.fromMap(mockConversations[0])),
          isTrue);
      expect(
          conversations[1]
              .equals(SmsConversation.fromMap(mockConversations[1])),
          isTrue);
    });
  });

  group("should generate", () {
    test("sms filter statement", () async {
      final statement = SmsFilter.where(SmsColumn.ADDRESS)
          .greaterThan("1")
          .and(SmsColumn.ID)
          .greaterThanOrEqualTo("2")
          .or(SmsColumn.DATE)
          .between("3", "4")
          .or(SmsColumn.TYPE)
          .not
          .like("5");

      expect(
          statement.selection,
          equals(
              "address > ?  AND _id >= ?  OR date BETWEEN ?  OR NOT type LIKE ?"));
      expect(
          ListEquality()
              .equals(statement.selectionArgs, ["1", "2", "3 AND 4", "5"]),
          isTrue);
    });

    test("conversation filter statement", () async {
      final statement = ConversationFilter.where(ConversationColumn.THREAD_ID)
          .lessThanOrEqualTo("1")
          .or(ConversationColumn.MSG_COUNT)
          .notEqualTo("6")
          .and(ConversationColumn.SNIPPET)
          .not
          .notEqualTo("7");

      expect(statement.selection,
          "thread_id <= ?  OR msg_count != ?  AND NOT snippet != ?");
      expect(ListEquality().equals(statement.selectionArgs, ["1", "6", "7"]),
          isTrue);
    });
  });
}

class MockMethodChannel extends Mock implements MethodChannel {}
