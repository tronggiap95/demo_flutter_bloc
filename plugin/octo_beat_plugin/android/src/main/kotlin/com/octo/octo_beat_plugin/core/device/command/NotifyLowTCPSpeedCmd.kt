package com.octo.octo_beat_plugin.core.device.command

import com.octo.octo_beat_plugin.core.device._enum.NotifyCode
import com.octo.octo_beat_plugin.core.device._enum.RequestCode
import org.json.JSONArray
import org.msgpack.core.MessagePack
import java.io.ByteArrayOutputStream

class NotifyLowTCPSpeedCmd {
    companion object {
        private val TAG = "MCTConfirmedCmd"
        fun response(connectionId: Int, speed: Int): ByteArray {
            val jsonArray = JSONArray()

            jsonArray.put(NotifyCode.BB_NT_TCP_TX_SPEED.value)
            jsonArray.put(connectionId)
            jsonArray.put(speed)

            return pack(jsonArray)
        }

        fun pack(jsonArray: JSONArray): ByteArray {
            val out = ByteArrayOutputStream()
            val packer = MessagePack.newDefaultPacker(out)
            try {
                packer.packArrayHeader(jsonArray.length())
                        .packInt(jsonArray.getInt(0))
                        .packInt(jsonArray.getInt(1))
                        .packInt(jsonArray.getInt(2))
                packer.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }

            return out.toByteArray()
        }
    }
}