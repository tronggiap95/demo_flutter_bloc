package com.octo.octo_beat_plugin.core.device.command

import com.octo.octo_beat_plugin.core.device._enum.RequestCode
import org.json.JSONArray
import org.msgpack.core.MessagePack
import java.io.ByteArrayOutputStream

class MCTConfirmedCmd {
    companion object {
        private val TAG = "MCTConfirmedCmd"
        fun request(time: Long, symptoms: IntArray): ByteArray {
            val jsonArray = JSONArray()

            jsonArray.put(RequestCode.BB_REQ_EVENT_CONFIRMED.value)
            jsonArray.put(time)
            jsonArray.put(symptoms)

            return pack(jsonArray, symptoms)
        }

        fun pack(jsonArray: JSONArray, symptoms: IntArray): ByteArray {
            val out = ByteArrayOutputStream()
            val packer = MessagePack.newDefaultPacker(out)
            try {
                packer.packArrayHeader(jsonArray.length())
                        .packInt(jsonArray.getInt(0))
                        .packInt(jsonArray.getInt(1))
                packer.packArrayHeader(symptoms.size)
                for (s in symptoms) {
                    packer.packInt(s)
                }
                packer.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }

            return out.toByteArray()
        }
    }
}