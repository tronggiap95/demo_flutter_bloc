package com.octo.octo_beat_plugin.core.device

import android.util.Log
import com.octo.octo_beat_plugin.core.device._enum.NotifyCode
import com.octo.octo_beat_plugin.core.device.handler.DeviceStatusNotificationHandler
import com.octo.octo_beat_plugin.core.device.handler.NotifyECGDataHandler
import com.octo.octo_beat_plugin.core.device.handler.TransmitDataHandler
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.model.Packet
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import com.octo.octo_beat_plugin.core.utils.MyLog

class NotifyContainerHandler: ContainerHandler {
    private val TAG = "NotifyContainerHandler"
    private val TAG_HANDLER = "DEVICE_HANDLER_LOG"
    private val typeLog = MyLog.TypeLog.DEBUG

    override fun handle(code: Int, dxhDevice: DXHDevice, packet: ByteArray, deviceHandlerCallback: DeviceHandlerCallback) {
        val messagePack = MessagePackHelper.unpack(packet)
        if (messagePack == null) {
            Log.e(TAG, "receivedPacket: messagePack is null")
            return
        }
        when(NotifyCode.get(code)){
            NotifyCode.BB_NT_DEVICE_STATUS -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_NT_DEVICE_STATUS")
                DeviceStatusNotificationHandler.handle(dxhDevice!!, messagePack, deviceHandlerCallback!!)
            }

            NotifyCode.BB_NT_ECG_DATA -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_NT_ECG_DATA")
                NotifyECGDataHandler.handle(dxhDevice!!, packet, deviceHandlerCallback!!)
            }

            NotifyCode.BB_NT_TCP_TX_DATA -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_NT_TCP_TX_DATA")
                //            tcpDataHandler?.readTCPData(packet.payloadData)
                TransmitDataHandler.handle(dxhDevice, packet)
            }
            else -> {}
        }
    }
}