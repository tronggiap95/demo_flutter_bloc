package com.octo.octo_beat_plugin.core.ble

import android.content.Context
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient
import com.lib.terminalio.TIOPeripheral

class SimpleBluetoothClient(context: Context, bluetoothDevice: TIOPeripheral, callback: BluetoothConnectionCallback?) :
        BluetoothClient(context, bluetoothDevice, callback) {
    override fun connect() {
    }

    override fun close() {
    }

    override fun send(data: ByteArray): Int {
        return 0
    }

    override fun read(buffer: ByteArray): Int {
        return 0
    }

    override fun isConnected(): Boolean {
        return false
    }

}