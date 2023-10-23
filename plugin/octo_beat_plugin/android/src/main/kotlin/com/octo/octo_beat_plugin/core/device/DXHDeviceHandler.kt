package com.octo.octo_beat_plugin.core.device

import android.content.Context
import android.util.Log

import com.octo.octo_beat_plugin.core.device.command.CommandUtils
import com.octo.octo_beat_plugin.core.device.handler.*
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.parser.bluetooth.PacketBLParser
import com.octo.octo_beat_plugin.core.device.parser.ParsePacketErrorListener
import com.octo.octo_beat_plugin.core.device.tcp.TCPClientCallback
import com.octo.octo_beat_plugin.core.model.Packet
import com.octo.octo_beat_plugin.core.utils.ByteUtils
import com.octo.octo_beat_plugin.core.utils.CRC16CCITT
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import com.octo.octo_beat_plugin.core.utils.MyLog
import io.reactivex.Observable
import io.reactivex.disposables.Disposable
import io.reactivex.schedulers.Schedulers
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * Created by caoxuanphong on 12/16/17.
 */

class DXHDeviceHandler(private val context: Context,
                       var dxhDevice: DXHDevice?,
                       private val deviceHandlerCallback: DeviceHandlerCallback?,
                       var listener: ParsePacketErrorListener) : Runnable {
    private var packetBLParser: PacketBLParser? = null
    private var disposableReadingData: Disposable? = null
    private val TAG_DEBUG = "DEBUG LOG - "
    private val TAG_HANDLER = "DEVICE_HANDLER_LOG"
    private val typeLog = MyLog.TypeLog.DEBUG

    private val notifyHandlers: NotifyContainerHandler
    private val requestHandlers: RequestContainerHandler

    private var isInterrupted = false

    init {
        this.dxhDevice?.callback = deviceHandlerCallback
        packetBLParser = PacketBLParser(dxhDevice, listener)
        dxhDevice?.executor?.submit(subscribeReadingData())
        dxhDevice?.executor?.submit(packetBLParser)

        notifyHandlers = NotifyContainerHandler()
        requestHandlers = RequestContainerHandler()
                .addContext(context)
    }

    override fun run() {
        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_FOREGROUND)
        while (dxhDevice?.executor != null
                && !dxhDevice?.executor!!.isTerminating
                && !dxhDevice?.executor!!.isShutdown
                && !dxhDevice?.executor!!.isTerminated) {
            try {
                packetBLParser?.handleLowCapacity()
                val packet = packetBLParser?.inputStream?.read()
                packet?.let {
                    handleReceivedBluetoothPacket(it)
                }
            } catch (e: Exception) {
                MyLog.log(dxhDevice?.bluetoothClient?.bluetoothDevice?.name, " --> INTERRUPT")
                e.printStackTrace()
            }
        }

        cancelTask()
        Log.d(TAG, TAG_DEBUG + "EXIT INTERRUPT")
    }

    private fun cancelTask() {
        try {
            dxhDevice?.ssltcpSocketClient?.destroy()
            dxhDevice?.tcpSocketClient?.close()
            dxhDevice?.bluetoothClient?.close()
        } catch (ex: IOException) {
            ex.printStackTrace()
        } finally {
            dxhDevice?.ssltcpSocketClient = null
            dxhDevice?.tcpSocketClient = null
            dxhDevice?.bluetoothClient = null
            dxhDevice?.executor = null

            disposableReadingData?.dispose()
//            disposableSentKeepAlive?.dispose()
//            disposableAdaptiveKA?.dispose()
            dxhDevice?.tcpBuffer?.clear()
            MyLog.log(dxhDevice?.bluetoothClient?.bluetoothDevice?.name, " --> ERASE ALL")
        }
    }

    private var handshakedCallback = object : HandshakedCallback{
        override fun success() {
//            disposableSentKeepAlive = startSendKeepAlive()
        }

    }

    private var tcpClientCallback: TCPClientCallback = object : TCPClientCallback {

        override fun didConnected() {
            MyLog.log(dxhDevice?.clientId, "TCP CONNECTED")
            HandleOpenTcp.handleConnected(dxhDevice)
        }

        override fun didLostConnection() {
            MyLog.log(dxhDevice?.clientId,  "TCP LOST CONNECTION")
            NotifyLostTCPHandler.handle(dxhDevice)
        }

        override fun didReceiveData(data: ByteArray) {
            MyLog.log("-", "--------------------------------------------------------------\n---")
            MyLog.log(dxhDevice?.clientId, "RECEIVE TCP DATA:" + ByteUtils.toHexString(data))
            dxhDevice?.let {
                it.rx += data.size
                deviceHandlerCallback?.updateInfo(dxhDevice)
            }

            dxhDevice?.tcpBuffer?.put(data)
            NotifyReceiveTCPDataHandler.handle(dxhDevice, data.size)
        }

        override fun connectFailed() {
            MyLog.log(dxhDevice?.clientId, "TCP FAILED CONNECTION")
            HandleOpenTcp.handleTimeout(dxhDevice)
        }

        override fun timeout() {
            MyLog.log(dxhDevice?.clientId,"TCP CONNECTION TIMEOUT")
            HandleOpenTcp.handleTimeout(dxhDevice)
        }
    }

    private fun handleReceivedBluetoothPacket(packet: ByteArray) {
        val messagePack = MessagePackHelper.unpack(packet)
        if (messagePack == null) {
            Log.e(TAG, "receivedPacket: messagePack is null")
            return
        }
        val cmdCode = CommandUtils.getCode(MessagePackHelper.unpack(packet))
        notifyHandlers.handle(cmdCode, dxhDevice!!, packet, deviceHandlerCallback!!)
        requestHandlers.addHandShakeCallback(handshakedCallback).addTCPClientCallback(tcpClientCallback)
                .handle(cmdCode, dxhDevice!!, packet, deviceHandlerCallback!!)
    }

    companion object {
        private const val TAG = "DXHDeviceHandler"
    }

    private fun subscribeReadingData(): Runnable {
        return Runnable {
            val buffer = ByteArray(150 * 1024)
            while (dxhDevice?.executor != null
                    && !dxhDevice?.executor!!.isTerminating
                    && !dxhDevice?.executor!!.isShutdown
                    && !dxhDevice?.executor!!.isTerminated
            ) {
                val len = dxhDevice?.bluetoothClient?.read(buffer)
                len?.let { _len ->
                    if (_len > 0) {

                        try {
                            packetBLParser?.outputStream?.write(buffer, 0, _len)
                        } catch (e: Exception) {
                            e.printStackTrace()
                        }
                    }
                }
                try {
                    Thread.sleep(20)
                } catch (ex: InterruptedException) {
                    ex.printStackTrace()
                }
            }
        }
    }
}
