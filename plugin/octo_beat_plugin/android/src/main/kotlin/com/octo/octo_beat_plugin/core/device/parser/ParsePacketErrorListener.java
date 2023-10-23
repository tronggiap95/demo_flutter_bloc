package com.octo.octo_beat_plugin.core.device.parser;

import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

/**
 * Created by phong on 1/24/18.
 */

public interface ParsePacketErrorListener {
    void receivedPacketIncorrectCRC(DXHDevice dxhDevice);
    void receivedInvalidStatusCode(DXHDevice dxhDevice);
    void receivedInvalidPacketLength(DXHDevice dxhDevice);
    void receivedTimeOut(DXHDevice dxhDevice);
}
