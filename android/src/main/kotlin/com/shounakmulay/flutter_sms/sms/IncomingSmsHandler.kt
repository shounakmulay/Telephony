package com.shounakmulay.flutter_sms.sms

import android.app.ActivityManager
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Telephony
import android.telephony.SmsMessage
import com.shounakmulay.flutter_sms.utils.Constants
import com.shounakmulay.flutter_sms.utils.Constants.HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.HANDLE_BACKGROUND_MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.MESSAGE_BODY
import com.shounakmulay.flutter_sms.utils.Constants.ON_MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.ORIGINATING_ADDRESS
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFERENCES_NAME
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFS_BACKGROUND_MESSAGE_HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFS_BACKGROUND_SETUP_HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.STATUS
import com.shounakmulay.flutter_sms.utils.Constants.TIMESTAMP
import com.shounakmulay.flutter_sms.utils.SmsAction
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterJNI
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import java.util.*
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.collections.HashMap


class IncomingSmsReceiver : BroadcastReceiver() {

  companion object {
    var foregroundSmsChannel: MethodChannel? = null
  }

  override fun onReceive(context: Context, intent: Intent?) {
    val smsList = Telephony.Sms.Intents.getMessagesFromIntent(intent)
    smsList.forEach { sms ->
      processIncomingSms(context, sms)
    }
  }

  /**
   * Calls [ON_MESSAGE] method on the Foreground Channel if the application is in foreground.
   *
   * If the application is not in the foreground and the background isolate is not running, it initializes the
   * background isolate. The SMS is added to a background queue that will be processed on the isolate is initialized.
   *
   * If the application is not in the foreground but the the background isolate is running, it calls the
   * [IncomingSmsHandler.executeDartCallbackInBackgroundIsolate] with the SMS.
   *
   */
  private fun processIncomingSms(context: Context, sms: SmsMessage) {
    if (IncomingSmsHandler.isApplicationForeground(context)) {
      val args = HashMap<String, Any>()
      args[MESSAGE] = sms.toMap()
      foregroundSmsChannel?.invokeMethod(ON_MESSAGE, args)
    } else {
      processInBackground(context, sms)
    }
  }

  private fun processInBackground(context: Context, sms: SmsMessage) {
    IncomingSmsHandler.apply {
      backgroundContext = context
      flutterLoader.ensureInitializationComplete(context.applicationContext, null)
      if (!isIsolateRunning.get()) {
        val preferences = backgroundContext.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val backgroundCallbackHandle = preferences.getLong(SHARED_PREFS_BACKGROUND_SETUP_HANDLE, 0)
        startBackgroundIsolate(backgroundContext, backgroundCallbackHandle)
        backgroundMessageQueue.add(sms)
      } else {
        executeDartCallbackInBackgroundIsolate(context, sms.toMap())
      }
    }
  }
}

/**
 * Convert the [SmsMessage] to a [HashMap]
 */
fun SmsMessage.toMap(): HashMap<String, Any?> {
  val smsMap = HashMap<String, Any?>()
  this.apply {
    smsMap[MESSAGE_BODY] = messageBody
    smsMap[TIMESTAMP] = timestampMillis
    smsMap[ORIGINATING_ADDRESS] = originatingAddress
    smsMap[STATUS] = status
  }
  return smsMap
}

/**
 * Handle all the background processing on received SMS
 * 
 * Call [setBackgroundSetupHandle] and [setBackgroundMessageHandle] before performing any other operations.
 * 
 * 
 * Will throw [RuntimeException] if [backgroundChannel] was not initialized by calling [startBackgroundIsolate] 
 * before calling [executeDartCallbackInBackgroundIsolate]
 */
object IncomingSmsHandler : MethodChannel.MethodCallHandler {

  internal val backgroundMessageQueue = Collections.synchronizedList(mutableListOf<SmsMessage>())
  internal var flutterLoader = FlutterLoader.getInstance()
  internal var isIsolateRunning = AtomicBoolean(false)

  internal lateinit var backgroundContext: Context
  private lateinit var backgroundChannel: MethodChannel
  private lateinit var backgroundFlutterEngine: FlutterEngine

  private var backgroundMessageHandle: Long? = null

  /**
   * Initializes a background flutter execution environment and executes the callback
   * to setup the background [MethodChannel]
   *
   * Also initializes the method channel on the android side
   */
  fun startBackgroundIsolate(context: Context, callbackHandle: Long) {
    flutterLoader.ensureInitializationComplete(context, null)
    val appBundlePath = flutterLoader.findAppBundlePath()
    val flutterCallback = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)

    val dartEntryPoint = DartExecutor.DartCallback(context.assets, appBundlePath, flutterCallback)

    backgroundFlutterEngine = FlutterEngine(context, flutterLoader, FlutterJNI())
    backgroundFlutterEngine.dartExecutor.executeDartCallback(dartEntryPoint)

    backgroundChannel = MethodChannel(backgroundFlutterEngine.dartExecutor, Constants.CHANNEL_SMS_BACKGROUND)
    backgroundChannel.setMethodCallHandler(this)
  }

  /**
   * Called when the background dart isolate has completed setting up the method channel
   * 
   * If any SMS were received during the background isolate was being initialized, it will process 
   * all those messages.
   */
  fun onInitialized() {
    isIsolateRunning.set(true)
    synchronized(backgroundMessageQueue) {

      // Handle all the messages received before the Dart isolate was
      // initialized, then clear the queue.
      val iterator = backgroundMessageQueue.iterator()
      while (iterator.hasNext()) {
        executeDartCallbackInBackgroundIsolate(backgroundContext, iterator.next().toMap())
      }
      backgroundMessageQueue.clear()
    }
  }

  /**
   * Invoke the method on background channel to handle the message
   */
  internal fun executeDartCallbackInBackgroundIsolate(context: Context, message: HashMap<String, Any?>) {
    if (!this::backgroundChannel.isInitialized) {
      throw RuntimeException(
          "setBackgroundChannel was not called before messages came in, exiting.")
    }

    val args: MutableMap<String, Any?> = HashMap()
    if (backgroundMessageHandle == null) {
      backgroundMessageHandle = getBackgroundMessageHandle(context)
    }
    args[HANDLE] = backgroundMessageHandle
    args[MESSAGE] = message
    backgroundChannel.invokeMethod(HANDLE_BACKGROUND_MESSAGE, args)
  }

  fun setBackgroundMessageHandle(context: Context, handle: Long) {
    backgroundMessageHandle = handle

    // Store background message handle in shared preferences so it can be retrieved
    // by other application instances.
    val preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
    preferences.edit().putLong(SHARED_PREFS_BACKGROUND_MESSAGE_HANDLE, handle).apply()

  }

  fun setBackgroundSetupHandle(context: Context, setupBackgroundHandle: Long) {
    // Store background setup handle in shared preferences so it can be retrieved
    // by other application instances.
    val preferences = context.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
    preferences.edit().putLong(SHARED_PREFS_BACKGROUND_SETUP_HANDLE, setupBackgroundHandle).apply()
  }

  private fun getBackgroundMessageHandle(context: Context): Long {
    return context
        .getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        .getLong(SHARED_PREFS_BACKGROUND_MESSAGE_HANDLE, 0)
  }

  fun isApplicationForeground(context: Context): Boolean {
    val keyguardManager = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
    if (keyguardManager.isKeyguardLocked) {
      return false
    }
    val myPid = Process.myPid()
    val activityManager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    var list: List<ActivityManager.RunningAppProcessInfo>
    if (activityManager.runningAppProcesses.also { list = it } != null) {
      for (aList in list) {
        var info: ActivityManager.RunningAppProcessInfo
        if (aList.also { info = it }.pid == myPid) {
          return info.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND
        }
      }
    }
    return false
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (SmsAction.fromMethod(call.method) == SmsAction.BACKGROUND_SERVICE_INITIALIZED) {
      onInitialized()
    }
  }
}