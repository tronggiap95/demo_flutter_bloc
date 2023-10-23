package com.octo.octo_beat_plugin.core.device.handler

import android.util.Log
import com.octo.octo_beat_plugin.core.device.command.CommandUtils
import com.octo.octo_beat_plugin.core.device.command.NotifyLowTCPSpeedCmd
import com.octo.octo_beat_plugin.core.device.model.DXHDevice

class NotifyLowTCPSpeedHandler {
    companion object {
        private val TAG = "StreamingECGHandler"

        fun handle(dxhDevice: DXHDevice?, speed: Int): Boolean {
            if (dxhDevice?.bluetoothClient == null) {
                Log.e(TAG, "handle: null")
                return false
            }
            for (tcpConnection in dxhDevice.tcpConnections) {
                val data = NotifyLowTCPSpeedCmd.response(tcpConnection.id, speed)
                val  encryptedPacket = CommandUtils.packPacketNotify(data, dxhDevice)
                encryptedPacket?.let {
                    dxhDevice.send(it)
                }
            }
            return true
        }
    }
}