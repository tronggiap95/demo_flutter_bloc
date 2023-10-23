package com.octo.octo_beat_plugin.core.utils

import android.bluetooth.BluetoothDevice
import com.octo.octo_beat_plugin.core.device._enum.CHANNEL
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.model.LeadStatus
import java.nio.ByteOrder
import kotlin.collections.ArrayList

object DeviceUtils {
    private val TAG = "DeviceUtils"

    fun isDeviceInBonedList(dxhDevice: DXHDevice, deviceBondedList: Set<BluetoothDevice>): Boolean {
        for (bondedDevice in deviceBondedList) {
            if (bondedDevice.address == dxhDevice.bluetoothMacAddress) {
                return true
            }
        }
        return false
    }

    @JvmStatic
    fun convertLeadStus(value: Int): LeadStatus {
        val bytes = ByteUtils.integerToByteArray(value, ByteOrder.LITTLE_ENDIAN)
        val raStatus = (bytes[0].toInt() == 1)
        val laStatus = (bytes[1].toInt() == 1)
        val llStatus = (bytes[2].toInt() == 1)
        return LeadStatus(raStatus, laStatus, llStatus)
    }


    @JvmStatic
    fun convertChannel(value: String): ArrayList<CHANNEL> {
        val list = ArrayList<CHANNEL>()
        when (value) {
            "1" -> list.add(CHANNEL.CH_1)
            "2" -> list.add(CHANNEL.CH_2)
            "3" -> list.add(CHANNEL.CH_3)
            "12" -> {
                list.add(CHANNEL.CH_1)
                list.add(CHANNEL.CH_2)
            }
            "13" -> {
                list.add(CHANNEL.CH_1)
                list.add(CHANNEL.CH_3)
            }
            "23" -> {
                list.add(CHANNEL.CH_2)
                list.add(CHANNEL.CH_3)
            }
            "123" -> {
                list.add(CHANNEL.CH_1)
                list.add(CHANNEL.CH_2)
                list.add(CHANNEL.CH_3)
            }
        }
        return list
    }

}