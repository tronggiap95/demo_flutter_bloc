package com.octo.octo_beat_plugin.core.device.command

import com.octo.octo_beat_plugin.core.device._enum.RequestCode
import org.json.JSONArray
import org.msgpack.core.MessagePack
import java.io.ByteArrayOutputStream

class RequestSWmodeCmd {
    companion object {
        private val TAG = "MCTConfirmedCmd"
//        fun request(): ByteArray {
//            val jsonArray = JSONArray()
//
//            jsonArray.put(RequestCode.BB_REQ_SWITCH_BT_MODE.value)
//            return CommandUtils.packPacketRequest(pack(jsonArray))
//        }

        fun pack(jsonArray: JSONArray): ByteArray {
            val out = ByteArrayOutputStream()
            val packer = MessagePack.newDefaultPacker(out)
            try {
                packer.packArrayHeader(jsonArray.length())
                        .packInt(jsonArray.getInt(0))
                        .packString(jsonArray.getString(1))
                packer.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }

            return out.toByteArray()
        }
    }
}