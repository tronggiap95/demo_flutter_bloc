package com.octo.octo_beat_plugin.core.utils;

import android.util.Log;

public class MyLog {
    public static boolean ENABLE_LOG = false;
    public enum TypeLog {
        VERBOSE,
        DEBUG,
        INFO,
        WARN,
        TERRIBLE_ERROR,
        ERROR
    }

    private static String generateTag(String className, String methodName) {
        String threadName = Thread.currentThread().getName();
        return String.format("[%s  -  %s  -  %s]", threadName, className, methodName);
    }

    private static String generateDebugTag(String deviceId) {
        return String.format("[DEBUG_LOG-%s]", deviceId);
    }


    public static void log(String deviceId, String message) {
        if (!ENABLE_LOG) {
            return;
        }

        String TAG = generateDebugTag(deviceId);
        Log.d(TAG, message);
    }

}
