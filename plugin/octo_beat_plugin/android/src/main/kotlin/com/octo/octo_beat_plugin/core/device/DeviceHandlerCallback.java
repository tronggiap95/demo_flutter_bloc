package com.octo.octo_beat_plugin.core.device;

import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

/**
 * Created by caoxuanphong on 12/26/17.
 */

public interface DeviceHandlerCallback {
    void newConnection(DXHDevice dxhDevice);

    void updateInfo(DXHDevice dxhDevice);

    void updateECGData(DXHDevice dxhDevice);

    void newMctEvent(DXHDevice dxhDevice);
}
