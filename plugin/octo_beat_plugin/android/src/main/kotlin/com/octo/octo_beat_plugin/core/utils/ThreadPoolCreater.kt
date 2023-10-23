package com.octo.octo_beat_plugin.core.utils

import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

object ThreadPoolCreater {
    private const val NUMBER_OF_CORES = 3
    // Sets the amount of time an idle thread waits before terminating
    private const val KEEP_ALIVE_TIME = 1L
    // Sets the Time Unit to seconds
    private val KEEP_ALIVE_TIME_UNIT = TimeUnit.SECONDS

    // Creates a thread pool manager
    fun create(): ThreadPoolExecutor {
        return ThreadPoolExecutor(
                NUMBER_OF_CORES,       // Initial pool size
                NUMBER_OF_CORES,       // Max pool size
                KEEP_ALIVE_TIME,
                KEEP_ALIVE_TIME_UNIT,
                LinkedBlockingQueue<Runnable>()
        )
    }

}