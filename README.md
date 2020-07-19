# Telephony
|:exclamation: This plugin currently only works on Android Platform|
|------------------------------------------------------------------|


A Flutter plugin to use telephony features such as
- Send SMS Messages
- Query SMS Messages
- Listen for incoming SMS
- Retrieve various network parameters

This plugin tries to replicate some of the functionality provided by Android's [Telephony](https://developer.android.com/reference/android/provider/Telephony) class.

Check the [Features section](#Features) to see the list of implemented and missing features.




## Usage
To use this plugin add `telephony` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

## Get Started
|:bulb: View the entire documentation **[here](https://shounakmulay.github.io/Telephony/)**.|
|----------|

### Setup
Import the `telephony` package
```dart
import 'package:telephony/telephony.dart';
```


Retrieve the singleton instance of `telephony` by calling
```dart
final Telephony telephony = Telephony.instance;
```

### Permissions
**Although this plugin will check and ask for permissions at runtime, it is advisable to _manually ask for permissions_ before calling any other functions.**

The plugin will only request those permission that are listed in the `AndroidManifest.xml`.

Manally request permission using
```dart
bool permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
```
You can also request SMS or Phone permissions separately using `requestSmsPermissions` or `requestPhonePermissions` respectively.

### Send SMS
:exclamation: Requires `SEND_SMS` permission.
Add the following permission in your `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.SEND_SMS"/>
```

SMS can either be sent directly or via the default SMS app.

#### Send SMS directly from your app:
```dart
telephony.sendSms(
	to: "1234567890",
	message: "May the force be with you!"
	);
```
If you want to listen to the status of the message being sent, provide `SmsSendStatusListener` to the `sendSms` function.
```dart
final SmsSendStatusListener listener = (SendStatus status) {
	// Handle the status
	};
	
telephony.sendSms(
	to: "1234567890",
	message: "May the force be with you!",
	statusListener: listener
	);
```
If the body of the message is longer than the standard SMS length limit of `160 characters`, you can send a multipart SMS by setting the `isMultipart` flag.

#### Send SMS via the default SMS app:
```dart
telephony.sendSmsByDefaultApp(to: "1234567890", message: "May the force be with you!");
```

### Query SMS
:exclamation: Requires `READ_SMS` permission.
Add the following permission in your `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.READ_SMS"/>
```

Use one of `getInboxSms()`, `getSentSms()` or `getDraftSms()` functions to query the messages on device.

You can provide the list of `SmsColumns` that need to be returned by the query.

If not explicitly specified, defaults to `[
  SmsColumn.ID,
  SmsColumn.ADDRESS,
  SmsColumn.BODY,
  SmsColumn.DATE
]`

Provide a `SmsFilter` to filter the results of the query. Functions like a `SQL WHERE` clause.

Provide a list of `OrderBy` objects to sort the results. The level of importance is determined by the position of `OrderBy` in the list.

All paramaters are optional.
```dart
List<SmsMessage> messages = await telephony.getInboxSms(
		columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
		filter: SmsFilter.where(SmsColumn.ADDRESS)
				 .equals("1234567890")
				 .and(SmsColumn.BODY)
				 .like("starwars"),
		sortOrder: [OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
			    OrderBy(SmsColumn.BODY)]
		);
```

### Query Conversations
:exclamation: Requires `READ_SMS` permission.
Add the following permission in your `AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.READ_SMS"/>
```

Works similar to [SMS queries](#query-sms). 

All columns are returned with every query. They are `[
  ConversationColumn.SNIPPET,
  ConversationColumn.THREAD_ID,
  ConversationColumn.MSG_COUNT
]`

Uses `ConversationFilter` instead of `SmsFilter`.

```dart
List<SmsConversation> messages = await telephony.getConversations(
		filter: ConversationFilter.where(ConversationColumn.MSG_COUNT)
					  .equals("4")
					  .and(ConversationColumn.THREAD_ID)
					  .greaterThan("12"),
		sortOrder: [OrderBy(ConversationColumn.THREAD_ID, sort: Sort.ASC)]
		);
```

### Listen to incoming SMS
:exclamation: Requires `RECEIVE_SMS` permission.

1. To listen to incoming SMS add the `RECEIVE_SMS` permission to your `AndroidManifest.xml` file and register the `BroadcastReceiver`.


	```xml
	<manifest>
		<uses-permission android:name="android.permission.RECEIVE_SMS"/>

		<application>
			...
			...

			<receiver android:name="com.shounakmulay.telephony.sms.IncomingSmsReceiver"
			    android:permission="android.permission.BROADCAST_SMS" android:exported="true">
			    <intent-filter>
				<action android:name="android.provider.Telephony.SMS_RECEIVED"/>
			    </intent-filter>
			</receiver>

		</application>
	</manifest>
	```

2. Create a **top-level static function** to handle incoming messages when app is not is foreground.

	:warning: Avoid heavy computations in the background handler as Android system may kill long running operations in the background.

	```dart
	backgrounMessageHandler(SmsMessage message) async {
		//Handle background message	
	}

	void main() {
	  runApp(MyApp());
	}
	```
3. Call `listenIncomingSms` with a foreground `MessageHandler` and pass in the static `backgrounMessageHandler`.
	```dart
	telephony.listenIncomingSms(
			onNewMessage: (SmsMessage message) {
				// Handle message
			},
			onBackgroundMessage: backgroundMessageHandler
		);
	```
	Preferably should be called early in app lifecycle.

4. If you do not wish to receive incoming SMS when the app is in background, just do not pass the `onBackgroundMessage` paramater. 

	Alternatively if you prefer to expecility disable background execution, set the `listenInBackground` flag to `false`.
	```dart
	telephony.listenIncomingSms(
			onNewMessage: (SmsMessage message) {
				// Handle message
			},
			listenInBackground: false
		);
	```

### Network data and metrics





## Features

 - [x] [Send SMS](#send-sms)
 - [x] Query SMS
	 - [x] Inbox
	 - [x] Sent
	 - [x] Draft
 - [x] Query Conversations
 - [x] Listen to incoming SMS
	 - [x] When app is in foreground
	 - [x] When app is in background
 - [x] Network data and metrics
	 - [x] Cellular data state
	 - [x] Call state
	 - [x] Data activity
	 - [x] Network operator
	 - [x] Network operator name
	 - [x] Data network type
	 - [x] Phone type
	 - [x] Sim operator
	 - [x] Sim operator name
	 - [x] Sim state
	 - [x] Network roaming
	 - [x] Signal strength
	 - [x] Service state
 - [ ] SMS Retriever API
 - [ ] Start Phone Call
 - [ ] iOS support
