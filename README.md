# Telephony
|:exclamation: This plugin currently only works on Android Platform|
|------------------------------------------------------------------|


A Flutter plugin to use telephony features such as
- Send SMS Messages
- Query SMS Messages
- Listen for incoming SMS
- Retrieve various network parameters

This plugin tries to replicate some of the functionality provided by Android's [Telephony](https://developer.android.com/reference/android/provider/Telephony) class.

Check the [Features section](https://github.com/shounakmulay/Telephony/tree/readme#Features) to see the list of implemented and missing features.




## Usage
To use this plugin add `telephony` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

## Get Started


## Features

 - [x] Send SMS
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
