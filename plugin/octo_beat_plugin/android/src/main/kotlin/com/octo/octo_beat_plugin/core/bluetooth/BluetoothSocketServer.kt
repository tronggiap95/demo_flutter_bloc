//package com.octo.octo_beat_plugin.core.bluetooth
//
//import android.bluetooth.BluetoothManager
//import android.bluetooth.BluetoothServerSocket
//import android.bluetooth.BluetoothSocket
//import android.content.Context
//import android.util.Log
//import octoflux.patch.android.clinician.service.MyApplication.Companion.context
//import com.octo.octo_beat_plugin.core.ble.BluetoothConnectionCallback
//import com.octo.octo_beat_plugin.core.device._enum.BluetoothConnectionType
//
//import java.io.IOException
//
///**
// * Created by caoxuanphong on 12/15/17.
// */
//
//class BluetoothSocketServer(context: Context, private var callback: BluetoothConnectionCallback?) : Thread(), SocketClientCallback {
//    private val serverSocket: BluetoothServerSocket?
//
//    init {
//        var tmp: BluetoothServerSocket? = null
//        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
//        val bluetoothAdapter = bluetoothManager.adapter
//
//        try {
//            tmp = bluetoothAdapter.listenUsingRfcommWithServiceRecord(bluetoothAdapter.name, BTUUID.UUID_SPP)
//        } catch (e: IOException) {
//            Log.e(TAG, "Socket's listen() method failed", e)
//            callback?.onError(BLUETOOTH_SOCKET_SERVER_COULD_NOT_START)
//        }
//
//        Log.d(TAG, "BluetoothSocketServer() called with: " + tmp!!)
//        serverSocket = tmp
//    }
//
//    override fun run() {
//        var socket: BluetoothSocket?
//        Log.d(TAG, "run server bluetooth: ")
//        while (isAlive && !isInterrupted) {
//            Log.d(TAG, "running server bluetooth...")
//            try {
//                socket = serverSocket!!.accept()
//                Log.d(TAG, "new socket: " + socket!!.remoteDevice.name)
//            } catch (e: IOException) {
//                callback?.onError(BLUETOOTH_SOCKET_SERVER_COULD_NOT_ACCEPT)
//                continue
//            }
//
//            if (isAlive && !isInterrupted) {
//                val bluetoothClient = BluetoothClientFactory.create(
//                        BluetoothConnectionType.BLUETOOTH_CLASSIC,
//                        context!!,
//                        socket.remoteDevice,
//                        callback!!)
//                (bluetoothClient as BluetoothSocketClient).socket = socket
//                bluetoothClient!!.connect()
//            }
//        }
//    }
//
//    fun close() {
//        try {
//            callback = null
//            serverSocket?.close()
//        } catch (e: Exception) {
//        }
//
//    }
//
//    override fun didDisconnected(socketClient: BluetoothSocketClient) {
//        Log.d(TAG, "didDisconnected: ")
//        callback?.didLostConnection(socketClient)
//    }
//
//    companion object {
//        private val TAG = "BluetoothSocketServer"
//
//        val BLUETOOTH_SOCKET_SERVER_COULD_NOT_ACCEPT = 1 shl 1
//        val BLUETOOTH_SOCKET_SERVER_COULD_NOT_START = 1 shl 2
//    }
//
//}