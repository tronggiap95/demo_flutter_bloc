package com.octo.octo_beat_plugin.core.device.model

import android.util.Log
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient

import java.nio.ByteBuffer

import com.octo.octo_beat_plugin.core.device.DeviceCallbackContainer
import com.octo.octo_beat_plugin.core.device.DeviceHandlerCallback
import com.octo.octo_beat_plugin.core.device._enum.BluetoothConnectionType
import com.octo.octo_beat_plugin.core.device._enum.CHANNEL
import com.octo.octo_beat_plugin.core.device.security.AESManager
import com.octo.octo_beat_plugin.core.device.tcp.TCPClientSupportSSL.SSLTCPSocketClient
import com.octo.octo_beat_plugin.core.device.tcp.TCPSocketClient
import com.octo.octo_beat_plugin.core.utils.ByteUtils
import com.octo.octo_beat_plugin.core.utils.DateTimeUtils
import com.octo.octo_beat_plugin.core.utils.DeviceUtils
import com.octo.octo_beat_plugin.core.utils.MyLog
import java.util.*
import java.util.concurrent.ThreadPoolExecutor

/**
 * Created by caoxuanphong on 12/16/17.
 */

class DXHDevice {
    var handShakeTime: Int? = null
    var mctTriggeredTime: Long? = null
    var handShaked: Boolean = false
    var bluetoothClient: BluetoothClient? = null
    var tcpBuffer: ByteBuffer? = null
    var clientId: String? = null
    var apiVersion: Int = 0 //IN PAYLOAD FIELD OF HANDSHAKE PACKET
    var protocolVersion: Int = 0 // IN STATUS FIELD OF ALL PACKETS
    var tx: Long = 0
    var rx: Long = 0
    var lastUpdatedTX = DateTimeUtils.currentTimeToEpoch()
    var lastUpdateRX = DateTimeUtils.currentTimeToEpoch()

    var battLevel: Int? = null
    var battCharging: Boolean = false
    var battLow: Boolean = false
    var chargingRemaining: Int? = null
    var leadStatus: LeadStatus? = null
    var studyStatus: String? = null
    var hasMCTNotify = false

    var isEdit = false
    var ECGConfig: ECGConfig? = null
    var ECGData: ByteArray? = null
    var callback: DeviceHandlerCallback? = null
    var tcpConnections = ArrayList<TCPConnection>()
    var ssltcpSocketClient: SSLTCPSocketClient? = null
    var tcpSocketClient: TCPSocketClient? = null
    var tcpStatus = false
    var serverCA: HashMap<Int, String> = LinkedHashMap()
    var clientCA: HashMap<Int, String> = LinkedHashMap()
    var clientPrivateKey: HashMap<Int, String> = LinkedHashMap()
    var mctInstance: MCTInstance? = null
    var executor: ThreadPoolExecutor? = null
    var bluetoothConnectionType: BluetoothConnectionType? = null
    var bluetoothMacAddress: String? = null
    var facilityId: String? = null
    var facilityName: String? = null

    /**
     * should use for request command
     */
    var callbackContainer = DeviceCallbackContainer()

    var security: AESManager? = null

    // FIXME: Need handle for each connection id
    val isTCPSocketOpened: Boolean
        get() {
            if (ssltcpSocketClient != null) {
                return ssltcpSocketClient!!.isOpened
            } else {
                return false
            }
        }
    val isBluetoothConnected: Boolean
        get() {
            return if (bluetoothClient == null) {
                false
            } else {
                bluetoothClient!!.isConnected()
            }
        }

    init {
        this.tcpBuffer = ByteBuffer.allocate(10 * 1024)
    }

    private constructor()

    constructor(clientId: String) {
        this.clientId = clientId
        this.security = AESManager(clientId)
    }

    constructor(bluetoothClient: BluetoothClient) {
        this.bluetoothClient = bluetoothClient
        this.security = AESManager(bluetoothClient.bluetoothDevice.name)
    }

    fun send(data: ByteArray) {
        bluetoothClient?.let { socket ->
            MyLog.log(clientId, "SEND BLUE DATA: ${ByteUtils.toHexString(data)}")
            socket.send(data)

            callback?.let { cb ->
                val currentUpdatedTime = DateTimeUtils.currentTimeToEpoch()
                if (currentUpdatedTime - lastUpdateRX > 15) {
                    cb.updateInfo(this)
                    lastUpdateRX = currentUpdatedTime
                }
            }
        }
    }

    fun sendDataToTCPServer(dxhDevice: DXHDevice?, connectionId: Int, data: ByteArray) {
        if (!dxhDevice?.isTCPSocketOpened!!) {
            Log.d(TAG, "sendDataToTCPServer: tcp client is not running")
            return
        }

        tx += data.size.toLong()
        val currentUpdatedTime = DateTimeUtils.currentTimeToEpoch()
        if (currentUpdatedTime - lastUpdatedTX > 15) {
            callback?.updateInfo(this)
            lastUpdatedTX = currentUpdatedTime
        }

        MyLog.log(clientId, "SEND TCP DATA: ${ByteUtils.toHexString(data)}")
        val tcpConnection = dxhDevice?.retrieveTCPConnection(connectionId)
        if (tcpConnection != null && tcpConnection.isSSLEnabled) {
            dxhDevice.ssltcpSocketClient?.send(data)
        } else {
            dxhDevice?.tcpSocketClient?.send(data)
        }
    }

    fun retrieveServerCa(id: Int): String? {
        for ((key, value) in serverCA) {
            if (key == id) {
                return value
            }
        }

        return null
    }

    fun retrieveTCPConnection(id: Int): TCPConnection? {
        for (tcpConnection in tcpConnections) {
            if (tcpConnection.id == id) {
                return tcpConnection
            }
        }

        return null
    }

    fun addNewTCPConnection(connection: TCPConnection) {
        val tcpConnection = retrieveTCPConnection(connection.id)
        if (tcpConnection == null) {
            tcpConnections.add(connection)
        } else {
            tcpConnection.paste(connection)
        }
    }

    fun removeMCTEvent() {
        mctInstance = null
    }

    fun isHasChannel(chanel: CHANNEL): Boolean {
        if (ECGConfig == null) return false
        val channels = DeviceUtils.convertChannel(ECGConfig?.channel!!)
        for (ch in channels) {
            if (ch == chanel) {
                return true
            }
        }
        return false
    }

    companion object {
        private val TAG = "DXHDevice"
    }

}
