package com.octomed.octo360.package_plugin

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import com.octomed.octo360.BuildConfig
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*


class PackageManagerPlugin {
    enum class Method(val value:  String) {
        GET_PACKAGE_INFO("getPackageInfo"),
        GET_APP_VERSION("getAppVersion"),
    }

    companion object{
        private const val METHOD_CHANNEL= "com.octomed.octo360.package_manager.method_channel"

        @SuppressLint("StaticFieldLeak")
       private var context: Context? = null

        fun register(context: Context, flutterEngine: FlutterEngine) {
            this.context = context

            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler {
                    call, result ->
                when (call.method) {
                    Method.GET_PACKAGE_INFO.value -> {
                        val args = call.arguments as ArrayList<*>
                        getPackageInfo(args[0] as  String, result)
                    }

                    Method.GET_APP_VERSION.value -> {
                        result.success(BuildConfig.VERSION_NAME)
                    }
                }
            }
        }

        private fun getPackageInfo(packageName:  String, result: MethodChannel.Result) {
            try {
                context?.packageManager?.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES)
                result.success(true)
            }  catch (ex: Exception){
                result.success(false);
            }
        }
    }
}