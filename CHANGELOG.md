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

