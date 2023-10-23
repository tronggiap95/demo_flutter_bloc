package com.octo.octo_beat_plugin.core.device.handler

import com.octo.octo_beat_plugin.core.device._enum.ResponseCode
import com.octo.octo_beat_plugin.core.device.listener.ResponseListener
import com.octo.octo_beat_plugin.core.model.Packet
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import java.lang.Exception

class SwModeHandler {
    companion object {
        private val TAG = "SwModeHandler"
        fun handleResponse(packet: ByteArray, listener: ResponseListener?){
            try {
                val messagePack = MessagePackHelper.unpack(packet)
                val rspOk = messagePack.getInt(1)
                listener?.onResult(rspOk == ResponseCode.BB_RSP_OK.value)
            }catch (e: Exception){
                listener?.onResult(false)
                e.printStackTrace()
            }

        }
    }
}