package com.octo.octo_beat_plugin.core.device.command

import android.util.Log
import com.octo.octo_beat_plugin.core.device._enum.RequestCode
import com.octo.octo_beat_plugin.core.device._enum.ResponseCode
import org.json.JSONArray
import org.msgpack.core.MessagePack
import java.io.ByteArrayOutputStream

object GetTimeCmd {
    private val TAG = "GetTimeCmd"
    fun response(response: Int, uctTime: Long, timezone: Int): ByteArray? {
        if (response != ResponseCode.BB_RSP_OK.value && response != ResponseCode.BB_RSP_ERR_PERMISSION.value) {
            Log.e(TAG, "GetTimeCmd response: invalid response code")
            return null
        }

        val jsonArray = JSONArray()
        jsonArray.put(RequestCode.BB_REQ_GET_TIME.value)
        jsonArray.put(response)

        if (response == ResponseCode.BB_RSP_OK.value) {
            jsonArray.put(uctTime)
            jsonArray.put(timezone)
        }

        return pack(jsonArray)
    }

    private fun pack(jsonArray: JSONArray): ByteArray? {
        val out = ByteArrayOutputStream()
        val packer = MessagePack.newDefaultPacker(out)
        try {
            packer.packArrayHeader(jsonArray.length())
                    .packInt(jsonArray.getInt(0))
                    .packInt(jsonArray.getInt(1))
            if (jsonArray.length() == 4) {
                packer.packLong(jsonArray.getLong(2))
                packer.packInt(jsonArray.getInt(3))
            }

            packer.close()
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
        return out.toByteArray()
    }
}