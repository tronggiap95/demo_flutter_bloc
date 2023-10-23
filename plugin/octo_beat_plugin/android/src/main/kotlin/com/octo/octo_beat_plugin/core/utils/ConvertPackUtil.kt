package com.octo.octo_beat_plugin.core.utils

import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import org.msgpack.core.MessageBufferPacker
import org.msgpack.core.MessagePack
import java.io.IOException

class ConvertPackUtil {
    companion object {
        @Throws(IOException::class, JSONException::class)
        fun convert(data: JSONObject): ByteArray {
            val packer = MessagePack.newDefaultBufferPacker()
            packJObject(packer, data)
            packer.close()
            return packer.toByteArray()
        }

        @Throws(IOException::class, JSONException::class)
        private fun packJObject(packer: MessageBufferPacker, data: JSONObject) {
            packer.packMapHeader(data.length())
            val keys = data.keys()
            while (keys.hasNext()) {
                val key = keys.next()
                packer.packString(key) // pack the key
                val value = data.get(key)
                if (value is JSONArray) {
                    packJArray(packer, value)
                } else if (value is JSONObject) {
                    packJObject(packer, value)
                } else {
                    packPrimitive(packer, value)
                }
            }
        }

        @Throws(IOException::class, JSONException::class)
        private fun packJArray(packer: MessageBufferPacker, data: JSONArray) {
            packer.packArrayHeader(data.length())
            for (i in 0 until data.length()) {
                val value = data.get(i)
                if (value is JSONObject) {
                    packJObject(packer, value)
                } else if (value is JSONArray) {
                    packJArray(packer, value)
                } else {
                    packPrimitive(packer, value)
                }
            }
        }

        @Throws(IOException::class)
        private fun packPrimitive(packer: MessageBufferPacker, value: Any) {
            if (value is String) {
                packer.packString(value)
            } else if (value is Int) {
                packer.packInt(value)
            } else if (value is Boolean) {
                packer.packBoolean(value)
            } else if (value is Double) {
                packer.packDouble(value)
            } else if (value is Long) {
                packer.packLong(value)
            } else {
                throw IOException("Invalid packing value of type " + value.javaClass.name)
            }
        }
    }
}