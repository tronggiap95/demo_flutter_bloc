package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.NetStatusChangeCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class NotifyNetStatusChangeHandler {
    private static final String TAG = "NetStatusChangeHandler";

    public static void handle(DXHDevice dxhDevice, boolean available) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "Device is not connected");
            return;
        }

        byte[] data = NetStatusChangeCmd.response(available);

        if (data != null) {
            byte[] encryptedPacket = CommandUtils.packPacketNotify(data, dxhDevice);
            if(encryptedPacket != null) {
                dxhDevice.send(encryptedPacket);
            }
        } else {
            Log.w(TAG, "Sent data is null");
        }
    }
}
