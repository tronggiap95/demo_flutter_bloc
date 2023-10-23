package com.octomed.octo360.scanner;
import android.content.Context
import com.octomed.octo360.event.EventHandler
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class BleScannerPlugin(context: Context) : MethodChannel.MethodCallHandler,
    BleStateController.BluetoothStateListener {
    enum class Event(val value: String) {
        SCAN_RESULT("scanResult"),
        BLUETOOTH_STATE("bluetoothState"),
    }

    enum class Method(val value: String) {
        START_SCAN("startScan"),
        STOP_SCAN("stopScan"),
        IS_BLE_ENABLE("isBleEnable")
    }

    var bluetoothEventHandler = EventHandler()
    var mBleStateController: BleStateController = BleStateController.getDefaultBleController(context)

    companion object {
        fun registerWith(context: Context, flutterEngine: FlutterEngine) {
            val instance = BleScannerPlugin(context)
            val channel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "com.octomed.octo360.scanner/ble_scanner_plugin"
            )
            channel.setMethodCallHandler(instance)

            val bluetoothStateChannel = EventChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                "com.octomed.octo360.scanner/ble_scanner_plugin/bluetooth_state"
            )
            bluetoothStateChannel.setStreamHandler(instance.bluetoothEventHandler)
            instance.mBleStateController.setListener(instance)
        }

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            Method.IS_BLE_ENABLE.value -> {
                isBleEnable(result)
            }
        }
    }

    private fun isBleEnable(result: MethodChannel.Result) {
        result.success(mBleStateController.isBluetoothEnabled)
    }

    override fun onBluetoothOff() {
        val map = HashMap<String, Any>()
        map["state"] = "off"
        bluetoothEventHandler.send(Event.BLUETOOTH_STATE.value, map)
    }

    override fun onBluetoothOn() {
        val map = HashMap<String, Any>()
        map["state"] = "on"
        bluetoothEventHandler.send(Event.BLUETOOTH_STATE.value, map)
    }
}