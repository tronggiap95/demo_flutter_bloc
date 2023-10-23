package com.octo.octo_beat_plugin.core;

import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

/**
 * Created by caoxuanphong on 12/25/17.
 */

public interface CoreHandlerCallback {
    void removeDevice(DXHDevice device);

    void lostConnection(DXHDevice device);

    void updateInfo(DXHDevice dxhDevice);

    void updateECGData(DXHDevice dxhDevice);

    void crcError(DXHDevice dxhDevice);

    void invalidStatusCode(DXHDevice dxhDevice);

    void invalidPacketLength(DXHDevice dxhDevice);

    void packetReceivedTimeOut(DXHDevice dxhDevice);

    void onNewMctEvent(DXHDevice dxhDevice);
}
