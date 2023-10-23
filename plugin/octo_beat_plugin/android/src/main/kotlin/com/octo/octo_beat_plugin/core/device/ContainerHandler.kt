package com.octo.octo_beat_plugin.core.device

import com.octo.octo_beat_plugin.core.device.model.DXHDevice
import com.octo.octo_beat_plugin.core.model.Packet

interface ContainerHandler {
    fun handle(code: Int, dxhDevice: DXHDevice, packet: ByteArray, deviceHandlerCallback: DeviceHandlerCallback)
}