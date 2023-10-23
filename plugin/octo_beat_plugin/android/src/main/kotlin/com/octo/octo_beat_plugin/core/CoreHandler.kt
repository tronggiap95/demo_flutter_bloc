package com.octo.octo_beat_plugin.core

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.util.Log
import com.octo.octo_beat_plugin.ForegroundService
import com.octo.octo_beat_plugin.core.modes.ConnectionCallback

import com.octo.octo_beat_plugin.core.bluetooth.BluetoothClient
import com.octo.octo_beat_plugin.core.device.ConnectionHandler
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.modes.*
import com.octo.octo_beat_plugin.core.utils.*
import com.octo.octo_beat_plugin.core.device.ConnectionHandler.Companion.TAG_CONNECTION_HANDLER
import com.octo.octo_beat_plugin.repository.entity.DeviceEntity
import com.octo.octo_beat_plugin.repository.repo.RepoManager
import com.lib.terminalio.TIOPeripheral
import java.util.concurrent.CopyOnWriteArrayList
import kotlin.collections.ArrayList

class CoreHandler(var service: ForegroundService) {
    private val TAG = "CoreHandler"
    private val typeLog = MyLog.TypeLog.DEBUG

    /**
     *  UI Update callback
     */
    private val coreHandlerCallbacks = ArrayList<CoreHandlerCallback>()
    private val connectionCallbacks = ArrayList<ConnectionCallback>()

    /**
     * network & bluetooth events
     */
    private var networkChangeReceiver: BroadcastReceiver? = null
    private var bluetoothAdapterCallback: FiotBluetoothAdapterState? = null


    /**
     *  Mode options
     */
    private val modeBLEManager: BLEModeManager = BLEModeManager(service.applicationContext)

    /**
     *  Lock thread
     */
    private var running = false

//    /**
//     * Notification handler for MCT EVENT, LEAD OFF, LOW BATTERY
//     */
//    private var notificationHandler = NotificationHandler()

    /**
     *  ConnectionHandlers which contain all the reconnecting or pairing tasks
     */

    private val connectionHandlers = ArrayList<ConnectionHandler>()

    init {
        RepoManager.initDB(service.applicationContext)
    }

    fun registerConnectionCallback(callback: ConnectionCallback) {
        this.connectionCallbacks.add(callback)
    }

    fun removeConnectionCallback(callback: ConnectionCallback) {
        if (this.connectionCallbacks.contains(callback)) {
            this.connectionCallbacks.remove(callback)
        }
    }

    fun registerCoreHandlerCallback(callback: CoreHandlerCallback) {
        this.coreHandlerCallbacks.add(callback)
    }

    fun unregisterCoreHandlerCallback(callback: CoreHandlerCallback) {
        if (this.coreHandlerCallbacks.contains(callback)) {
            this.coreHandlerCallbacks.remove(callback)
        }
    }

    fun removeAllConnectionCallback() {
        this.connectionCallbacks.clear()
    }

    private fun isDeviceReconnecting(mac: String): Boolean {
        connectionHandlers.forEach {
            if (it.dxhDevice?.bluetoothMacAddress == mac) {
                return true
            }
        }
        return false
    }

    private fun registerCoreBleCallback() {
        modeBLEManager.setBleCallback(object : CoreBleModeCallback {

            override fun onFailedConnection(bluetoothDevice: TIOPeripheral) {
                for (callback in connectionCallbacks) {
                    callback.connectFail(bluetoothDevice)
                }

            }

            override fun onLostConnection(dxhDevice: DXHDevice) {
                coreHandlerCallbacks.forEach {
                    it.lostConnection(dxhDevice)
                }
                reconnectDevice(dxhDevice.bluetoothMacAddress)
            }

            override fun onNewConnection(bluetoothClient: BluetoothClient) {}

            override fun onNewDevice(dxhDevice: DXHDevice) {
                dispoReconnecting(dxhDevice.bluetoothMacAddress, dxhDevice.clientId)
                Thread {
                    val deviceRepo = RepoManager.getDeviceRepo()
                    deviceRepo?.insert(
                        DeviceEntity(
                            dxhDevice.bluetoothMacAddress!!,
                            dxhDevice.clientId!!,
                            )
                    )
                }.start()
                for (callback in connectionCallbacks) {
                    Log.d(TAG, "new connection in: ${dxhDevice.clientId}")
                    callback.newDevice(dxhDevice)
                }
            }

            override fun onNewMctEvent(dxhDevice: DXHDevice) {
                coreHandlerCallbacks.forEach {
                    it.onNewMctEvent(dxhDevice)
                }
            }

            override fun updateInfo(dxhDevice: DXHDevice) {
                Log.d(TAG, "updateInfo: ${dxhDevice.clientId}")
                coreHandlerCallbacks.forEach {
                    it.updateInfo(dxhDevice)
                }
            }

            override fun updateECGData(dxhDevice: DXHDevice?) {
                coreHandlerCallbacks.forEach {
                    it.updateECGData(dxhDevice)
                }
            }

            override fun removeDeviceConnection(dxhDevice: DXHDevice?) {
                dispoReconnecting(dxhDevice?.bluetoothMacAddress, dxhDevice?.clientId)
                coreHandlerCallbacks.forEach {
                    it.removeDevice(dxhDevice)
                }
            }

            override fun receivedPacketIncorrectCRC(dxhDevice: DXHDevice?) {
                coreHandlerCallbacks.forEach {
                    it.crcError(dxhDevice)
                }
                coreHandlerCallbacks.forEach {
                    it.lostConnection(dxhDevice)
                }
                reconnectDevice(dxhDevice?.bluetoothMacAddress)
            }

            override fun receivedInvalidStatusCode(dxhDevice: DXHDevice?) {
                coreHandlerCallbacks.forEach {
                    it.invalidStatusCode(dxhDevice)
                }
                coreHandlerCallbacks.forEach {
                    it.lostConnection(dxhDevice)
                }
                reconnectDevice(dxhDevice?.bluetoothMacAddress)
            }

            override fun receivedInvalidPacketLength(dxhDevice: DXHDevice?) {
                coreHandlerCallbacks.forEach {
                    it.invalidPacketLength(dxhDevice)
                }
                coreHandlerCallbacks.forEach {
                    it.lostConnection(dxhDevice)
                }
                reconnectDevice(dxhDevice?.bluetoothMacAddress)
            }

            override fun receivedTimeOut(dxhDevice: DXHDevice?) {
                coreHandlerCallbacks.forEach {
                    it.packetReceivedTimeOut(dxhDevice)
                }
                coreHandlerCallbacks.forEach {
                    it.lostConnection(dxhDevice)
                }
                reconnectDevice(dxhDevice?.bluetoothMacAddress)
            }
        })
    }

    fun retrieveDeviceByMacAddress(mac: String?): DXHDevice? {
        if (mac == null) return null
        return modeBLEManager.retrieveDeviceByMacAddress(mac)
    }

    fun retrieveHandShakedDevice(): ArrayList<DXHDevice> {
        return modeBLEManager.retrieveHandShakedDevice()
    }
    fun retriveDevices(): CopyOnWriteArrayList<DXHDevice> {
        return modeBLEManager.devices()
    }


    fun handleDeleteDeviceFromUser(mac: String?): Boolean {
        dispoReconnecting(mac, "")
        return modeBLEManager.handleDeleteDeviceFromUser(mac)
    }

    fun handleDeleteAllDevices() {
        disposeAllConnectings()
        modeBLEManager.deleteAllDevices()
    }

    fun requestConnectToDeviceBLE(bluetoothDevice: TIOPeripheral) {
        modeBLEManager.requestConnectToDevice(bluetoothDevice)
    }


    private fun startListenBluetoothAdapterState() {
        bluetoothAdapterCallback = FiotBluetoothUtils.listenBluetoothState(
            this.service.applicationContext,
            object : FiotBluetoothUtils.FioTBluetoothStateListener {
                override fun onBluetoothOff() {
                    MyLog.log("NONE", "Bluetooth off")
                    modeBLEManager.onBlueOff()
                }

                override fun onBluetoothOn() {
                    MyLog.log("NONE", "Bluetooth on")
                    modeBLEManager.onBlueOn()
                }
            })
    }

    private fun registerNetworkStateChanged() {
        networkChangeReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                Log.d(TAG, "networkChangeReceiver: " + ConnectivityUtils.isConnected(context))
                modeBLEManager.notifyNetworkStatusChange(ConnectivityUtils.isConnected(context))
            }
        }

        try {
            this.service.applicationContext.unregisterReceiver(networkChangeReceiver)
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            this.service.applicationContext.registerReceiver(
                networkChangeReceiver,
                IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION)
            )
        }
    }

    fun reconnectAll() {
        retriveDevices().forEach {
            if (!isDeviceReconnecting(it.bluetoothMacAddress!!)) {
                val connectionHandler = ConnectionHandler(it).setDelayCount(1)
                connectionHandler.startReconnecting(service.applicationContext, modeBLEManager)
                connectionHandlers.add(connectionHandler)
            }
        }
    }

    /**
     * use to dispose reconnecting task
     */
    fun dispoReconnecting(mac: String?, name: String?) {
        if (mac == null) return
        val iterators = connectionHandlers.iterator()
        while (iterators.hasNext()) {
            val connectionHandler = iterators.next()
            if (connectionHandler.dxhDevice?.bluetoothMacAddress == mac) {
                Log.d(TAG_CONNECTION_HANDLER, "$name:DISPOSAL CONNECTING :$mac")
                connectionHandler.disposeTask()
                iterators.remove()
            }
        }
    }

    /**
     * Only use when signing out
     */
    fun disposeAllConnectings() {
        connectionHandlers.forEach {
            Log.d(
                TAG_CONNECTION_HANDLER,
                "${it.dxhDevice?.clientId}:SIGN OUT DISPOSABLE CONNECTING :${it.dxhDevice?.bluetoothMacAddress}"
            )
            it.disposeTask()
        }
        connectionHandlers.clear()
    }

    fun reconnectToPairedDevice(mac: String?) {
        if (mac == null) return
        retriveDevices().forEach {
            if (isDeviceReconnecting(mac)) {
                dispoReconnecting(mac, it.clientId)
            }
            if (it.bluetoothMacAddress == mac) {
                val connectionHandler = ConnectionHandler(it)
                connectionHandler.startReconnecting(service.applicationContext, modeBLEManager)
                connectionHandlers.add(connectionHandler)
            }
        }
    }

    /**
     * Reconnect when device is lost connection
     */

    fun reconnectDevice(mac: String?) {
        if (mac == null) return
        retriveDevices().forEach {
            if (it.bluetoothMacAddress == mac && !isDeviceReconnecting(mac)) {
                val connectionHandler = ConnectionHandler(it)
                connectionHandler.startReconnecting(service.applicationContext, modeBLEManager)
                connectionHandlers.add(connectionHandler)
            }
        }
    }

    fun onCreate() {
        synchronized(running) {
            Log.d(TAG, "onCreate")
            try {
                registerCoreBleCallback()
                registerNetworkStateChanged()
                startListenBluetoothAdapterState()
            } catch (ex: Exception) {
                ex.printStackTrace()
            }
        }
    }

    fun onStart() {
        synchronized(running) {
            Log.d(TAG, "onStart")
            modeBLEManager.startPeripheralHandler()
        }
    }

    fun onStop() {
        synchronized(running) {
            Log.d(TAG, "onStop")
            try {
                modeBLEManager.closeAllConnection()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    fun onDestroy() {
        synchronized(running) {
            Log.d(TAG, "onDestroy")

            try {
                coreHandlerCallbacks.clear()
                connectionCallbacks.clear()
                bluetoothAdapterCallback?.stopListener(this.service.applicationContext)
            } catch (e: java.lang.Exception) {
            }

            try {
                this.service.applicationContext.unregisterReceiver(networkChangeReceiver)
            } catch (e: Exception) {
            }
        }
    }
}
