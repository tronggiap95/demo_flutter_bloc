package com.octo.octo_beat_plugin.core.bluetooth

import android.content.Context
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.os.Message
import com.octo.octo_beat_plugin.core.ble.BluetoothConnectionCallback
import com.octo.octo_beat_plugin.core.model.ConnectionParams
import java.io.IOException

/**
 * Created by caoxuanphong on 12/15/17.
 */
class BluetoothConnectHandler(private val context: Context, private val callback: BluetoothConnectionCallback) : HandlerThread(""),
        Handler.Callback {
    lateinit var handler: Handler

    override fun onLooperPrepared() {
        super.onLooperPrepared()
        handler = Handler(Looper.myLooper()!!, this)
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
}