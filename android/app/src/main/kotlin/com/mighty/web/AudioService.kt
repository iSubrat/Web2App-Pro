package com.mighty.web

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.app.PendingIntent
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner

class AudioService : Service(), LifecycleObserver {

    private var isMediaPlaying = false

    override fun onCreate() {
        super.onCreate()
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
        startForegroundService()
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun onAppGoesToBackground() {
        if (isMediaPlaying) {
            showNotification()
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    fun onAppComesToForeground() {
        stopNotification()
    }

    private fun startForegroundService() {
        isMediaPlaying = true
    }

    private fun showNotification() {
        val channelId = "audio_channel_id"
        val channelName = "Background Audio Service"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationChannel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(notificationChannel)
        }

        val launchIntent = packageManager.getLaunchIntentForPackage("com.mighty.web")
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification: Notification = NotificationCompat.Builder(this, channelId)
            .setSilent(true)
            .setContentTitle("MightyWeb is running")
            .setAutoCancel(true)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSmallIcon(R.mipmap.ic_launcher_foreground)
            .setContentIntent(pendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_SECRET)
            .build()

        startForeground(1, notification)
    }

    private fun stopNotification() {
        stopForeground(true)
    }

    override fun onDestroy() {
        ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
        super.onDestroy()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        isMediaPlaying = true
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
