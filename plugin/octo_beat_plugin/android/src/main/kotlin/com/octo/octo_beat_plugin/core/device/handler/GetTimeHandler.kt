package com.octo.octo_beat_plugin.core.device.handler

import android.util.Log
import com.octo.octo_beat_plugin.core.device._enum.ResponseCode
import com.octo.octo_beat_plugin.core.device.command.CommandUtils
import com.octo.octo_beat_plugin.core.device.command.GetTimeCmd
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.utils.DateTimeUtils


object GetTimeHandler {
    val TAG = "GetTimeHandler"
    fun handle(dxhDevice: DXHDevice?) {
        if (dxhDevice == null) {
            Log.w(HandleTriggerMCT.TAG, "Device is null")
            return
        }

        //Check handshake
        if (!dxhDevice.handShaked) {
            val data = GetTimeCmd.response(ResponseCode.BB_RSP_ERR_PERMISSION.value, 0, 0)
            val encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice)
            encryptedPacket?.let {
                dxhDevice.send(it)
            }
            return
        }

        //RESPONSE OK
        DateTimeUtils.getTrueTimeUTCInSecond { time ->
            val localTime = time + DateTimeUtils.getOffsetFromUtc()
            val data = GetTimeCmd.response(ResponseCode.BB_RSP_OK.value, uctTime = localTime, timezone = DateTimeUtils.getTimezoneInMinute())
            val encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice)
            encryptedPacket?.let {
                dxhDevice.send(it)
            }
        }

    }
}
