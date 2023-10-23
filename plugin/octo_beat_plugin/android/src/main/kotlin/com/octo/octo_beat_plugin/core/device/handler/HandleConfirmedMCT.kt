package com.octo.octo_beat_plugin.core.device.handler

import android.util.Log
import com.octo.octo_beat_plugin.core.device.command.CommandUtils
import com.octo.octo_beat_plugin.core.device.command.MCTConfirmedCmd
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.model.MCTInstance
import com.octo.octo_beat_plugin.core.utils.ByteUtils
import org.json.JSONArray

class HandleConfirmedMCT {
    companion object {
        val TAG = "HandleConfirmedMCT"
        fun handle(dxhDevice: DXHDevice?,
                   mctInstance: MCTInstance,
                   symptoms: IntArray) {


            if (dxhDevice == null) {
                Log.w(TAG, "Device is null")
                return
            }

            if (dxhDevice.handShaked) {
                try {
                    val data = MCTConfirmedCmd.request(mctInstance.deviceTriggerTime, symptoms)

                    val encryptedPacket = CommandUtils.packPacketRequest(data, dxhDevice)
                    encryptedPacket?.let {
                        dxhDevice.send(it)
                        Log.d(TAG, "SEND CONFIRM MCT EVENT: ${ByteUtils.toHexString(data)}, TIME ${mctInstance.deviceTriggerTime}")
                    }

                } catch (e: Exception) {
                    e.printStackTrace()
                }

            }

        }

        fun handleResponse(dxhDevice: DXHDevice?,
                           messagePack: JSONArray) {

        }


    }
}