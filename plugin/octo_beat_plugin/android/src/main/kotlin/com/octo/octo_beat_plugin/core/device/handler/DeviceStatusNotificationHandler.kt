package com.octo.octo_beat_plugin.core.device.handler

import com.octo.octo_beat_plugin.core.device.DeviceHandlerCallback
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.model.LeadStatus
import org.json.JSONArray

object DeviceStatusNotificationHandler {
    fun handle(dxhdevice: DXHDevice, messagePack: JSONArray, deviceHandlerCallback: DeviceHandlerCallback): Boolean {
        try {
            val batteryLevel = messagePack.getInt(1)
            val chargeRemaining = messagePack.getInt(3)
            val raStatus = messagePack.getBoolean(4)
            val laStatus = messagePack.getBoolean(5)
            val llStatus = messagePack.getBoolean(6)
            val studyStatus = messagePack.getString(7)

            dxhdevice.battLevel = batteryLevel
            if(dxhdevice.apiVersion < 1) {
                dxhdevice.battCharging = messagePack.getBoolean(2)
                dxhdevice.battLow = batteryLevel < 10
            } else {
                val battStatus = messagePack.getInt(2)
                dxhdevice.battLow = battStatus == 1
                dxhdevice.battCharging = battStatus == 2
            }
            dxhdevice.chargingRemaining = chargeRemaining
            dxhdevice.leadStatus = LeadStatus(raStatus, laStatus, llStatus)
            dxhdevice.studyStatus = studyStatus

            deviceHandlerCallback.updateInfo(dxhdevice)
            return true
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }
}