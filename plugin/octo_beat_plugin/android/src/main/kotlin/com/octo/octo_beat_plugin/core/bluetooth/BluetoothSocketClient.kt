//package com.octo.octo_beat_plugin.core.bluetooth
//
//import android.bluetooth.BluetoothDevice
//import android.bluetooth.BluetoothSocket
//import android.content.Context
//import android.os.SystemClock
//import android.util.Log
//import com.octo.octo_beat_plugin.core.ble.BluetoothConnectionCallback
//
//import com.octo.octo_beat_plugin.core.utils.ByteUtils
//
///**
// * Created by caoxuanphong on 12/16/17.
// */
//
//class BluetoothSocketClient(context: Context,
//                            bluetoothDevice: BluetoothDevice,
//                            callback: BluetoothConnectionCallback?) : BluetoothClient(context, bluetoothDevice, callback) {
//
//    override fun connect() {
//        try {
//            if (socket == null) {
//                socket = bluetoothDevice.createRfcommSocketToServiceRecord(BTUUID.UUID_SPP)
//                socket!!.connect()
//            }
//
//            val ret = callback?.didNewConnection(this)
//            ret?.let {
//                if (it) {
//                    start()
//                }
//            }
//        } catch (e: java.lang.Exception) {
//            callback?.didConnectFail(bluetoothDevice)
//            e.printStackTrace()
//        }
//    }
//
//    private var readerBuffer: ByteArray? = ByteArray(500 * 1024) // 500Kb
//    private var writePos: Int = 0
//    private var readPos: Int = 0
//    private var rx: Long = 0
//    var socket: BluetoothSocket? = null
//
//    override fun isConnected(): Boolean {
//        if (socket == null) {
//            return false
//        }
//
//        return socket?.isConnected!!
//    }
//
//    override fun read(buffer: ByteArray): Int {
//        val num = writePos - readPos
//        if (num <= 0) {
//            return 0
//        }
//
//        readerBuffer?.let {
//            for (i in 0 until num) {
//                buffer[i] = it[readPos + i]
//            }
//
//            readPos += num
//            return num
//        }
//
//        return 0
//    }
//
//    override fun run() {
//        while (true) {
//            try {
//                // Buffer overflow
//                if (10 * 1024 + writePos > readerBuffer?.size!! && readPos < writePos) {
//                    Log.d(TAG, "over buffer, writePos: " + writePos +
//                            " readPos: " + readPos +
//                            " remain: " + (writePos - readPos))
//                    SystemClock.sleep(5)
//                    continue
//                }
//
//                // Rollback buffer
//                if (10 * 1024 + writePos > readerBuffer?.size!!) {
//                    writePos = 0
//                    readPos = 0
//                    Log.d(TAG, "over buffer, writePos: $writePos read: $readPos")
//                    continue
//                }
//
//
//                readerBuffer?.let {
//                    var len: Int? = socket?.inputStream?.read(it, writePos, 10 * 1024)
//                    if (len != null && len!! >= 0) {
//                        writePos += len
//                        rx += len.toLong()
//                    } else {
//                        callback?.didLostConnection(this@BluetoothSocketClient)
//                    }
//                }
//            } catch (e: Exception) {
//                e.printStackTrace()
//                callback?.didLostConnection(this@BluetoothSocketClient)
//                break
//            }
//        }
//    }
//
//    override fun close() {
//        try {
//            callback = null
//            socket?.close()
//            socket = null
//            readerBuffer = null
//            interrupt()
//        } catch (e: Exception) {
//            e.printStackTrace()
//        }
//    }
//
//    override fun send(data: ByteArray): Int {
//        return try {
//            if (socket != null && socket?.outputStream != null) {
//                Log.d(TAG, "send: " + ByteUtils.toHexString(data))
//                socket?.outputStream?.write(data)
//                data.size
//            } else {
//                Log.d(TAG, "send: socket or output stream is null")
//                -1
//            }
//        } catch (e: Exception) {
//            e.printStackTrace()
//            -1
//        }
//    }
//
//    companion object {
//        private val TAG = "BluetoothSocketClient"
//    }
//
//}
