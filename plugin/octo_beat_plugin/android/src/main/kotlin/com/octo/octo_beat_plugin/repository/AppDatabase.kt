package com.octo.octo_beat_plugin.repository

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.octo.octo_beat_plugin.Constant
import com.octo.octo_beat_plugin.repository.dao.DeviceDao
import com.octo.octo_beat_plugin.repository.entity.DeviceEntity

@Database(
        entities =
        [
            DeviceEntity::class
        ],
        version = 1
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun deviceDao(): DeviceDao

    companion object : SingletonHolder<AppDatabase, Context>({
        Room.databaseBuilder(
                it.applicationContext,
                AppDatabase::class.java, Constant.DATABASE_NAME
        )
                .fallbackToDestructiveMigration()
                .build()
    })
}