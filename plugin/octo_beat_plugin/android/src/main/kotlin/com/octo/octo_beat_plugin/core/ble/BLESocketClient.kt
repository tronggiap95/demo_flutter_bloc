package com.octo.octo_beat_plugin.core.ble

import android.content.Context
import android.util.Log
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient
import com.octo.octo_beat_plugin.core.utils.ByteUtils
import com.lib.terminalio.TIOConnection
import com.lib.terminalio.TIOConnectionCallback
import com.lib.terminalio.TIOManager
import com.lib.terminalio.TIOPeripheral

class BLESocketClient(context: Context, bluetoothDevice: TIOPeripheral, callback: BluetoothConnectionCallback?) : BluetoothClient(context, bluetoothDevice, callback),
        TIOConnectionCallback {

    override fun onConnected(connection: TIOConnection?) {
        Log.d(TAG, "onConnected")

        if (!mPeripheral?.shallBeSaved()!!) {
            // save if connected for the first time
            mPeripheral?.setShallBeSaved(true)
            TIOManager.getInstance().savePeripherals()
        }

        callback?.didNewConnection(this)
    }

    override fun onConnectFailed(connection: TIOConnection?, errorMessage: String?) {
        Log.d(TAG, "onConnectFailed $errorMessage")
        callback?.didConnectFail(mPeripheral!!)
    }

    override fun onDisconnected(connection: TIOConnection?, errorMessage: String?) {
        Log.d(TAG, "onDisconnected $errorMessage")
        callback?.didLostConnection(this)
    }

    override fun onDataReceived(connection: TIOConnection?, data: ByteArray?) {
        try {
            // Buffer overflow
            if (writePos - readPos > 140 * 1024) {
                Log.d(
                    TAG, "over buffer, writePos: " + writePos +
                        " readPos: " + readPos +
                        " remain: " + (writePos - readPos))
                close()
            }

            // Rollback buffer
            if (readPos == writePos) {
                writePos = 0
                readPos = 0
             //   Log.d(TAG, "over buffer, writePos: $writePos read: $readPos")
            }

            try {
                readerBuffer?.let {
                    if (data?.size?.toLong()!! > 0) {
                        readerBuffer = ByteUtils.append(readerBuffer, data, writePos)
                        writePos += data.size
                        rx += data.size
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDataTransmitted(connection: TIOConnection?, status: Int, bytesWritten: Int) {

    }

    override fun onReadRemoteRssi(connection: TIOConnection?, status: Int, rssi: Int) {
    }

    override fun onLocalUARTMtuSizeUpdated(connection: TIOConnection?, mtuSize: Int) {
        Log.d(TAG, "Local MTU Size = $mtuSize")
    }

    override fun onRemoteUARTMtuSizeUpdated(connection: TIOConnection?, mtuSize: Int) {
        Log.d(TAG, "Remote MTU Size = $mtuSize")
        UARTCredit = mtuSize and 0xff
    }

    private var rxCreditCount: Long = 0
    private var UARTCredit: Int? = null
    private val BUFFER_SIZE = 150 * 1024
    private val LOCAL_CREDIT = 48
    private var readerBuffer: ByteArray? = ByteArray(BUFFER_SIZE)
    private var writePos: Int = 0
    private var readPos: Int = 0
    private var rx: Long = 0
    var mPeripheral: TIOPeripheral? = null
    private var mConnection: TIOConnection? = null

    init {
        mPeripheral = bluetoothDevice
    }

    override fun isConnected(): Boolean {
        if (mPeripheral == null) {
            return false
        }

        return when (mPeripheral?.connectionState) {
            TIOConnection.STATE_CONNECTED -> true
            else -> false
        }
    }

    override fun connect() {
        try {
            mConnection = mPeripheral?.connect(this)
        } catch (ex: Exception) {
            ex.printStackTrace()
        }

    }

    override fun read(buffer: ByteArray): Int {
        val num = writePos - readPos
        if (num <= 0) {
            return 0
        }

        readerBuffer?.let {
            for (i in 0 until num) {
                buffer[i] = it[readPos + i]
            }

            readPos += num
            return num
        }

        return 0
    }

    override fun close() {
        try {
            mConnection?.clear()
            mConnection = null
            TIOManager.getInstance().removePeripheral(mPeripheral)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun send(data: ByteArray): Int {
        return try {
            if (data != null && isConnected()) {
                mConnection?.transmit(data)
                data.size
            } else {
                Log.d(TAG, "send: socket or output stream is null")
                -1
            }
        } catch (e: Exception) {
            e.printStackTrace()
            -1
        }
    }

    companion object {
        private const val TAG = "BLESocketClient"
    }
}
