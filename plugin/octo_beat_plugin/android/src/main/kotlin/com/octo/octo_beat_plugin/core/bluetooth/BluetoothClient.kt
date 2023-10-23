package com.octo.octo_beat_plugin.core.bluetooth

import android.content.Context
import com.octo.octo_beat_plugin.core.ble.BluetoothConnectionCallback
import com.lib.terminalio.TIOPeripheral

abstract class BluetoothClient(var context: Context, var bluetoothDevice: TIOPeripheral,
                               var callback: BluetoothConnectionCallback?): Thread() {
    abstract fun connect()
    abstract fun close()
    abstract fun send(data: ByteArray): Int
    abstract fun read(buffer: ByteArray): Int
    abstract fun isConnected() : Boolean
}