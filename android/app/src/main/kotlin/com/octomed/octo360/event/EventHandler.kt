package com.octomed.octo360.event;

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import java.util.*

class EventHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

//    fun send(task: BioTask) {
//        Handler(Looper.getMainLooper()).post {
//            eventSink?.success(mapOf(
//                "event" to task.method,
//                "body" to task.data
//            ))
//        }
//    }

    fun send(event: String, body: Map<String, Any>?) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(mapOf("event" to event, "body" to body))
        }
    }

    fun send(event: String, body: ArrayList<HashMap<String, String>>) {
        Handler(Looper.getMainLooper()).post {
            eventSink?.success(mapOf("event" to event, "body" to body))
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}