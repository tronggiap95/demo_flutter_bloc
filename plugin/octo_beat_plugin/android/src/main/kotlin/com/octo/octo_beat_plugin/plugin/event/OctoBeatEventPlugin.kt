package com.octo.octo_beat_plugin.plugin.event

import android.content.Context
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.utils.KeyValueDB
import com.octo.octo_beat_plugin.plugin.service.OctoHeadlessTask
import com.octo.octo_beat_plugin.plugin.service.OctoTask
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class OctoBeatEventPlugin : OctoBeatEventCallback, FlutterPlugin,
    MethodChannel.MethodCallHandler {
    private val eventChannel = "com.octo.octo_beat_plugin.plugin.event/event"

    enum class Event(val value: String) {
        //DEVICE INFORMATION
        UPDATE_INFO("OctoBeat_updateInfo"),
        //MCT STATUS
        MCT_TRIGGER("OctoBeat_mctTrigger"),
    }

    private var mContext: Context? = null
    private val eventHandler = EventHandler()

    //*************************** FLUTTER PLUGIN FUNCTIONS ****************************************
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        //NO IMPLEMENTATION
    }

    companion object {
        val instance = OctoBeatEventPlugin()
        fun registerWith(context: Context, binaryMessenger: BinaryMessenger) {
            instance.mContext = context.applicationContext

            //SET EVENT CHANNEL
            val eventChannel = EventChannel(
                binaryMessenger,
                instance.eventChannel
            )
            eventChannel.setStreamHandler(instance.eventHandler)

            //REGISTER CORE EVENTS
            OctoBeatEventHelper.getInstance(context).setEventHandlerCallback(instance)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        mContext = binding.applicationContext
        OctoBeatEventHelper.getInstance(binding.applicationContext).setEventHandlerCallback(this)
        //SET EVENT CHANNEL
        val eventChannel = EventChannel(
            binding.binaryMessenger,
            eventChannel
        )
        eventChannel.setStreamHandler(eventHandler)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        //NO IMPLEMENTATION
    }

    //************************ DEVICE INFO UPDATES ************************************************
    override fun updateInfo(dxhDevice: DXHDevice) {
        val deviceMap = ObjectParser.parseDeviceInfo(dxhDevice)
        eventHandler.send(OctoTask(Event.UPDATE_INFO.value, deviceMap))
    }

    override fun newMCTEvent(dxhDevice: DXHDevice) {
        val mctInstance = dxhDevice.mctInstance
        val data = mapOf("mctEventTime" to (mctInstance?.deviceTriggerTime ?: 0))

        mContext?.let {
            val isAppKilled = KeyValueDB.isAppKilled(context = it)
            if (isAppKilled) {
                OctoHeadlessTask.sendWork(it, OctoTask(Event.MCT_TRIGGER.value, data))
            } else {
                eventHandler.send(OctoTask(Event.MCT_TRIGGER.value, data))
            }
        }
    }

}