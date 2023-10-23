package com.octo.octo_beat_plugin.plugin.connection

import android.content.Context
import android.util.Log
import com.octo.octo_beat_plugin.ForegroundService
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.modes.ConnectionCallback
import com.octo.octo_beat_plugin.repository.SingletonHolder
import com.octo.octo_beat_plugin.repository.entity.DeviceEntity
import com.octo.octo_beat_plugin.repository.repo.RepoManager
import com.lib.terminalio.TIOManager
import com.lib.terminalio.TIOManagerCallback
import com.lib.terminalio.TIOPeripheral
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class OctoBeatConnectionHelper private constructor(private val context: Context) {
    companion object : SingletonHolder<OctoBeatConnectionHelper, Context>(::OctoBeatConnectionHelper)

    private val TAG = "OctoBeatConnectionHelper"
    private var mService: ForegroundService? = null

    private var mTio: TIOManager? = null
    private var selectedDevice: TIOPeripheral? = null
    private var mPeripheralList = ArrayList<TIOPeripheral>()

    // callback to ui
    private var octoBeatConnectionCallback: OctoBeatConnectionCallback? = null

    // callback from core handler
    val connectionBLECallback: ConnectionCallback = object : ConnectionCallback {
        override fun newDevice(dxhDevice: DXHDevice?) {
            dxhDevice?.let {
                addDeviceToDB(it)
                val device = createDeviceMap(
                    name = it.clientId ?: "",
                    address = it.bluetoothMacAddress ?: ""
                )
                octoBeatConnectionCallback?.onConnectedOctoBeat(device)
            }
        }

        override fun connectFail(device: TIOPeripheral?) {
            if (selectedDevice?.address == device?.address) {
                octoBeatConnectionCallback?.onConnectFailOctoBeat()
            }
        }
    }

    init {
        TIOManager.enableTrace(false)
        mTio = TIOManager.getInstance()
    }

    fun onServiceStarted(service: ForegroundService?) {
        mService = service

        mService?.coreHandler?.removeAllConnectionCallback()
        mService?.coreHandler?.registerConnectionCallback(connectionBLECallback)
    }

    fun setConnectionCallback(callback: OctoBeatConnectionCallback) {
        octoBeatConnectionCallback = callback
    }

    fun handleStartScan(result: MethodChannel.Result) {
        cleanUpTio()
        mTio?.startScan(object : TIOManagerCallback {
            override fun onPeripheralFound(peripheral: TIOPeripheral?) {
                peripheral ?: return
                Log.d("TAGGGGGGG", "onPeripheralFound: ${peripheral.name}")
                val device = mService?.coreHandler?.retrieveDeviceByMacAddress(peripheral.address)
                if (device == null) {
                    if (!isPeripheralInScannedList(peripheral)) {
                        mPeripheralList.add(peripheral)
                        val mapDevices = createMapFoundedDevices()
                        octoBeatConnectionCallback?.onFoundOctoBeat(mapDevices)
                    }
                }

            }

            override fun onPeripheralUpdate(peripheral: TIOPeripheral?) {
            }
        })
        result.success(true)
    }

    fun handleStopScan(result: MethodChannel.Result) {
        try {
            mTio?.stopScan()
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
        result.success(true)
    }

    fun requestConnectToDeviceBLE(args: ArrayList<*>?, result: MethodChannel.Result) {
        args ?: return
        val uuid = args[0] as String
        for (device in mPeripheralList) {
            if (device.address == uuid) {
                selectedDevice = device
                mService?.coreHandler?.requestConnectToDeviceBLE(device)
            }
        }
        result.success(true)
    }

    fun deleteDevice(result: MethodChannel.Result) {
        Thread {
            mService?.coreHandler?.handleDeleteAllDevices()
        }.start()
        result.success(true)
    }

    private fun addDeviceToDB(dxhDevice: DXHDevice) {
        val deviceEntity = DeviceEntity(dxhDevice.bluetoothMacAddress!!, dxhDevice.clientId!!,)
        Thread {
            RepoManager.getDeviceRepo()?.insert(deviceEntity)
        }.start()
    }

    private fun cleanUpTio() {
        try {
            mPeripheralList.clear()
            mTio?.peripherals?.forEach {
                if (!it.shallBeSaved()) {
                    mTio?.removePeripheral(it)
                }
            }
            mTio?.removeAllPeripherals()
        } catch (ex: Exception) {
            ex.printStackTrace()
        }
    }

    private fun isPeripheralInScannedList(peripheral: TIOPeripheral): Boolean {
        mPeripheralList.forEach {
            if (it.address == peripheral.address) {
                return true
            }
        }
        return false
    }

    // parse data //
    private fun createDeviceMap(name: String, address: String): Map<String, String> {
        return mapOf(
            "name" to name,
            "address" to address
        )
    }

    private fun createMapFoundedDevices(): ArrayList<Map<String, String>> {
        val devices = ArrayList<Map<String, String>>()
        mPeripheralList.forEach {
            val device = createDeviceMap(
                name = it.name,
                address = it.address
            )
            devices.add(device)
        }
        return devices
    }
    //===========//
}
