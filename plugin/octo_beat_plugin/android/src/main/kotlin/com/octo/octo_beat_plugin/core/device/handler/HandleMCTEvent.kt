package com.octo.octo_beat_plugin.core.device.handler

import android.util.Log
import com.octo.octo_beat_plugin.Constant
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.model.MCTInstance
import com.octo.octo_beat_plugin.core.model.Packet
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import org.json.JSONObject
import org.msgpack.core.MessagePack
import org.msgpack.value.Value
import java.io.ByteArrayOutputStream

class HandleMCTEvent {
    companion object {
        val TAG = "HandleMCTEvent"

        fun handle(dxhDevice: DXHDevice?, connectionId: Int, packet: Packet) {
            if (dxhDevice == null) {
                Log.w(TAG, "device is null")
                return
            }

            val messagePack = MessagePackHelper.unpackRaw(packet.payloadData)

            val eventMCTTime = try {
                messagePack.asMapValue().keyValueArray[3].asFloatValue().toLong()
            } catch (e: Exception) {
                e.printStackTrace()
                dxhDevice.sendDataToTCPServer(dxhDevice, connectionId, packet.buildOriginalPacket())
                return
            }

            val handshakeTime = dxhDevice.handShakeTime
            var mctInstance: MCTInstance? = dxhDevice.mctInstance

            // No mct trigger events
            if (mctInstance == null) {
                Log.w(TAG, "No mct trigger event before")
                dxhDevice.sendDataToTCPServer(dxhDevice, connectionId, packet.buildOriginalPacket())
                return
            }

            if (inPayloadAlreadyHasInfo(packet.payloadData)) {
                dxhDevice.sendDataToTCPServer(dxhDevice, connectionId, packet.buildOriginalPacket())
                return
            }

            Log.d(TAG, "HANDSHAKED TIME $handshakeTime, MCTTRIGGEREVENT ${mctInstance!!.triggerTime}")
            if (!isValidPacket(handshakeTime!!, mctInstance!!.triggerTime.toInt())) {
                Log.w(TAG, "invalid packet")
                dxhDevice.sendDataToTCPServer(dxhDevice, connectionId, packet.buildOriginalPacket())
                return
            }

            try {
                packet.payloadData = insertUserChosenIntoPayload(messagePack, mctInstance!!.chosenSymtoms)
            } catch (e: Exception) {
                e.printStackTrace()
            }

            Log.d(TAG, "SEND MCT EVENT TO SERVER = ${MessagePackHelper.unpackRaw(packet.payloadData).toJson()}")
            dxhDevice.sendDataToTCPServer(dxhDevice, connectionId, packet.buildPacket())

            dxhDevice.mctInstance = null
//            Log.d(TAG, "edited message pack = ${MessagePackHelper.unpackRaw(packet.payloadData).toJson()}")
        }

        private fun inPayloadAlreadyHasInfo(payload: ByteArray): Boolean {
            val messagePack = MessagePackHelper.unpackRaw(payload)

            try {
                Log.d(HandleTriggerMCT.TAG,
                        "info = ${(messagePack.asMapValue().keyValueArray[9].asArrayValue()[0])}")
                if (messagePack.asMapValue().keyValueArray[9].asArrayValue().list().isNotEmpty() &&
                        messagePack.asMapValue().keyValueArray[9].asArrayValue()[0].asStringValue().toString() != "None") {
                    Log.d(HandleTriggerMCT.TAG, "Has info, don't need to insert info into packet")
                    return true
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            return false
        }

        private fun isValidPacket(handshakeTime: Int,
                                  triggerTime: Int): Boolean {
            return ((triggerTime +
                    ((Constant.MCT_EVENT_TRIGGERED_EXPIRED_TIME_MILLISECOND / 1000)))
                    >= handshakeTime)
        }

        private fun insertUserChosenIntoPayload(messagePackValue: Value, info: ArrayList<String>?): ByteArray {
            val outByteStream = ByteArrayOutputStream()
            val messagePacker = MessagePack.newDefaultPacker(outByteStream)
            val originJsonObj = JSONObject(messagePackValue.toJson())

            messagePacker.packMapHeader(8).packString("nt").packString(originJsonObj.get("nt") as String?).packString("t").packInt(originJsonObj.get("t") as Int).packString("ack").packBoolean(originJsonObj.get("ack") as Boolean).packString("type").packString(originJsonObj.get("type") as String).packString("info")

            if (info == null || info!!.isEmpty()) {
                messagePacker.packArrayHeader(1)
                messagePacker.packString("None")
            } else {
                messagePacker.packArrayHeader(info.size)
                for (s in info) {
                    messagePacker.packString(s)
                }
            }

            messagePacker.packString("preEv").packInt(originJsonObj.get("postEv") as Int)
            messagePacker.packString("postEv").packInt(originJsonObj.get("postEv") as Int)

            val hfJsonObj = JSONObject(originJsonObj.get("hr").toString())
            messagePacker.packString("hr")
            messagePacker.packMapHeader(6)
            messagePacker.packString("resume").packInt(hfJsonObj.get("resume") as Int).packString("stop").packInt(hfJsonObj.get("stop") as Int).packString("count").packInt(hfJsonObj.get("count") as Int).packString("min").packInt(hfJsonObj.get("min") as Int).packString("avg").packInt(hfJsonObj.get("avg") as Int).packString("max").packInt(hfJsonObj.get("max") as Int)

            messagePacker.close()
            return outByteStream.toByteArray()
        }
    }
}