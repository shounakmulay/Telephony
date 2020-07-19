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

Provide a `SmsFilter` to filter the results of the query.
Provide a list of `OrderBy` to sort the results. The level of importance is determined by the position of `OrderBy` in the list.
```dart
List<SmsMessage> messages = await telephony.getInboxSms()
```




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
