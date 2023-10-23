package com.octo.octo_beat_plugin.core.device.handler

import android.content.Context
import android.util.Log
import com.octo.octo_beat_plugin.core.device._enum.EventTCP
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.parser.tcp.PacketTCPParser
import com.octo.octo_beat_plugin.core.model.Packet
import com.octo.octo_beat_plugin.core.utils.ByteUtils
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper
import org.msgpack.value.Value

class TCPDataHandler(var dxhDevice: DXHDevice?, var context: Context) : Runnable {
    private var packetTCPParser: PacketTCPParser? = null
    private var connectionId: Int? = null

    init {
        packetTCPParser = PacketTCPParser(dxhDevice, null)
        dxhDevice?.executor?.submit(packetTCPParser)
    }

    override fun run() {
        while (!dxhDevice?.executor?.isShutdown!! &&
                !dxhDevice?.executor?.isTerminated!!) {
            try {
                Log.d(TAG, "run: wait new tcp packet ...")
                Log.d(TAG, "name ${dxhDevice?.bluetoothClient?.bluetoothDevice?.name} handle tcp packet")
                val packet = try {
                    packetTCPParser?.inputStream?.read()
                } catch (e: InterruptedException) {
                    e.printStackTrace()
                    null
                }

                packet?.let {
                    handleReceivedTCPPacket(it)
                }
            } catch (e: InterruptedException) {
                Log.d(TAG, "name ${dxhDevice?.bluetoothClient?.bluetoothDevice?.name} DXHDeviceHandler Interrupted")
                e.printStackTrace()
                break
            }
        }

        Log.d(TAG, "run: exit receive packet")
    }

    private fun handleReceivedTCPPacket(packet: Packet) {
        val messagePack = MessagePackHelper.unpackRaw(packet.payloadData)
        Log.d(TAG, "unpack: $messagePack")

        if (isInvalidEvent(messagePack)) {
            dxhDevice?.sendDataToTCPServer(dxhDevice, connectionId!!, packet.buildOriginalPacket())
            return
        }

        when (messagePack.asMapValue().keyValueArray[1].asStringValue().asString()) {
//            EventTCP.MCT_TRIGGER.value -> {
//                dxhDevice?.sendDataToTCPServer(dxhDevice, connectionId!!, packet.buildOriginalPacket())
//                HandleTriggerMCT.handle(dxhDevice, connectionId, packet, context)
//            }
            EventTCP.MCT_EVENT.value -> {
                HandleMCTEvent.handle(dxhDevice, connectionId!!, packet)
            }
            else -> {
                dxhDevice?.sendDataToTCPServer(dxhDevice, connectionId!!, packet.buildOriginalPacket())
            }
        }
    }

    private fun isInvalidEvent(messagePack: Value?): Boolean {
        if (messagePack == null) {
            return true
        }

        val keyValueArray = messagePack.asMapValue().keyValueArray
        if (keyValueArray.size < 2) {
            return true
        }

        val tcpEvent = keyValueArray[1].asStringValue().asString()
        Log.d(TAG, "TCP EVENT: $tcpEvent")
        if (tcpEvent.isNullOrEmpty()) {
            return true
        }

        return false
    }

    fun readTCPData(payloadData: ByteArray) {
        if (dxhDevice == null || !dxhDevice?.isBluetoothConnected!!) {
            Log.e(TAG, "readTCPData: null")
            return
        }

        if (!dxhDevice!!.handShaked) {
            Log.e(TAG, "readTCPData: device did not handshake")
            return
        }

        try {
            val value = MessagePackHelper.unpackRaw(payloadData)

            connectionId = value!!.asArrayValue().get(1).asIntegerValue().asInt()
            val bin = value.asArrayValue().get(2).asBinaryValue().asByteArray()

            Log.d(TAG, "connectionId: $connectionId")
            Log.d(TAG, "TCP DATA: ${ByteUtils.toHexString(payloadData)}")
            Log.d(TAG, " read TCP Bin: size: ${bin.size} " + ByteUtils.toHexString(bin))

            bin?.let { packetTCPParser?.outputStream?.write(bin, 0, bin.size) }
                    ?: Log.e(TAG, "readTCPData: data is null")

        } catch (e: Exception) {
            e.printStackTrace()
        }

    }

    companion object {
        private const val TAG = "TCPDataHandler"
    }

}