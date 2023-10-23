package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.NotifyTCPLostCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.model.TCPConnection;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class NotifyLostTCPHandler {
    private static final String TAG = "NotifyLostTCPHandler";

    public static void handle(DXHDevice dxhDevice) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        for (TCPConnection tcpConnection : dxhDevice.getTcpConnections()) {
            byte[] data = NotifyTCPLostCmd.response(tcpConnection.id);

            if (data != null) {
                byte[] encryptedPacket = CommandUtils.packPacketNotify(data, dxhDevice);
                if(encryptedPacket != null) {
                    dxhDevice.send(encryptedPacket);
                }
            } else {
                Log.w(TAG, "handle: data is null");
            }
        }
    }
}
