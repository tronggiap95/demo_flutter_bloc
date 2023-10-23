package com.octo.octo_beat_plugin.core.ble

import android.content.Context
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.Message
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClientFactory
import com.octo.octo_beat_plugin.core.model.ConnectionParams
import java.io.IOException

class BLEConnectHandler(private val context: Context, private val callback: BluetoothConnectionCallback) : HandlerThread(""),
        Handler.Callback {

    var handler: Handler? = null

    override fun onLooperPrepared() {
        super.onLooperPrepared()
        handler = Looper.myLooper()?.let { Handler(it, this) }
    }

    override fun handleMessage(msg: Message): Boolean {
        if (this.isAlive && !this.isInterrupted) {
            val bluetoothDevice = (msg.obj as ConnectionParams).bluetoothDevice
            val connectionType = (msg.obj as ConnectionParams).connectionType

            bluetoothDevice.let { device ->
                try {
                    val bleSocketClient = BluetoothClientFactory.create(connectionType, context, bluetoothDevice, callback)
                    bleSocketClient?.connect()
                } catch (e: IOException) {
                    e.printStackTrace()
                    callback?.didConnectFail(device)
                }
            }
        }

        return true
    }

    companion object {
        const val TAG = "BLEConnectHandler"
    }

}