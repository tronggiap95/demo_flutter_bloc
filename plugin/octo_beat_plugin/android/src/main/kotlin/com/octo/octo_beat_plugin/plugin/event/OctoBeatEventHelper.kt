package com.octo.octo_beat_plugin.plugin.event

import android.content.Context
import android.util.Log
import com.octo.octo_beat_plugin.ForegroundService
import com.octo.octo_beat_plugin.core.CoreHandlerCallback
import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.repository.SingletonHolder

class OctoBeatEventHelper private constructor(private val context: Context) : CoreHandlerCallback {
    companion object : SingletonHolder<OctoBeatEventHelper, Context>(::OctoBeatEventHelper)

    var mService: ForegroundService? = null
    var mOctoHEventCallback: OctoBeatEventCallback? = null

    fun onServiceStarted(service: ForegroundService?) {
        mService = service
        mService?.coreHandler?.unregisterCoreHandlerCallback(this)
        mService?.coreHandler?.registerCoreHandlerCallback(this)
    }

    fun setEventHandlerCallback(octoHEventCallback: OctoBeatEventCallback) {
        mOctoHEventCallback = octoHEventCallback
    }
    // ======= CoreHandlerCallback ========= //
    override fun removeDevice(device: DXHDevice?) {
        Log.d("TAGGGGGGGG", "removeDevice")
    }

    override fun lostConnection(device: DXHDevice?) {
        Log.d("TAGGGGGGGG", "lostConnection")
        device?.let {
            mOctoHEventCallback?.updateInfo(it)
        }
    }

    override fun updateInfo(dxhDevice: DXHDevice?) {
        dxhDevice?.let {
            mOctoHEventCallback?.updateInfo(it)
        }
    }

    override fun updateECGData(dxhDevice: DXHDevice?) {
        Log.d("TAGGGGGGGG", "updateECGData")
    }

    override fun crcError(dxhDevice: DXHDevice?) {
        Log.d("TAGGGGGGGG", "crcError")
    }

    override fun invalidStatusCode(dxhDevice: DXHDevice?) {
        Log.d("TAGGGGGGGG", "invalidStatusCode")
    }

    override fun invalidPacketLength(dxhDevice: DXHDevice?) {
        Log.d("TAGGGGGGGG", "invalidPacketLength")
    }

    override fun packetReceivedTimeOut(dxhDevice: DXHDevice?) {
        Log.d("TAGGGGGGGG", "packetReceivedTimeOut")
    }

    override fun onNewMctEvent(dxhDevice: DXHDevice?) {
        Log.d("TAGGGGGGGG", "onNewMctEvent")
        dxhDevice?.let {
            mOctoHEventCallback?.newMCTEvent(it)
        }
    }
    ///

}
