package com.octo.octo_beat_plugin.core.device.handler;

import android.content.Context;
import android.util.Log;

import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.HandShakeCmd;
import com.octo.octo_beat_plugin.core.device.command.NetStatusCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.utils.ConnectivityUtils;

import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/20/17.
 */

/**
 * Test case
 * 1 - Not handshake
 * 2 - handshake - no network
 * 3 - handshake - have network
 * 4 - Exception - input invalid, bluetooth socket couldn't send
 */
public class NetStatusHandler {
    private static final String TAG = "NetStatusHandler";

    public static void handle(DXHDevice dxhDevice, Context context) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        byte[] data = null;

        if (!dxhDevice.getHandShaked()) {
            data = NetStatusCmd.response(BB_RSP_ERR_PERMISSION.value, false);
            Log.w(TAG, "handle: BB_RSP_ERR_PERMISSION");
        } else {
            data = NetStatusCmd.response(BB_RSP_OK.value, ConnectivityUtils.isConnected(context));
            Log.d(TAG, "handle: BB_RSP_OK");
        }

        if (data != null) {
            byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
            if(encryptedPacket != null) {
                dxhDevice.send(encryptedPacket);
            }
        } else {
            Log.w(TAG, "handle: data is null");
        }

    }
}
