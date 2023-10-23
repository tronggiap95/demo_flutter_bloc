package com.octo.octo_beat_plugin.core.device.handler

import android.util.Log
import com.octo.octo_beat_plugin.core.device.DeviceHandlerCallback
import com.octo.octo_beat_plugin.core.device._enum.CHANNEL
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.model.ECGConfig
import com.octo.octo_beat_plugin.core.device.model.ECGSample
import com.octo.octo_beat_plugin.core.utils.ByteUtils
import com.octo.octo_beat_plugin.core.utils.DeviceUtils
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import java.nio.ByteOrder
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStreamWriter


class NotifyECGDataHandler {
    companion object {
        private val TAG = "NotifyECGDataHandler"
        private var previousIndex = 0u
        private var lost = 0u
//        val bufferString: StringBuffer = StringBuffer(100*1024)


        fun handle(dxhDevice: DXHDevice, payloadData: ByteArray, deviceHandlerCallback: DeviceHandlerCallback) {
            val value = MessagePackHelper.unpackRaw(payloadData)
            val index = value.asArrayValue().get(1).asIntegerValue().toInt().toUInt()
//            Log.d(TAG, "indexECG: $index")
//            checkLostPacketIndex(index)
            val bin = value.asArrayValue().get(2).asBinaryValue().asByteArray()
            saveBinTobuffer(ByteUtils.toHexString(bin))
            dxhDevice.ECGData = bin
            deviceHandlerCallback.updateECGData(dxhDevice)
        }

        fun parseSampleECG(ECGConfig: ECGConfig, data: ByteArray): ECGSample? {
            val channels = DeviceUtils.convertChannel(ECGConfig.channel)
            val gain = ECGConfig.gain
            return when (channels.size) {
                1 -> parseOneChannel(channels, gain, data)
                2 -> parseTwoChannel(channels, gain, data)
                3 -> parseThreeChannel(channels, gain, data)
                else -> null
            }
        }

        private fun parseOneChannel(channels: ArrayList<CHANNEL>, gain: Double, data: ByteArray): ECGSample {
            val ch = ArrayList<Short>()
            for (i in 0..data.size - 2 step 2) {
                val sample = ByteUtils.subByteArray(data, i, 2)
                val value = ByteUtils.toShort(sample, ByteOrder.LITTLE_ENDIAN)
                ch.add(value)
            }
            return when (channels[0]) {
                CHANNEL.CH_1 -> ECGSample(ch, null, null)
                CHANNEL.CH_2 -> ECGSample(null, ch, null)
                CHANNEL.CH_3 -> ECGSample(null, null, ch)
            }
        }

        private fun parseTwoChannel(channels: ArrayList<CHANNEL>, gain: Double, data: ByteArray): ECGSample? {
            val data1 = ArrayList<Short>()
            val data2 = ArrayList<Short>()
            for (i in 0..data.size - 4 step 4) {
                val sample1 = ByteUtils.subByteArray(data, i, 2)
                val sample2 = ByteUtils.subByteArray(data, i + 2, 2)
                val value1 = ByteUtils.toShort(sample1, ByteOrder.LITTLE_ENDIAN)
                val value2 = ByteUtils.toShort(sample2, ByteOrder.LITTLE_ENDIAN)
                data1.add(value1)
                data2.add(value2)
            }

            val chValue1 = channels[0]
            val chValue2 = channels[1]
            return if (chValue1 == CHANNEL.CH_1 && chValue2 == CHANNEL.CH_2) {
                ECGSample(data1, data2, null)
            } else if (chValue1 == CHANNEL.CH_1 && chValue2 == CHANNEL.CH_3) {
                ECGSample(data1, null, data2)
            } else {
                ECGSample(null, data1, data2)
            }
        }

        private  fun  parseThreeChannel(channels: ArrayList<CHANNEL>, gain: Double, data: ByteArray): ECGSample? {
            val data1 = ArrayList<Short>()
            val data2 = ArrayList<Short>()
            val data3 = ArrayList<Short>()

//            Log.d(TAG, "data size: ${data.size}: ${ByteUtils.toHexString(data)}")
            for (i in 0..data.size - 6 step 6) {
                val sample1 = ByteUtils.subByteArray(data, i, 2)
                val sample2 = ByteUtils.subByteArray(data, i + 2, 2)
                val sample3 = ByteUtils.subByteArray(data, i + 4, 2)
                val value1 = ByteUtils.toShort(sample1, ByteOrder.LITTLE_ENDIAN)
                val value2 = ByteUtils.toShort(sample2, ByteOrder.LITTLE_ENDIAN)
                val value3 = ByteUtils.toShort(sample3, ByteOrder.LITTLE_ENDIAN)
                data1.add(value1)
                data2.add(value2)
                data3.add(value3)
//                Log.d(TAG, "data CH1: $value1")
            }

//            Log.d(TAG, "ch1 size: ${data1.size} ch2 size: ${data2.size} ch3 size: ${data3.size}")
            return ECGSample(data1, data2, data3)
        }

        fun checkLostPacketIndex(currentIndex: UInt) {
            lost = currentIndex - previousIndex
//            Log.d(TAG, "lost indexECG: $lost")
            if (lost < 0u) {
                previousIndex = 0u
                lost = currentIndex - previousIndex
            }
            if (lost > 0u && lost != 1u) {
                Log.d(TAG, "lost: $lost")
            }
            previousIndex = currentIndex
        }

        fun saveBinTobuffer(data: String) {
            var value: String = data.replace("]", "").replace("[", " ,")
//            bufferString.append(value)
        }

        fun writeSDcard() {
            try {
                val myFile = File("/sdcard/mysdfile.txt")
                myFile.createNewFile()
                val fOut = FileOutputStream(myFile)
                val myOutWriter = OutputStreamWriter(fOut)
//                myOutWriter.append(bufferString)
                myOutWriter.close()
                fOut.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

    }
}