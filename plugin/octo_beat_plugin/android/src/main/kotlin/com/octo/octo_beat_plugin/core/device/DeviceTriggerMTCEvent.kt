package com.octo.octo_beat_plugin.core.device

import com.octo.octo_beat_plugin.core.device.model.DXHDevice

interface DeviceTriggerMTCEvent {
    fun onEvent(dxhDevice: DXHDevice?)
}