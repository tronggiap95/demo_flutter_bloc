package com.octo.octo_beat_plugin.core.bluetooth

import android.content.Context
import com.octo.octo_beat_plugin.core.ble.BluetoothConnectionCallback
import com.octo.octo_beat_plugin.core.device._enum.BluetoothConnectionType
import com.octo.octo_beat_plugin.core.ble.BLESocketClient
import com.lib.terminalio.TIOPeripheral

class BluetoothClientFactory()  {
    companion object {
        fun create(connectionType: BluetoothConnectionType, context: Context, bluetoothDevice: TIOPeripheral, callback: BluetoothConnectionCallback): BluetoothClient? {
            return when (connectionType){
                BluetoothConnectionType.BLUETOOTH_BLE -> {
                    BLESocketClient(context, bluetoothDevice, callback)
                }
//                BluetoothConnectionType.BLUETOOTH_CLASSIC -> {
//                    BluetoothSocketClient(context, null, callback)
//                }
                else -> return null
            }
        }
    }
}