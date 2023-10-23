package com.octo.octo_beat_plugin.core.bluetooth

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log

class BluetoothScanner {
    private var mBtAdapter: BluetoothAdapter? = null
    private var listener: BluetoothSPPScannerListener? = null
    private var context: Context? = null

    interface BluetoothSPPScannerListener {
        fun found(bluetoothDevice: BluetoothDevice)
    }

    private val mReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action

            if (BluetoothDevice.ACTION_FOUND == action) {
                val device = intent.getParcelableExtra<BluetoothDevice>(BluetoothDevice.EXTRA_DEVICE)!!
                Log.d(TAG, "Found a device: address = ${device.address}, name = ${device.name}")
                listener?.found(device)
            }
        }
    }

    fun start(context: Context, listener: BluetoothSPPScannerListener) {
        this.listener = listener
        this.context = context
        val intentFilter = IntentFilter()
        intentFilter.addAction(BluetoothDevice.ACTION_FOUND)
        mBtAdapter = BluetoothAdapter.getDefaultAdapter()
        if (mBtAdapter?.isDiscovering!!) {
            try {
                context.unregisterReceiver(mReceiver)
                mBtAdapter?.cancelDiscovery()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        context.registerReceiver(mReceiver, intentFilter)
        mBtAdapter?.startDiscovery()
    }

    fun stop() {
        try {
            context?.unregisterReceiver(mReceiver)
            mBtAdapter?.cancelDiscovery()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    companion object {
        private val TAG = "BluetoothScanner"
    }

}
