package com.octo.octo_beat_plugin.core.modes

import android.bluetooth.BluetoothDevice
import android.content.Context
import android.os.Message
import android.util.Log
import com.octo.octo_beat_plugin.core.ble.BluetoothConnectionCallback
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient
import com.octo.octo_beat_plugin.core.bluetooth.BluetoothConnectHandler
import com.octo.octo_beat_plugin.core.device.DXHDeviceHandler
import com.octo.octo_beat_plugin.core.device.DeviceHandlerCallback
import com.octo.octo_beat_plugin.core.device._enum.BluetoothConnectionType
import com.octo.octo_beat_plugin.core.device.handler.NotifyNetStatusChangeHandler
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.parser.ParsePacketErrorListener
import com.octo.octo_beat_plugin.core.model.ConnectionParams
import com.octo.octo_beat_plugin.core.utils.MyLog
import com.octo.octo_beat_plugin.core.utils.ThreadPoolCreater
import com.octo.octo_beat_plugin.repository.repo.RepoManager
import com.lib.terminalio.TIOManager
import com.lib.terminalio.TIOPeripheral
import java.util.ArrayList
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import kotlin.concurrent.thread

/**********************************************************************************************
 *                                          BLE MODE                                          *
 **********************************************************************************************/
class BLEModeManager(var context: Context) : BluetoothMode, ParsePacketErrorListener {
    override fun receivedPacketIncorrectCRC(dxhDevice: DXHDevice?) {
        coreBleModeCallback?.receivedPacketIncorrectCRC(dxhDevice)
        closeConnection(dxhDevice!!)
    }

    override fun receivedInvalidStatusCode(dxhDevice: DXHDevice?) {
        coreBleModeCallback?.receivedInvalidStatusCode(dxhDevice)
        closeConnection(dxhDevice!!)
    }

    override fun receivedInvalidPacketLength(dxhDevice: DXHDevice?) {
        coreBleModeCallback?.receivedInvalidPacketLength(dxhDevice)
        closeConnection(dxhDevice!!)
    }

    override fun receivedTimeOut(dxhDevice: DXHDevice?) {
        coreBleModeCallback?.receivedTimeOut(dxhDevice)
        closeConnection(dxhDevice!!)
    }

    private val TAG = "BLEModeManager"
    private val typeLog = MyLog.TypeLog.DEBUG

    private val dxhDevices = CopyOnWriteArrayList<DXHDevice>()

    private var bleConnectHandler: BluetoothConnectHandler? = null
    private var bleSocketCallback: BluetoothConnectionCallback? = null

    private var running = false

    private var coreBleModeCallback: CoreBleModeCallback? = null

    private var isSupported = false

    private var isBlueOn = true

    fun setBleCallback(coreBleModeCallback: CoreBleModeCallback) {
        this.coreBleModeCallback = coreBleModeCallback
    }

    fun startPeripheralHandler() {
        synchronized(running) {
            running = true
            bleSocketCallback = object : BluetoothConnectionCallback {
                override fun onError(errorCode: Int) {
                    //
                }

                override fun didConnectFail(bluetoothDevice: TIOPeripheral) {
                    MyLog.log(bluetoothDevice.name, "FAILED CONNECTION")
                    coreBleModeCallback?.onFailedConnection(bluetoothDevice)
                }

                override fun didNewConnection(bluetoothClient: BluetoothClient): Boolean {
                    synchronized(running) {
                        if (running) {
                            coreBleModeCallback?.onNewConnection(bluetoothClient)
                            handleNewConnectedBluetoothSocket(bluetoothClient, false)
                        }
                        return running
                    }
                }

                override fun didLostConnection(bluetoothClient: BluetoothClient) {
                    synchronized(running) {
                        handleDisconnectedBluetoothSocket(bluetoothClient)
                    }
                }
            }

            if (bleConnectHandler == null) {
                bleConnectHandler = BluetoothConnectHandler(context, bleSocketCallback!!)
                bleConnectHandler?.start()
            }
        }
    }

    override fun requestConnectToDevice(bluetoothDevice: TIOPeripheral) {
        Log.d(TAG, "requestConnectToDeviceBLE = " + bluetoothDevice.name)
        if (!isBlueOn) {
            Log.d(TAG, "IGNORE CONNECT DUE TO BLUE OFF")
            return
        }
        val message = Message()
        message.obj = ConnectionParams(bluetoothDevice, BluetoothConnectionType.BLUETOOTH_BLE)
        bleConnectHandler?.handler?.sendMessage(message)
    }

    override fun handleNewConnectedBluetoothSocket(
        bluetoothClient: BluetoothClient?,
        retrictConnect: Boolean
    ) {
        Log.d(TAG, "handleNewConnectedDevice = " + bluetoothClient?.bluetoothDevice?.name)
        isSupported = false

        var dxhDevice: DXHDevice? = null
        dxhDevices.forEach { device ->
            if (device.bluetoothMacAddress == bluetoothClient?.bluetoothDevice?.address) {
                dxhDevice = device
                dxhDevice?.bluetoothClient = null
                dxhDevice?.bluetoothMacAddress = bluetoothClient?.bluetoothDevice?.address
                dxhDevice?.bluetoothClient = bluetoothClient
            }
        }

        if (dxhDevice == null) {
            dxhDevice = DXHDevice(bluetoothClient!!)
            dxhDevice?.bluetoothMacAddress = bluetoothClient.bluetoothDevice.address
        }

        // In case, bluetooth connection was closed but still on timeout,
        // then there is new bluetooth connection
        dxhDevice?.executor?.shutdownNow()
        try {
            dxhDevice?.executor?.awaitTermination(1, TimeUnit.SECONDS)
        } catch (e: InterruptedException) {
            e.printStackTrace()
        }

        dxhDevice?.executor = ThreadPoolCreater.create()
        dxhDevice?.bluetoothConnectionType = BluetoothConnectionType.BLUETOOTH_BLE
        val dxhDeviceHandler = DXHDeviceHandler(context, dxhDevice, object : DeviceHandlerCallback {
            override fun newConnection(dxhDevice: DXHDevice) {
                Log.d(TAG, "new connection out: ${dxhDevice.clientId}")
                if (retrieveDevice(dxhDevice.bluetoothClient) == null) {
                    dxhDevices.add(dxhDevice)
                }
                coreBleModeCallback?.onNewDevice(dxhDevice)
            }

            override fun newMctEvent(dxhDevice: DXHDevice) {
                coreBleModeCallback?.onNewMctEvent(dxhDevice)
            }

            override fun updateInfo(dxhDevice: DXHDevice) {
                coreBleModeCallback?.updateInfo(dxhDevice)
            }

            override fun updateECGData(dxhDevice: DXHDevice?) {
                coreBleModeCallback?.updateECGData(dxhDevice)
            }
        }, this)

        dxhDevice?.executor?.submit(dxhDeviceHandler)
    }

    override fun handleDisconnectedBluetoothSocket(bluetoothClient: BluetoothClient?) {
        bluetoothClient?.close()
        val device = retrieveDevice(bluetoothClient)
        device?.let { device ->
            closeConnection(device)
            coreBleModeCallback?.onLostConnection(device)
            Log.d(TAG, "handleDisconnectedDevice = " + bluetoothClient?.bluetoothDevice?.name)
        }
    }

    fun removeDevice(address: String) {
        val iterator = dxhDevices.iterator()
        while (iterator.hasNext()) {
            val device = iterator.next()
            if (device.bluetoothMacAddress == address) {
                iterator.remove()
            }
        }
    }

    override fun devices(): CopyOnWriteArrayList<DXHDevice> {
        return dxhDevices
    }

    override fun retrieveDevice(bluetoothClient: BluetoothClient?): DXHDevice? {
        for (device in dxhDevices) {
            if (device.bluetoothClient?.bluetoothDevice?.address == bluetoothClient?.bluetoothDevice?.address ||
                    device?.bluetoothMacAddress === bluetoothClient?.bluetoothDevice?.address) {
                return device
            }
        }
        return null
    }

    override fun deleteDevice(dxhDevice: DXHDevice?) {
        dxhDevice?.let {
            closeConnection(dxhDevice)
            removeDevice(dxhDevice)
        }
    }


    override fun closeConnection(dxhDevice: DXHDevice) {
        try {
            try {
                dxhDevice.bluetoothClient?.close()
            } catch (ex: Exception) {
            }

            try {
                dxhDevice.ssltcpSocketClient?.close()
            } catch (ex: Exception) {
            }

            try {
                dxhDevice.tcpSocketClient?.close()
            } catch (ex: Exception) {
            }
        } catch (ex: Exception) {
        } finally {
            dxhDevice.bluetoothClient = null
            dxhDevice.ssltcpSocketClient = null
            dxhDevice.tcpSocketClient = null
            dxhDevice.executor?.shutdownNow()
            try {
                dxhDevice.executor?.awaitTermination(1, TimeUnit.SECONDS)
            } catch (e: InterruptedException) {
            }
        }
    }

    override fun removeDevice(dxhDevice: DXHDevice) {
        coreBleModeCallback?.removeDeviceConnection(dxhDevice)
        dxhDevices.remove(dxhDevice)
    }

    override fun handleDisconnectedDevice(dxhDevice: DXHDevice?) {
        dxhDevice?.let { device ->
            coreBleModeCallback?.onLostConnection(dxhDevice)
            device.executor?.shutdownNow()
            try {
                device.executor?.awaitTermination(1, TimeUnit.SECONDS)
            } catch (e: InterruptedException) {
                e.printStackTrace()
            } finally {
                Log.d(TAG, "handleDisconnectedDevice done")
            }
        }
    }

    override fun isIgnoringDevice(address: String?): Boolean {
        if (address == null) {
            Log.d(TAG, "Ignore device $address because of device address is null")
            return true
        }

        if (dxhDevices.isNullOrEmpty()) {
            Log.d(TAG, "Ignore device $address because of devices list is empty")
            return true
        }

        if (retrieveDeviceByMacAddress(address) == null) {
            Log.d(
                TAG,
                "Ignore device $address because of devices doesn't exist in the devices list"
            )
            return true
        }

        return false
    }

    override fun retrieveDeviceByMacAddress(mac: String): DXHDevice? {
        if (mac.isEmpty()) {
            return null
        }

        for (dxhDevice in dxhDevices) {
            if (dxhDevice.bluetoothMacAddress == mac) {
                return dxhDevice
            }
        }
        return null
    }


    override fun onBlueOff() {
        isBlueOn = false
        dxhDevices.forEach {
            it.bluetoothClient?.close()
            it.bluetoothClient = null
            handleDisconnectedDevice(it)
        }
    }

    override fun onBlueOn() {
        isBlueOn = true
    }

    fun notifyNetworkStatusChange(available: Boolean) {
        for (dxhDevice in dxhDevices) {
            NotifyNetStatusChangeHandler.handle(dxhDevice, available)
        }
    }

    override fun retrieveHandShakedDevice(): ArrayList<DXHDevice> {
        val devices = ArrayList<DXHDevice>()
        dxhDevices.forEach {
            if (it.clientId != null)
                devices.add(it)
        }
        return devices
    }

    fun closeAllConnection() {
        for (i in dxhDevices.indices) {
            closeConnection(dxhDevices[i])
        }
    }

    fun deleteAllDevices() {
        devices().forEach {
            handleDeleteDeviceFromUser(it.bluetoothMacAddress)
        }
    }

    fun handleDeleteDeviceFromUser(mac: String?): Boolean {
        if (mac == null) return false
        val dxhDevice = retrieveDeviceByMacAddress(mac) ?: return false
        Log.d(TAG, "remove device: ${dxhDevice.clientId}")
        deleteDevice(dxhDevice)
        thread { RepoManager.getDeviceRepo()?.deleteDeviceByMac(mac) }
        TIOManager.getInstance().removePeripheral(mac)
        return true
    }
}