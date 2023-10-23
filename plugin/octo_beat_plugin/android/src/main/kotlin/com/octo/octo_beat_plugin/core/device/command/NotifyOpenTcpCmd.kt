package com.octo.octo_beat_plugin.core.device.command

import com.octo.octo_beat_plugin.core.device._enum.NotifyCode
import org.json.JSONArray
import org.msgpack.core.MessagePack
import java.io.ByteArrayOutputStream

object NotifyOpenTcpCmd {
    private val TAG = "NotifyTCPLostCmd"

    fun notify(connectionId: Int, isConnected: Boolean): ByteArray? {
        val jsonArray = JSONArray()
        jsonArray.put(NotifyCode.BB_NT_TCP_CONN_OPEN_REPORT.value)
        jsonArray.put(connectionId)
        jsonArray.put(isConnected)
        return pack(jsonArray)
    }

    fun pack(jsonArray: JSONArray): ByteArray? {
        val out = ByteArrayOutputStream()
        val packer = MessagePack.newDefaultPacker(out)
        try {
            packer.packArrayHeader(jsonArray.length())
                    .packInt(jsonArray.getInt(0))
                    .packInt(jsonArray.getInt(1))
                    .packBoolean(jsonArray.getBoolean(2))
            packer.close()
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
        return out.toByteArray()
    }
}