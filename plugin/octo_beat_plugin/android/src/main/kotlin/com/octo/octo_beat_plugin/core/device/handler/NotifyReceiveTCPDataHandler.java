package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.NotifyTCPReceiveDataCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

/**
 * Created by caoxuanphong on 12/21/17.
 */

public class NotifyReceiveTCPDataHandler {
    private static final String TAG = "TransmitDataHandler";

    // FIXME: Support multiple connection id
    public static void handle(DXHDevice dxhDevice, int dataLength) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        if (!dxhDevice.getHandShaked()) {
            Log.e(TAG, "handle: device did not handshake");
            return;
        }

        try {
            byte[] data = NotifyTCPReceiveDataCmd.response(1, dataLength);
            byte[] encryptedPacket = CommandUtils.packPacketNotify(data, dxhDevice);
            if(encryptedPacket != null) {
                dxhDevice.send(encryptedPacket);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
