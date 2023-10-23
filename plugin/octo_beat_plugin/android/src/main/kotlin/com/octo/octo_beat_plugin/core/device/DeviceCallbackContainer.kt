package com.octo.octo_beat_plugin.core.device

import com.octo.octo_beat_plugin.core.device.listener.ResponseListener

class DeviceCallbackContainer {
    private var rspSwModeListener: ResponseListener? = null

    fun setSwModeListener(listener: ResponseListener){
        this.rspSwModeListener = listener
    }

    fun getSWmodeListener(): ResponseListener? {
        return rspSwModeListener
    }

    fun removeRspSwModeListener(){
        this.rspSwModeListener = null
    }
}