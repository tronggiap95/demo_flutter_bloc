package com.octo.octo_beat_plugin.plugin.event

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.octo.octo_beat_plugin.plugin.service.OctoTask
import io.flutter.plugin.common.EventChannel

class EventHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    fun send(task: OctoTask) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(mapOf(
                "event" to task.method,
                "body" to task.data
            ))

        }
    }

    fun send(event: String, body: Map<String, Any>?) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(mapOf("event" to event, "body" to body))
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}