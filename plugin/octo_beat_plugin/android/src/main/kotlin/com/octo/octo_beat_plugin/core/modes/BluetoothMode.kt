package com.octo.octo_beat_plugin.core.modes

import android.bluetooth.BluetoothDevice
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.lib.terminalio.TIOPeripheral
import java.util.ArrayList

interface BluetoothMode {
    fun devices(): List<DXHDevice>
    fun handleNewConnectedBluetoothSocket(bluetoothClient: BluetoothClient?, retrictConnect: Boolean)
    fun handleDisconnectedBluetoothSocket(bluetoothClient: BluetoothClient?)
    fun handleDisconnectedDevice(dxhDevice: DXHDevice?)
    fun requestConnectToDevice(bluetoothDevice: TIOPeripheral)
    fun isIgnoringDevice(address: String?): Boolean
    fun retrieveHandShakedDevice(): ArrayList<DXHDevice>
    fun closeConnection(dxhDevice: DXHDevice)
    fun removeDevice(dxhDevice: DXHDevice)
    fun retrieveDeviceByMacAddress(mac: String): DXHDevice?
    fun retrieveDevice(bluetoothClient: BluetoothClient?): DXHDevice?
    fun deleteDevice(dxhDevice: DXHDevice?)

    fun onBlueOff()
    fun onBlueOn()
}