package com.octomed.octo360

import android.os.Bundle
import com.octomed.octo360.package_plugin.PackageManagerPlugin
import com.octomed.octo360.scanner.BleScannerPlugin
import com.octomed.octo360.utils.KeyValueDB
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        KeyValueDB.putIsAppKilled(this, false)
        // Obtain the FirebaseAnalytics instance.
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BleScannerPlugin.registerWith(context.applicationContext, flutterEngine)
        PackageManagerPlugin.register(context.applicationContext, flutterEngine)
    }

    override fun onDestroy() {
        super.onDestroy()
        KeyValueDB.putIsAppKilled(this, true)
    }

}
