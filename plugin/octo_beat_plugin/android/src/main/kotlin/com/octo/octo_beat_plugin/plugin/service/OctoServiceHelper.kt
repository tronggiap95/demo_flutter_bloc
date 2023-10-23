package com.octo.octo_beat_plugin.plugin.service

import android.app.Notification
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.octo.octo_beat_plugin.OctoBeatHelper
import com.octo.octo_beat_plugin.ForegroundService
import com.octo.octo_beat_plugin.plugin.connection.OctoBeatConnectionHelper
import com.octo.octo_beat_plugin.plugin.event.OctoBeatEventHelper
import com.octo.octo_beat_plugin.repository.SingletonHolder

class OctoServiceHelper private constructor(val context: Context) {
    var binded: Boolean = false
    var mService: ForegroundService? = null

    var notificationId: Int? = null
    var notification: Notification? = null

    companion object : SingletonHolder<OctoServiceHelper, Context>(::OctoServiceHelper)

    fun unBindService() {
        if (binded) {
            binded = false
        }
    }

    fun startService() {
        context.let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                it.startForegroundService(Intent(it, ForegroundService::class.java))
            } else {
                it.startService(Intent(it, ForegroundService::class.java))
            }

            val intent = Intent(it, ForegroundService::class.java)
            it.bindService(intent, connection, Context.BIND_AUTO_CREATE)
        }
    }

    fun stopService() {
        mService?.coreHandler?.removeConnectionCallback(OctoBeatConnectionHelper.getInstance(context).connectionBLECallback)
    }


    val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            binded = true
            val binder = service as ForegroundService.LocalBinder
            mService = binder.getService()
            OctoBeatHelper.getInstance(context).onServiceStarted(mService)
            OctoBeatConnectionHelper.getInstance(context).onServiceStarted(mService)
            OctoBeatEventHelper.getInstance(context).onServiceStarted(mService)
        }

        override fun onServiceDisconnected(arg0: ComponentName) {
            binded = false
        }
    }
}