package com.octo.octo_beat_plugin.repository.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(tableName = "DeviceEntity", indices = [Index(value = ["name"], unique = true)])
data class DeviceEntity(
    @PrimaryKey
    @ColumnInfo(name = "address") var address: String,
    @ColumnInfo(name = "name") var name: String
)