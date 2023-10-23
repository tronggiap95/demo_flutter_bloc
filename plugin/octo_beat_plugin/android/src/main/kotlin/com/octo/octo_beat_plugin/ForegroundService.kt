package com.octo.octo_beat_plugin

import android.annotation.SuppressLint
import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.util.Log
import com.octo.octo_beat_plugin.core.CoreHandler
import io.flutter.embedding.engine.FlutterEngine

class ForegroundService : Service() {
    private val TAG = "ForegroundService"
    private var builder: Notification.Builder? = null
    private val title: String = "Service is running"
    private val message = "Tap to open the app"
    private val notificationId = 3333

    private val binder = LocalBinder()
    private var startedForeground = false
    var coreHandler: CoreHandler? = null

    companion object {
        private const val CHANNEL_ID = "notification.octo.channel.id"
        private const val CHANNEL_NAME = "Foreground Service"

        @SuppressLint("StaticFieldLeak")
        var headlessTaskFlutterEngine: FlutterEngine? = null

        @JvmStatic
        fun setBackgroundTasks(headlessTaskFlutterEngine: FlutterEngine?) {
            this.headlessTaskFlutterEngine = headlessTaskFlutterEngine
        }
    }

    override fun onCreate() {
        super.onCreate()
        startForegroundNotification(this, false)

        coreHandler = CoreHandler(this)
        coreHandler?.onCreate()
    }

    private fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val importance = NotificationManager.IMPORTANCE_HIGH
            val notificationChannel = NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance)
            notificationChannel.enableVibration(true)
            notificationChannel.setShowBadge(true)
            notificationChannel.enableLights(true)
            notificationChannel.lightColor = Color.parseColor("#e8334a")
            notificationChannel.description = "notification channel description"
            notificationChannel.lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            notificationManager.createNotificationChannel(notificationChannel)
            notificationChannel.setShowBadge(false)
        }
    }

    private fun startForegroundNotification(context: Context, force: Boolean) {
        if (startedForeground && !force) {
            Log.d(TAG, "Already started foreground")
            return
        }

        Log.d(TAG, "title = $title, message = $message")
        var notification: Notification?
        createChannel(context)

        val notifyIntent = Intent(context, context.javaClass::class.java)

        notifyIntent.putExtra("title", title)
        notifyIntent.putExtra("message", message)
        notifyIntent.putExtra("notification", true)
        notifyIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)

        val pendingIntent = PendingIntent.getActivity(context,
            0,
            notifyIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val icon = context.resources.getIdentifier("ic_notification", "drawable", context.packageName)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            builder = Notification.Builder(context, CHANNEL_ID)
                .setContentIntent(pendingIntent)
                .setSmallIcon(icon)
                .setAutoCancel(true)
                .setContentTitle(title)
                .setStyle(Notification.BigTextStyle()
                    .bigText(message))
                .setContentText(message)
                .setWhen(System.currentTimeMillis())
                .setShowWhen(true)
                .setColor(Color.parseColor("#2A56BD"))
            notification = builder?.build()

        } else {
            builder = Notification.Builder(context)
                .setContentIntent(pendingIntent)
                .setSmallIcon(icon)
                .setAutoCancel(true)
                .setPriority(Notification.PRIORITY_MAX)
                .setContentTitle(title)
                .setStyle(Notification.BigTextStyle()
                    .bigText(message))
                .setContentText(message)
                .setWhen(System.currentTimeMillis())

            notification = builder?.build()
        }

        startedForeground = true
        startForeground(notificationId, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        startedForeground = false
        coreHandler?.onDestroy()
    }

    inner class LocalBinder : Binder() {
        fun getService(): ForegroundService = this@ForegroundService
    }

    override fun onBind(intent: Intent): IBinder {
        coreHandler?.onStart()
        return binder
    }
}
