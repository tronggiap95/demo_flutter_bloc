package com.octo.octo_beat_plugin.core.device.command

import com.octo.octo_beat_plugin.core.device._enum.RequestCode
import org.json.JSONArray
import org.msgpack.core.MessagePack
import java.io.ByteArrayOutputStream

class ConfigECGCmd {
    companion object {
        private val TAG = "ConfigECGCmd"
        fun response(response: Int): ByteArray {
            val jsonArray = JSONArray()

            jsonArray.put(RequestCode.BB_CMD_ECG_PARAM_CONFIG.value)
            jsonArray.put(response)

            return pack(jsonArray)
        }

        fun pack(jsonArray: JSONArray): ByteArray {
            val out = ByteArrayOutputStream()
            val packer = MessagePack.newDefaultPacker(out)
            try {
                packer.packArrayHeader(jsonArray.length())
                        .packInt(jsonArray.getInt(0))
                        .packInt(jsonArray.getInt(1))
                packer.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }

            return out.toByteArray()
        }
    }
}