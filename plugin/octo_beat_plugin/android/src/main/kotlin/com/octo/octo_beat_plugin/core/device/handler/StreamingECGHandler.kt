package com.octo.octo_beat_plugin.core.device.handler

import android.util.Log
import com.octo.octo_beat_plugin.core.device._enum.RequestCode
import com.octo.octo_beat_plugin.core.device.command.CommandUtils
import com.octo.octo_beat_plugin.core.device.command.ECGStreamingCmd
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.utils.ByteUtils

class StreamingECGHandler {
    companion object {
        private val TAG = "StreamingECGHandler"

        fun start(dxhDevice: DXHDevice?): Boolean {
            if (dxhDevice?.bluetoothClient == null) {
                Log.e(TAG, "handle: null")
                return false
            }

            val data = ECGStreamingCmd.build(RequestCode.BB_REQ_START_STREAMING_ECG.value)

            val encryptedPacket = CommandUtils.packPacketRequest(data, dxhDevice)
            encryptedPacket?.let {
                dxhDevice.send(it)
                Log.d(TAG, "SEND BB_REQ_START_STREAMING_ECG: ${ByteUtils.toHexString(data)}")
            }
            return true
        }

        fun stop(dxhDevice: DXHDevice?): Boolean {
            if (dxhDevice?.bluetoothClient == null) {
                Log.e(TAG, "handle: null")
                return false
            }

            val data = ECGStreamingCmd.build(RequestCode.BB_REQ_STOP_STREAMING_ECG.value)
            val encryptedPacket = CommandUtils.packPacketRequest(data, dxhDevice)
            encryptedPacket?.let {
                dxhDevice.send(it)
                Log.d(TAG, "SEND BB_REQ_START_STREAMING_ECG: ${ByteUtils.toHexString(data)}")
            }

            return true
        }
    }
}