package com.octo.octo_beat_plugin.plugin.service

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class OctoServicePlugin : MethodChannel.MethodCallHandler {
    private val  methodChannel =
        "com.octo.octo_beat_plugin.plugin.service/method"

    enum class Method(val value: String) {
        START_SERVICE("startService"),
        STOP_SERVICE("stopService"),
        INITIALIZE_HEADLESS_SERVICE("initializeHeadlessService"),
    }

    private var mContext: Context? = null;

    companion object {
        fun registerWith(context: Context, binaryMessenger: BinaryMessenger) {
            val instance = OctoServicePlugin()
            instance.mContext = context.applicationContext
            //SET METHODS CHANNEL
            val channel = MethodChannel(binaryMessenger, instance.methodChannel)
            channel.setMethodCallHandler(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            Method.START_SERVICE.value -> {
                mContext?.let {
                    OctoServiceHelper.getInstance(it).startService()
                    result.success(true)
                }
            }

            Method.STOP_SERVICE.value -> {
                mContext?.let {
                    OctoServiceHelper.getInstance(it).stopService()
                    result.success(true)
                }
            }

            Method.INITIALIZE_HEADLESS_SERVICE.value -> {
                mContext?.let {
                    OctoHeadlessTask.saveCallbackId(it, call.arguments as? ArrayList<*>)
                    result.success(true)
                }
            }
        }
    }

}