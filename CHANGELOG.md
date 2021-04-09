## 0.1.3
* Now you can add a list of addresses without using a semi-colon (;) to separate the addresses.


## 0.1.2
* Change invokeMethod call type for getSms methods to List? (No change to telephony API)

## 0.1.1
* Added background instance for executing telephony methods in background.
* Fix type cast issues.

## 0.1.0
* Feature equivalent of v0.0.9
* Enabled null-safety

## 0.0.9
* Fix sendSms Future never completes.

## 0.0.8
* Upgrade platform version.

## 0.0.7
* Fix build error when plugin included in iOS project.

## 0.0.6
* Multipart messages are grouped as one single SMS so that listenSms functions only get triggered once.

## 0.0.5
* Fix background execution error due to FlutterLoader.getInstance() deprecation.

## 0.0.4

#### New Features:
* Start phone calls from default dialer or directly from the app.

## 0.0.3

#### Changes:
* Fix unresponsive foreground methods after starting background isolate.


## 0.0.2

#### Possible breaking changes:
* sendSms functions are now async.

#### Other changes:
* Adding documentation.
* Fix conflicting class name (Column --> TelephonyColumn).
* Update plugin description.


## 0.0.1

* First release of telephony

