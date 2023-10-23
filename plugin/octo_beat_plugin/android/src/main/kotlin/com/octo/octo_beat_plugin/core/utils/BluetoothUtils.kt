package com.octo.octo_beat_plugin.core.utils

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.Context
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothScanner
import io.reactivex.Flowable
import io.reactivex.subscribers.DisposableSubscriber
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern

object BluetoothUtils {
    fun getMacAddress(context: Context): String {
        return android.provider.Settings.Secure.getString(context.contentResolver, "bluetooth_address")
    }

    fun filterBluetoothDeviceName(name: String?): Boolean {
        val pattern = "(^\\d{10}$)|((^\\d{7}\$))"
        val r = Pattern.compile(pattern)
        val m = r.matcher(name ?: "")
        return m.find()

    }

    fun startScan(context: Context, bluetoothScanner: BluetoothScanner?, listener: BluetoothScanner.BluetoothSPPScannerListener): DisposableSubscriber<Long> {
        val disposableSubscriber = object : DisposableSubscriber<Long>() {
            override fun onComplete() {
            }

            override fun onNext(t: Long?) {
                bluetoothScanner?.start(context, listener)
            }

            override fun onError(t: Throwable?) {
            }
        }
        Flowable.interval(0, 12, TimeUnit.SECONDS).subscribe(disposableSubscriber)
        return disposableSubscriber
    }



    fun unPairBluetoothDevice(device: BluetoothDevice): Boolean {
        try {
            val m = BluetoothDevice::class.java.getMethod("removeBond", *emptyArray<Class<*>>())
            return m.invoke(device, *emptyArray()) as Boolean
        } catch (e: Exception) {
            e.printStackTrace()
            return false
        }
    }

    private fun retrieveBondDevices(): Set<BluetoothDevice>? {
        val adapter = BluetoothAdapter.getDefaultAdapter()
        adapter?.let {
            return it.bondedDevices
        }
        return null
    }
}