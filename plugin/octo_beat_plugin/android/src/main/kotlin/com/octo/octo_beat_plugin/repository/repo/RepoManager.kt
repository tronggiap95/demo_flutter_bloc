package com.octo.octo_beat_plugin.repository.repo

import android.content.Context
import com.octo.octo_beat_plugin.repository.AppDatabase

object RepoManager {
    private var deviceRepo: DeviceRepo? = null

    fun getDeviceRepo() = deviceRepo

    fun initDB(context: Context) {
        val appDatabase =
            AppDatabase.getInstance(context)
        deviceRepo = DeviceRepo(appDatabase.deviceDao())
    }
}