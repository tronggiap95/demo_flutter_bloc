package com.octo.octo_beat_plugin.core.modes;

import com.lib.terminalio.TIOPeripheral;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

/**
 * Created by caoxuanphong on 12/25/17.
 */

public interface ConnectionCallback {
    void newDevice(DXHDevice dxhDevice);

    void connectFail(TIOPeripheral device);
}
