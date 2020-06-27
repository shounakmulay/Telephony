package com.shounakmulay.flutter_sms.sms

import android.app.ActivityManager
import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Telephony
import android.telephony.SmsMessage
import androidx.work.*
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFERENCES_NAME
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFS_BACKGROUND_MESSAGE_HANDLE
import com.shounakmulay.flutter_sms.utils.Constants.SHARED_PREFS_BACKGROUND_SETUP_HANDLE
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import io.flutter.view.FlutterNativeView
import io.flutter.view.FlutterRunArguments
import java.lang.Exception
import java.util.*
import java.util.concurrent.CountDownLatch
import java.util.concurrent.atomic.AtomicBoolean


class IncomingSmsReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent?) {
    val smsList = Telephony.Sms.Intents.getMessagesFromIntent(intent)
    smsList.forEach { sms ->
      if (IncomingSmsHandler.isApplicationForeground(context.applicationContext)) {
        // TODO: Use foreground channel
      } else {
        val workRequest = OneTimeWorkRequestBuilder<IncomingSmsHandler>().build()
        WorkManager.getInstance(context).enqueue(workRequest)
      }
    }
  }
}

class IncomingSmsHandler(private val context: Context, private val workerParams: WorkerParameters) : CoroutineWorker(context, workerParams), MethodChannel.MethodCallHandler {


  init {
    backgroundContext = applicationContext
    flutterLoader.ensureInitializationComplete(backgroundContext, null)

    if (!isIsolateRunning.get()) {
      val preferences = backgroundContext.getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
      val backgroundCallbackHandle = preferences.getLong(SHARED_PREFS_BACKGROUND_SETUP_HANDLE, 0)
      startBackgroundIsolate(backgroundContext, backgroundCallbackHandle)
    }
  }

  companion object {
    private lateinit var backgroundContext: Context
    private val backgroundMessageQueue = Collections.synchronizedList(mutableListOf<SmsMessage>())
    private var flutterLoader = FlutterLoader.getInstance()

    private lateinit var backgroundFlutterView: FlutterNativeView
    private lateinit var backgroundChannel: MethodChannel

    private var backgroundMessageHandle: Long? = null
    private var isIsolateRunning = AtomicBoolean(false)

    fun onInitialized() {
      isIsolateRunning.set(true)
      synchronized(backgroundMessageQueue) {

        // Handle all the messages received before the Dart isolate was
        // initialized, then clear the queue.
        val iterator = backgroundMessageQueue.iterator()
        while (iterator.hasNext()) {
          executeDartCallbackInBackgroundIsolate(backgroundContext, iterator.next(), null)
        }
        backgroundMessageQueue.clear()
      }
    }

    fun startBackgroundIsolate(context: Context, callbackHandle: Long) {
      flutterLoader.ensureInitializationComplete(context, null)
      val appBundlePath = flutterLoader.findAppBundlePath()
      val flutterCallback = FlutterCallbackInformation.lookupCallbackInformation(callbackHandle)

      // Note that we're passing `true` as the second argument to our
      // FlutterNativeView constructor. This specifies the FlutterNativeView
      // as a background view and does not create a drawing surface.
      backgroundFlutterView = FlutterNativeView(context, true)

      val args = FlutterRunArguments()
      args.bundlePath = appBundlePath
      args.entrypoint = flutterCallback.callbackName
      args.libraryPath = flutterCallback.callbackLibraryPath
      backgroundFlutterView.runFromBundle(args)
    }

    private fun executeDartCallbackInBackgroundIsolate(
        context: Context, message: SmsMessage, latch: CountDownLatch?) {
      if (!this::backgroundChannel.isInitialized) {
        throw RuntimeException(
            "setBackgroundChannel was not called before messages came in, exiting.")
      }

      // If another thread is waiting, then wake that thread when the callback returns a result.
      var result: MethodChannel.Result? = null
      if (latch != null) {
        result = LatchResult(latch).getResult()
      }
      val args: MutableMap<String, Any?> = HashMap()
      if (backgroundMessageHandle == null) {
        backgroundMessageHandle = getBackgroundMessageHandle(context)
      }
      args["handle"] = backgroundMessageHandle
      // TODO: Add SmsMessage.toMap() to args
      backgroundChannel.invokeMethod("handleBackgroundMessage", args, result)
    }

    fun setBackgroundChannel(channel: MethodChannel) {
      backgroundChannel = channel
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

    fun getBackgroundMessageHandle(context: Context): Long {
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

  }

  override suspend fun doWork(): Result {
    return if (!isIsolateRunning.get()) {
      // TODO: ADD message to background queue
      Result.retry()
    } else {
      try {
        // TODO executeDartCallbackInBackgroundIsolate()
        Result.success()
      } catch (e: Exception) {
        Result.failure()
      }
    }
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if ("initialized" == call.method) {
      onInitialized()
    }
  }


}

class LatchResult(latch: CountDownLatch) {
  private val result: MethodChannel.Result

  init {
    result = object : MethodChannel.Result {
      override fun success(result: Any?) {
        latch.countDown()
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        latch.countDown()
      }

      override fun notImplemented() {
        latch.countDown()
      }
    }
  }

  fun getResult(): MethodChannel.Result {
    return result
  }
}