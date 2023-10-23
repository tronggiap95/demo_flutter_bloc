package com.octo.octo_beat_plugin.core.device.handler

import android.content.Context
import android.content.Intent
import android.util.Log
import com.octo.octo_beat_plugin.Constant
import com.octo.octo_beat_plugin.core.device.command.MCTTriggeredCmd
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import org.json.JSONArray

import com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION
import com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK
import com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM
import com.octo.octo_beat_plugin.core.device.command.CommandUtils
import com.octo.octo_beat_plugin.core.device.model.MCTInstance


class HandleTriggerMCT {

    companion object {
        val TAG = "HandleTriggerMCT"

        fun handle(dxhDevice: DXHDevice?,
                   packet: ByteArray,
                   messagePack: JSONArray,
                   context: Context?) {

            if (dxhDevice == null) {
                Log.w(TAG, "Device is null")
                return
            }

            checkValidation(dxhDevice, messagePack) { valid, data, triggerTime ->
                if (valid) {
                    sendEventBroadCast(dxhDevice, context,triggerTime)
                    dxhDevice.callback?.newMctEvent(dxhDevice)
                }
                val encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice)
                encryptedPacket?.let {
                    dxhDevice.send(it)
                }
            }

            Log.d(TAG, "RECEIVE MCT EVENT TRIGGER")
        }

        private fun sendEventBroadCast(dxhDevice: DXHDevice, context: Context?,deviceTriggerTime: Long) {
            dxhDevice.mctInstance = MCTInstance(System.currentTimeMillis() / 1000, null, deviceTriggerTime)

            val i = Intent(Constant.ACTION_MCT_EVENT_TRIGGERED)
                    .putExtra(Constant.DEVICE_ADDRESS, dxhDevice.bluetoothClient?.bluetoothDevice?.address)
            context?.sendBroadcast(i)
        }

        private fun checkValidation(dxhDevice: DXHDevice, messagePack: JSONArray, result: (Boolean, ByteArray, Long) -> Unit) {
            //Parse params
            val triggerTime = try {
                messagePack.getLong(1)
            } catch (e: Exception) {
                val data = MCTTriggeredCmd.response(BB_RSP_ERR_PARAM.value)
                result(false, data, 0)
                e.printStackTrace()
                return
            }


            //Check handshake
            if (!dxhDevice.handShaked) {
                val data = MCTTriggeredCmd.response(BB_RSP_ERR_PERMISSION.value)
                result(false, data, 0)
                return
            }

            //RESPONSE OK
            val data = MCTTriggeredCmd.response(BB_RSP_OK.value)
            result(true, data, triggerTime)
        }

        private fun inPayloadAlreadyHasInfo(payload: ByteArray): Boolean {
            val messagePack = MessagePackHelper.unpackRaw(payload)

            try {
                Log.d(TAG,
                        "info = ${(messagePack.asMapValue().keyValueArray[9].asArrayValue()[0])}")
                if (messagePack.asMapValue().keyValueArray[9].asArrayValue().list().isNotEmpty() &&
                        messagePack.asMapValue().keyValueArray[9].asArrayValue()[0].asStringValue().toString() != "None") {
                    Log.d(TAG, "Has info, don't need to insert info into packet")
                    return true
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            return false
        }

        private fun isExpiredEvent(handshakeTime: UInt, triggerTime: UInt): Boolean {
            return ((triggerTime + (Constant.MCT_EVENT_TRIGGERED_EXPIRED_TIME_MILLISECOND / 1000).toUInt()) < handshakeTime)
        }
    }
}