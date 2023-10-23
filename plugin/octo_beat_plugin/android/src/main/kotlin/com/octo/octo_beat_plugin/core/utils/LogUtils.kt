package com.octo.octo_beat_plugin.core.utils

import android.bluetooth.BluetoothDevice

object LogUtils {
    fun logBleMethod() {
        val methods = BluetoothDevice::class.java!!.declaredMethods
        var nMethod = 1
        println("1. List of all methods of Person class")
        for (method in methods) {
            System.out.printf("%d. %s", ++nMethod, method)
            println()
        }
    }
}