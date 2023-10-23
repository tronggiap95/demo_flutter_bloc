package com.octo.octo_beat_plugin.core.device

import android.content.Context
import android.util.Log
import com.octo.octo_beat_plugin.core.device._enum.BluetoothConnectionType
import com.octo.octo_beat_plugin.core.device._enum.RequestCode
import com.octo.octo_beat_plugin.core.device.handler.*
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.tcp.TCPClientCallback
import com.octo.octo_beat_plugin.core.model.Packet
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import com.octo.octo_beat_plugin.core.utils.MyLog

class RequestContainerHandler: ContainerHandler {
    private val TAG = "RequestContainerHandler"
    private val TAG_HANDLER = "DEVICE_HANDLER_LOG"
    private val typeLog = MyLog.TypeLog.DEBUG

    private var tcpClientCallback: TCPClientCallback? = null
    private var handshakedCallback: HandshakedCallback? = null
    private var context: Context? = null

    fun addHandShakeCallback(callback: HandshakedCallback): RequestContainerHandler{
        this.handshakedCallback = callback
        return this
    }

    fun addTCPClientCallback(tcpClientCallback: TCPClientCallback): RequestContainerHandler{
        this.tcpClientCallback = tcpClientCallback
        return this
    }

    fun addContext(context: Context): RequestContainerHandler{
        this.context = context
        return this
    }


    override fun handle(code: Int, dxhDevice: DXHDevice, packet: ByteArray, deviceHandlerCallback: DeviceHandlerCallback) {
        val messagePack = MessagePackHelper.unpack(packet)
        if (messagePack == null) {
            Log.e(TAG, "receivedPacket: messagePack is null")
            return
        }
        when (RequestCode.get(code)) {
            RequestCode.BB_REQ_HANDSHAKE -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_CMD_HANDSHAKE")
                HandShakeHandler().handle(dxhDevice, messagePack, deviceHandlerCallback) {
                    if(dxhDevice.bluetoothConnectionType == BluetoothConnectionType.BLUETOOTH_CLASSIC){
                        handshakedCallback?.success()
                    }
                }
            }

            RequestCode.BB_REQ_GET_NETSTAT -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_CMD_GET_NETSTAT")
                NetStatusHandler.handle(dxhDevice, context)
            }

            RequestCode.BB_REQ_TCP_OPEN_CONN -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_CMD_TCP_OPEN_CONN")
                HandleOpenTcp.handle(dxhDevice,
                        messagePack,
                        context,
                        tcpClientCallback)
            }

            RequestCode.BB_REQ_TCP_CLOSE_CONN -> {
                MyLog.log(dxhDevice.clientId,  "CMD: BB_CMD_TCP_CLOSE_CONN")
                HandCloseTCP.handle(dxhDevice, messagePack)
            }

            RequestCode.BB_REQ_TCP_GET_CONN_STATUS -> MyLog.log(dxhDevice.clientId, "CMD: BB_CMD_TCP_GET_CONN_STATUS")

            RequestCode.BB_REQ_TCP_READ_DATA -> {
                MyLog.log("", "")
                ReadTcpDataHandler.handle(dxhDevice, messagePack)
                MyLog.log(dxhDevice.clientId, "BB_CMD_TCP_READ_DATA")

                if (dxhDevice?.tcpBuffer?.position()!! > 0) {
                    NotifyReceiveTCPDataHandler.handle(dxhDevice, dxhDevice?.tcpBuffer?.position()!!)
                }
            }

            RequestCode.INVALID_CMD -> MyLog.log(dxhDevice.clientId,"CMD: INVALID_CMD")


            RequestCode.BB_REQ_SSL_CONN_CONFIG -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_CMD_SSL_CONN_CONFIG")
                HandleConfigureSSL.handle(dxhDevice, messagePack)
            }

            RequestCode.BB_REQ_SSL_SET_CA_CERT -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_CMD_SSL_SET_CA_CERT")
                SetSeverCertificateHandler.handle(dxhDevice, messagePack)
            }



            RequestCode.BB_REQ_START_STREAMING_ECG -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_CMD_ECG_PARAM_CONFIG")
                ConfigECGHandler.handle(dxhDevice!!, messagePack, deviceHandlerCallback!!)
            }

            RequestCode.BB_REQ_EVENT_TRIGGERED -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_REQ_EVENT_TRIGGERED")
                HandleTriggerMCT.handle(dxhDevice, packet, messagePack, context)
            }

            RequestCode.BB_REQ_SWITCH_BT_MODE -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_REQ_SWITCH_BT_MODE")
                SwModeHandler.handleResponse(packet, dxhDevice.callbackContainer.getSWmodeListener())
            }

            RequestCode.BB_REQ_GET_TIME -> {
                MyLog.log(dxhDevice.clientId, "CMD: BB_REQ_GET_TIME")
                GetTimeHandler.handle(dxhDevice)
            }
            else -> {}
        }
    }

}