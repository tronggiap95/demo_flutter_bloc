package com.octo.octo_beat_plugin.plugin.connection

import android.content.Context
import android.os.Handler
import android.util.Log
import com.octo.octo_beat_plugin.plugin.event.EventHandler
import com.octo.octo_beat_plugin.plugin.service.OctoTask
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class OctoBeatConnectionPlugin : MethodChannel.MethodCallHandler, OctoBeatConnectionCallback {

    private val methodChannel =
        "com.octo.octo_beat_plugin.plugin.connection/method"
    private val eventChannel =
        "com.octo.octo_beat_plugin.plugin.connection/event"

    enum class Method(val value: String) {
        START_SCAN("startScan"),
        STOP_SCAN("stopScan"),
        CONNECT("connect"),
        DELETE_DEVICE("deleteDevice"),
    }

    enum class Event(val value: String) {
        FOUND_DEVICES("foundDevice"),
        CONNECT_SUCCESS("connectSuccess"),
        CONNECT_FAIL("connectFailed"),
    }

    private var mContext: Context? = null
    private val eventHandler = EventHandler()

    companion object {
        val instance = OctoBeatConnectionPlugin()
        fun registerWith(context: Context, binaryMessenger: BinaryMessenger) {
            instance.mContext = context.applicationContext
            //SET METHODS CHANNEL
            val channel = MethodChannel(binaryMessenger, instance.methodChannel)
            channel.setMethodCallHandler(instance)

            //SET EVENT CHANNEL
            val eventChannel = EventChannel(
                binaryMessenger,
                instance.eventChannel
            )
            eventChannel.setStreamHandler(instance.eventHandler)

           //REGISTER CORE EVENTS
            OctoBeatConnectionHelper.getInstance(context).setConnectionCallback(instance)
        }
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val args = call.arguments<ArrayList<*>>()
        when (call.method) {
            Method.START_SCAN.value -> {
                mContext?.let {
                    //Start scan listener must be handled in main thread.
                    Handler(mContext!!.mainLooper).post {
                        OctoBeatConnectionHelper.getInstance(it).handleStartScan(result)
                    }
                }
            }
            Method.STOP_SCAN.value -> {
                mContext?.let {
                    OctoBeatConnectionHelper.getInstance(it).handleStopScan(result)
                }
            }
            Method.CONNECT.value -> {
                mContext?.let {
                    OctoBeatConnectionHelper.getInstance(it).requestConnectToDeviceBLE(args, result)
                }
            }
            Method.DELETE_DEVICE.value -> {
                mContext?.let {
                    OctoBeatConnectionHelper.getInstance(it).deleteDevice(result)
                }
            }
            else -> result.notImplemented()
        }
    }

    // OctoBeatConnectionCallback
    override fun onFoundOctoBeat(devices: ArrayList<Map<String, String>>) {
        val data = mapOf("devices" to devices)
        Log.e("onFoundOctoBeat", "")
        eventHandler.send(OctoTask(Event.FOUND_DEVICES.value, data))
    }

    override fun onConnectedOctoBeat(device: Map<String, String>) {
        Log.e("onConnectedOctoBeat", "")
        eventHandler.send(OctoTask(Event.CONNECT_SUCCESS.value, device))
    }

    override fun onConnectFailOctoBeat() {
        Log.e("onConnectFailOctoBeat", "")
        eventHandler.send(OctoTask(Event.CONNECT_FAIL.value, null))
    }

}