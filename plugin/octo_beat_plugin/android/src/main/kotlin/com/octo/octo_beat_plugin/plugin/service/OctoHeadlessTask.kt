package com.octo.octo_beat_plugin.plugin.service

import android.content.Context
import android.content.res.AssetManager
import android.os.Handler
import com.octo.octo_beat_plugin.ForegroundService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.embedding.engine.loader.ApplicationInfoLoader
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.FlutterCallbackInformation
import java.util.ArrayDeque
import java.util.ArrayList
import java.util.concurrent.atomic.AtomicBoolean

data class OctoTask(val method: String, val data: Map<String, Any>?)

class OctoHeadlessTask(private val context: Context, private val task: OctoTask, private val callback: MethodChannel.Result?) : MethodChannel.MethodCallHandler, Runnable {
    private val queue = ArrayDeque<OctoTask>()
    private lateinit var mBackgroundChannel: MethodChannel

    companion object {
        @JvmStatic
        private  val initializeMethod = "octo_beat_plugin.octo_headless_task.initialized"
        @JvmStatic
        private  val pluginName = "com.octo.octo_beat_plugin.plugin.service/octo_headless_task/event"
        @JvmStatic
        private val octoHeadlessCallbackId = "octo_beat_plugin.OctoHeadlessTask_CALLBACK_ID"
        @JvmStatic
        val octoSharedReferencesKey = "octo_beat_plugin.octo_headless_task.preferences_key"
        @JvmStatic
        private var sOctoHeadlessTaskFlutterEngine: FlutterEngine? = null
        @JvmStatic
        private val sServiceStarted = AtomicBoolean(false)

        @JvmStatic
        fun saveCallbackId(context: Context, args: ArrayList<*>?) {
            val callbackId = args?.get(0) as Long?
            context.getSharedPreferences(octoSharedReferencesKey, Context.MODE_PRIVATE)
                .edit()
                .putLong(octoHeadlessCallbackId, callbackId ?:0)
                .apply()
        }

        @JvmStatic
        fun sendWork(context: Context, task: OctoTask, callback: MethodChannel.Result? = null) {
            Thread(OctoHeadlessTask(context, task, callback)).start()
        }
    }

    private fun getCallbackId(context: Context): Long {
        return context.getSharedPreferences(
            octoSharedReferencesKey,
            Context.MODE_PRIVATE
        )
            .getLong(octoHeadlessCallbackId, 0);
    }


    private fun startBackgroundPlugin(context: Context) {
        try {
            sOctoHeadlessTaskFlutterEngine = ForegroundService.headlessTaskFlutterEngine
            if (sOctoHeadlessTaskFlutterEngine == null) {
                synchronized(sServiceStarted) {
                    sOctoHeadlessTaskFlutterEngine = FlutterEngine(context)
                    val callbackId = getCallbackId(context)
                    if (callbackId == 0L) {
                        return
                    }
                    val callbackInfo =
                        FlutterCallbackInformation.lookupCallbackInformation(callbackId) ?: return
                    val info = ApplicationInfoLoader.load(context)
                    val appBundlePath = info.flutterAssetsDir

                    val assets: AssetManager = context.assets

                    val args = DartExecutor.DartCallback(
                        assets,
                        appBundlePath,
                        callbackInfo
                    )
                    sOctoHeadlessTaskFlutterEngine!!.dartExecutor.executeDartCallback(args)
                }
            }

            mBackgroundChannel = MethodChannel(
                sOctoHeadlessTaskFlutterEngine!!.dartExecutor.binaryMessenger,
                pluginName
            )
            mBackgroundChannel.setMethodCallHandler(this)

            //Remember engine
            ForegroundService.setBackgroundTasks(sOctoHeadlessTaskFlutterEngine)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }

    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments<ArrayList<*>>()
        when(call.method) {
            initializeMethod -> {
                synchronized(sServiceStarted) {
                    while (!queue.isEmpty()) {
                        val task =  queue.remove()
                        mBackgroundChannel.invokeMethod(task.method, task.data, callback)
                    }
                    sServiceStarted.set(true)
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }


    override fun run() {
        Handler(context.mainLooper).post {
            startBackgroundPlugin(context)
        }
        dispatch()
    }

    private fun dispatch() {
        try {
            synchronized(sServiceStarted) {
                if (!sServiceStarted.get()) {
                    // Queue up geofencing events while background isolate is starting
                    queue.add(task)
                } else {
                    // Callback method name is intentionally left blank.
                    Handler(context.mainLooper).post {
                        mBackgroundChannel.invokeMethod(task.method, task.data, callback)
                    }
                }
            }
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }
}