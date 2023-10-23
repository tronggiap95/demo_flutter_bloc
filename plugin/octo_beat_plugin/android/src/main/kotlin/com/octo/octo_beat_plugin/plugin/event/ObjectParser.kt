package com.octo.octo_beat_plugin.plugin.event

import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.repository.entity.DeviceEntity

object ObjectParser {
    fun parseDeviceInfo(device: DXHDevice): Map<String, Any> {
        val isLAConnected = device.leadStatus?.LAConnected ?: false
        val isLLConnected = device.leadStatus?.LLConnected ?: false
        val isRAConnected = device.leadStatus?.RAConnected ?: false
        val batLevel = device.battLevel ?: 0
        val isCharging = device.battCharging
        val batLow = device.battLow
        val batTime = device.chargingRemaining ?: 0
        val isConnected = device.isBluetoothConnected
        val name = device.clientId ?: ""
        val isServerConnected = device.isTCPSocketOpened ?: false
        val studyStatus = device.studyStatus ?: ""
        val address = device.bluetoothMacAddress ?: ""

        return mapOf(
            "isConnected" to isConnected,
            "name" to name,
            "address" to address,
            "batLow" to batLow,
            "batTime" to batTime,
            "batLevel" to batLevel,
            "isCharging" to isCharging,
            "isServerConnected" to isServerConnected,
            "studyStatus" to studyStatus,
            "isLeadConnected" to (isLAConnected && isLLConnected && isRAConnected)
        )
    }

    fun parseDeviceInfo(device: DeviceEntity): Map<String, Any> {
        val isLAConnected =  false
        val isLLConnected =  false
        val isRAConnected =  false
        val batLevel = 0
        val isCharging =  false
        val batTime = 0
        val name = device.name
        val isServerConnected = false
        val studyStatus =  ""
        val address = device.address

        return mapOf(
            "isConnected" to false,
            "name" to name,
            "address" to address,
            "batLow" to true,
            "batTime" to batTime,
            "hwVersion" to "",
            "fwVersion" to "",
            "batLevel" to batLevel,
            "isCharging" to isCharging,
            "isServerConnected" to isServerConnected,
            "studyStatus" to studyStatus,
            "isLeadConnected" to (isLAConnected && isLLConnected && isRAConnected)
        )
    }
}