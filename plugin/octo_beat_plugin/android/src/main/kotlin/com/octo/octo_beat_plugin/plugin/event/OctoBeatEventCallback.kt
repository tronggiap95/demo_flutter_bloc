package com.octo.octo_beat_plugin.plugin.event

import com.octo.octo_beat_plugin.core.device.model.DXHDevice


interface OctoBeatEventCallback {
    fun updateInfo(dxhDevice: DXHDevice)
    fun newMCTEvent(dxhDevice: DXHDevice)
}