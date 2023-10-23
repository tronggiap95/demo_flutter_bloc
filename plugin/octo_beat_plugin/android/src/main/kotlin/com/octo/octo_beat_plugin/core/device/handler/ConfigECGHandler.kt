package com.octo.octo_beat_plugin.core.device.handler

import android.util.Log
import com.octo.octo_beat_plugin.core.device.DeviceHandlerCallback
import com.octo.octo_beat_plugin.core.device._enum.ResponseCode
import com.octo.octo_beat_plugin.core.device.command.CommandUtils
import com.octo.octo_beat_plugin.core.device.command.ConfigECGCmd
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.model.ECGConfig
import org.json.JSONArray
import java.lang.Exception

class ConfigECGHandler {
    companion object {
        private val TAG = "ConfigECGHandler"
        fun handle(dxhDevice: DXHDevice, messagePack: JSONArray, deviceHandlerCallback: DeviceHandlerCallback) {
            Log.d(TAG, "$messagePack")
            dxhDevice.ECGConfig = parse(messagePack)
            deviceHandlerCallback.updateECGData(dxhDevice)
        }

//        private fun responseOk(): ByteArray {
//            val responseOK = ConfigECGCmd.response(ResponseCode.BB_RSP_OK.value)
//            return CommandUtils.packPacketResponse(responseOK)
//        }
//
//        private fun responseFail(): ByteArray {
//            val responseFail = ConfigECGCmd.response(ResponseCode.BB_RSP_ERR_PARAM.value)
//            return CommandUtils.packPacketResponse(responseFail)
//        }

        private fun parse(messagePack: JSONArray): ECGConfig? {
            return try {
                val responseCode = messagePack.getInt(1)
                val gain = messagePack.getDouble(2)
                val channel = messagePack.getString(3)
                val sampleRate = messagePack.getInt(4)
                Log.d(TAG, "Parse ECG CONFIG FROM START ECG - CODE: ${ResponseCode.get(responseCode)}")
                Log.d(TAG, "Parse ECG CONFIG FROM START ECG - Gain: $gain Channel: $channel Sample: $sampleRate")
                if(ResponseCode.get(responseCode) != ResponseCode.BB_RSP_OK){
                    return null
                }
                ECGConfig(gain, channel, sampleRate)
            } catch (e: Exception) {
                e.printStackTrace()
                null
            }
        }
    }
}