package com.octo.octo_beat_plugin.core.ble

import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient
import com.lib.terminalio.TIOPeripheral

interface BluetoothConnectionCallback {
    fun didConnectFail(bluetoothDevice: TIOPeripheral)
    fun didNewConnection(bluetoothClient: BluetoothClient): Boolean
    fun didLostConnection(bluetoothClient: BluetoothClient)
    fun onError(errorCode: Int)
}