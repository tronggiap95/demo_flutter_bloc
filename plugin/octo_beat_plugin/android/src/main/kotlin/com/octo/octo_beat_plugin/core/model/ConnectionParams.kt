package com.octo.octo_beat_plugin.core.model

import android.bluetooth.BluetoothDevice
import com.octo.octo_beat_plugin.core.device._enum.BluetoothConnectionType
import com.lib.terminalio.TIOPeripheral

data class ConnectionParams(var bluetoothDevice : TIOPeripheral,
                            var connectionType: BluetoothConnectionType)