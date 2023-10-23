package com.octo.octo_beat_plugin.core.utils

import io.reactivex.Observable
import io.reactivex.Scheduler
import io.reactivex.android.schedulers.AndroidSchedulers
import java.util.concurrent.TimeUnit

class TimeoutUtil {
    interface TimeoutListener {
        fun onStart()
        fun onTimeout()
    }

    companion object {
        fun run(value: Long, timeUnit: TimeUnit, scheduler: Scheduler, listener: TimeoutListener): Observable<Long> {
            return Observable.interval(1, timeUnit, scheduler)
                    .take(value)
                    .map { i ->
                        if (i == 0L) {
                            listener.onStart()
                        }
                        val back = value - (i + 1)
                        if (back == 0L) {
                            listener.onTimeout()
                        }
                        back
                    }
        }

        fun runCountDown60S(stop: () -> Unit): Observable<Long> {
            return Observable.interval(1, TimeUnit.SECONDS, AndroidSchedulers.mainThread())
                .map { i ->
                    val back = 60 - (i + 1)
                    if (back == 0L) {
                        stop()
                    }
                    back
                }
        }
    }
}