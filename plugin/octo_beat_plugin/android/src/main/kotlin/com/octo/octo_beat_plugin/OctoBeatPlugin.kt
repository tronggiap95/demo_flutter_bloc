package com.octo.octo_beat_plugin

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.lib.terminalio.TIOManager
import com.octo.octo_beat_plugin.plugin.connection.OctoBeatConnectionPlugin
import com.octo.octo_beat_plugin.plugin.event.OctoBeatEventPlugin
import com.octo.octo_beat_plugin.plugin.service.OctoServicePlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** OctoBeatPlugin */
class OctoBeatPlugin: FlutterPlugin, MethodCallHandler {
  private var mContext : Context? = null

  enum class Method(val value: String) {
    GET_DEVICE_INFO("getDeviceInfo"),
    SUBMIT_MCT_EVENT("submitMctEvent")
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    mContext = flutterPluginBinding.applicationContext
    val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "octo_beat_plugin")
    channel.setMethodCallHandler(this)
    Log.e("TAGGGGGGG", "onAttachedToEngine octo_beat plugin")
    //Children plugins
    TIOManager.initialize(mContext)
    OctoServicePlugin.registerWith(mContext!!, flutterPluginBinding.binaryMessenger)
    OctoBeatConnectionPlugin.registerWith(mContext!!, flutterPluginBinding.binaryMessenger)
    OctoBeatEventPlugin.registerWith(mContext!!, flutterPluginBinding.binaryMessenger)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val ctx = mContext ?: return
    val args = call.arguments<ArrayList<*>>()
    when (call.method) {
      Method.GET_DEVICE_INFO.value -> {
        // GET DEVICE INFO
        OctoBeatHelper.getInstance(ctx).getDeviceInfo(result)
      }
      Method.SUBMIT_MCT_EVENT.value -> {
        // SUBMIT MCT EVENT
        OctoBeatHelper.getInstance(ctx).submitMctEvent(args, result)
      }
      else -> result.notImplemented()
    }
  }
}
