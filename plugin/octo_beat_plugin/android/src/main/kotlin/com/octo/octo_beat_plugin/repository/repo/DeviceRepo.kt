package com.octo.octo_beat_plugin.repository.repo

import com.octo.octo_beat_plugin.repository.dao.DeviceDao
import com.octo.octo_beat_plugin.repository.entity.DeviceEntity

class DeviceRepo(deviceDao: DeviceDao) {
    private var deviceDao = deviceDao

    fun getDevices(): List<DeviceEntity> {
        return deviceDao.getDevices()
    }

    fun insert(deviceEntity: DeviceEntity) {
        deviceDao.insert(deviceEntity)
    }

    fun deleteDeviceByMac(mac: String) {
        deviceDao.deleteDeviceByMac(mac)
    }

    fun delete(deviceEntity: DeviceEntity) {
        deviceDao.delete(deviceEntity)
    }

    fun deleteAll() {
        deviceDao.deleteAll()
    }
}