package com.octo.octo_beat_plugin.core.device.command

import org.json.JSONArray
import org.msgpack.core.MessagePack
import java.io.ByteArrayOutputStream

class ECGStreamingCmd {
    private val TAG = "ECGStreamingCmd"

    companion object {
        fun build(cmd: Int): ByteArray? {
            val jsonArray = JSONArray()
            jsonArray.put(cmd)
            return pack(jsonArray)
        }

        private fun pack(jsonArray: JSONArray): ByteArray? {
            val out = ByteArrayOutputStream()
            val packer = MessagePack.newDefaultPacker(out)
            try {
                packer.packArrayHeader(jsonArray.length())
                        .packInt(jsonArray.getInt(0))
                packer.close()
            } catch (e: Exception) {
                e.printStackTrace()
                return null
            }
            return out.toByteArray()
        }
    }
}