package com.octo.octo_beat_plugin

import android.content.Context
import com.octo.octo_beat_plugin.core.CoreHandler
import com.octo.octo_beat_plugin.core.device.handler.HandleConfirmedMCT
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.device.model.MCTInstance
import com.octo.octo_beat_plugin.plugin.event.ObjectParser
import com.octo.octo_beat_plugin.repository.SingletonHolder
import com.octo.octo_beat_plugin.repository.entity.DeviceEntity
import com.octo.octo_beat_plugin.repository.repo.RepoManager
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

class OctoBeatHelper private constructor(val context: Context) {
    companion object : SingletonHolder<OctoBeatHelper, Context>(::OctoBeatHelper)

    private var mService: ForegroundService? = null

    fun onServiceStarted(service: ForegroundService?) {
        mService = service
    }

    fun submitMctEvent(args: ArrayList<*>?, result: MethodChannel.Result) {
        args ?: return
        val evTime = args[0] as Int
        val symptoms = (args[1] as ArrayList<Int>).toList().toIntArray()


        val devices = mService?.coreHandler?.retriveDevices()
        if (devices == null || devices.isEmpty()) {
            result.success(null)
            return
        }

        HandleConfirmedMCT.handle(
            dxhDevice = devices[0],
            mctInstance =  MCTInstance(triggerTime = evTime.toLong(), deviceTriggerTime = evTime.toLong()),
            symptoms = symptoms
        )
    }

    fun getDeviceInfo(result: MethodChannel.Result) {
        val dxhDevices = mService?.coreHandler?.retriveDevices()
        if (dxhDevices == null || dxhDevices.isEmpty()) {
            getLocalDevice{
                devices ->
                if (devices == null){
                    result.success(null)
                    return@getLocalDevice
                }
                val deviceInfoMap = ObjectParser.parseDeviceInfo(devices[0])
                result.success(deviceInfoMap)
                reconnectFirstOpen(devices, mService?.coreHandler)
            }
            return
        }

        val deviceInfoMap = ObjectParser.parseDeviceInfo(dxhDevices[0])
        result.success(deviceInfoMap)
    }

    private fun getLocalDevice( result: (localDevices: List<DeviceEntity>?) -> Unit) {
        Thread {
            try {
                val devices = RepoManager.getDeviceRepo()?.getDevices()

                if (devices == null) {
                    result(null)
                    return@Thread
                }

                if (devices.isEmpty()) {
                    result(null)
                    return@Thread
                }
                result(devices)
            } catch (ex: Exception) {
                result(null)
            }
        }.start()
    }

    private fun reconnectFirstOpen(localDevices: List<DeviceEntity>?, coreHandler: CoreHandler?) {
        val dxhDevices = ArrayList<DXHDevice>()
        localDevices?.forEach { deviceEntity ->
            val dxhDevice = DXHDevice(deviceEntity.name)
            dxhDevice.bluetoothMacAddress = deviceEntity.address
            dxhDevices.add(dxhDevice)
        }
        coreHandler?.retriveDevices()?.clear()
        coreHandler?.retriveDevices()?.addAll(dxhDevices)
        coreHandler?.reconnectAll()
    }
}