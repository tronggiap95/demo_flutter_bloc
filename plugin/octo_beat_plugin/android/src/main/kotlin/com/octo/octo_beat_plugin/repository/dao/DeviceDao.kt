package com.octo.octo_beat_plugin.repository.dao

import androidx.room.*
import com.octo.octo_beat_plugin.repository.entity.DeviceEntity

@Dao
interface DeviceDao {
    //create
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insert(deviceEntity: DeviceEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertAll(deviceEntities: List<DeviceEntity>)

    //read
    @Query("SELECT * FROM DeviceEntity")
    fun getDevices(): List<DeviceEntity>

    @Query("SELECT * FROM DeviceEntity WHERE address = :mac")
    fun getDeviceByMac(mac: String): DeviceEntity?

    //update
    @Update(onConflict = OnConflictStrategy.REPLACE)
    fun update(deviceEntity: DeviceEntity)

    @Query("UPDATE DeviceEntity SET address=:address WHERE name = :name")
    fun updateMacAddress( name: String, address: String)

    //delete
    @Query("DELETE FROM DeviceEntity WHERE address = :mac")
    fun deleteDeviceByMac(mac: String)

    @Query("DELETE FROM DeviceEntity")
    fun deleteAll()

    @Delete
    fun delete(deviceEntity: DeviceEntity)
}