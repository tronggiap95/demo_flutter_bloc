package com.octo.octo_beat_plugin.core.modes

import android.bluetooth.BluetoothDevice
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.lib.terminalio.TIOPeripheral

interface CoreBleModeCallback{
    fun onFailedConnection(bluetoothDevice: TIOPeripheral)
    fun onLostConnection(dxhDevice: DXHDevice)
    fun onNewConnection(bluetoothClient: BluetoothClient)
    fun onNewDevice(dxhDevice: DXHDevice)

    fun onNewMctEvent(dxhDevice: DXHDevice)

    fun updateInfo(dxhDevice: DXHDevice)

    fun updateECGData(dxhDevice: DXHDevice?)

    fun removeDeviceConnection(dxhDevice: DXHDevice?)

    fun receivedPacketIncorrectCRC(dxhDevice: DXHDevice?)

    fun receivedInvalidStatusCode(dxhDevice: DXHDevice?)

    fun receivedInvalidPacketLength(dxhDevice: DXHDevice?)

    fun receivedTimeOut(dxhDevice: DXHDevice?)
}