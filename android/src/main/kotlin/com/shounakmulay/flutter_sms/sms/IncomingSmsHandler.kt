package com.shounakmulay.flutter_sms.sms

import android.app.ActivityManager
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Telephony
import android.telephony.SmsMessage
import android.util.Log
import com.shounakmulay.flutter_sms.utils.Constants
import com.shounakmulay.flutter_sms.utils.Constants.MESSAGE_BODY
import com.shounakmulay.flutter_sms.utils.Constants.ON_MESSAGE
import com.shounakmulay.flutter_sms.utils.Constants.ORIGINATING_ADDRESS
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFERENCES_NAME
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFS_BACKGROUND_MESSAGE_HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFS_BACKGROUND_SETUP_HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.STATUS
import com.shounakmulay.flutter_sms.utils.Constants.TIMESTAMP
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
      if (IncomingSmsHandler.isApplicationForeground(context)) {
        val args = HashMap<String, Any>()
        args["message"] = sms.toMap()
        foregroundSmsChannel?.invokeMethod(ON_MESSAGE, args)
      } else {
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
  }
}

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

const val TAG = "IncomingSmsHandler"

object IncomingSmsHandler : MethodChannel.MethodCallHandler {
  internal val backgroundMessageQueue = Collections.synchronizedList(mutableListOf<SmsMessage>())
  internal var flutterLoader = FlutterLoader.getInstance()
  internal var isIsolateRunning = AtomicBoolean(false)

  internal lateinit var backgroundContext: Context
  private lateinit var backgroundChannel: MethodChannel
  private lateinit var backgroundFlutterEngine: FlutterEngine

  private var backgroundMessageHandle: Long? = null

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

  internal fun executeDartCallbackInBackgroundIsolate(context: Context, message: HashMap<String, Any?>) {
    if (!this::backgroundChannel.isInitialized) {
      throw RuntimeException(
          "setBackgroundChannel was not called before messages came in, exiting.")
    }

    val args: MutableMap<String, Any?> = HashMap()
    if (backgroundMessageHandle == null) {
      backgroundMessageHandle = getBackgroundMessageHandle(context)
    }
    args["handle"] = backgroundMessageHandle
    args["message"] = message
    // TODO: Add SmsMessage.toMap() to args
    backgroundChannel.invokeMethod("handleBackgroundMessage", args)
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
    if ("backgroundServiceInitialized" == call.method) {
      Log.wtf(TAG, "Init received")
      onInitialized()
    }
  }
}