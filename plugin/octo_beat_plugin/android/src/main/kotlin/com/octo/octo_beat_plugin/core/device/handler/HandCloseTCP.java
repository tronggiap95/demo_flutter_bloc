package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import org.json.JSONArray;

import com.octo.octo_beat_plugin.core.device.command.CloseTCPCmd;
import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.model.TCPConnection;

import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class HandCloseTCP {
    private static final String TAG = "HandCloseTCP";

    public static void handle(DXHDevice dxhDevice, JSONArray messagePack) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        if (dxhDevice.getTcpBuffer() != null) {
            dxhDevice.getTcpBuffer().clear();
        }

        byte[] data;

        if (!dxhDevice.getHandShaked()) {
            data = CloseTCPCmd.response(BB_RSP_ERR_PERMISSION.value);
            Log.d(TAG, "handle: BB_RSP_ERR_PERMISSION");
        } else {
            try {
                int connectionId = messagePack.getInt(1);
                Log.d(TAG, "connection id: " + connectionId);

                TCPConnection tcpConnection = dxhDevice.retrieveTCPConnection(connectionId);
                if (tcpConnection == null) {
                    data = CloseTCPCmd.response(BB_RSP_ERR_PARAM.value);
                    Log.d(TAG, "handle: BB_RSP_ERR_PARAM");
                } else {
                    if (tcpConnection.isSSLEnabled) {
                        if (dxhDevice.getSsltcpSocketClient() != null) {
                            dxhDevice.getSsltcpSocketClient().destroy();
                            dxhDevice.setSsltcpSocketClient(null);
                        }
                    } else {
                        if (dxhDevice.getTcpSocketClient() != null) {
                            dxhDevice.getTcpSocketClient().close();
                        }
                    }

                    data = CloseTCPCmd.response(BB_RSP_OK.value);
                    Log.d(TAG, "handle: BB_RSP_OK");
                }
                dxhDevice.getCallback().updateInfo(dxhDevice);
            } catch (Exception e) {
                data = CloseTCPCmd.response(BB_RSP_ERR_PARAM.value);
                Log.d(TAG, "handle: BB_RSP_ERR_PARAM");
            }
        }

        if (data != null) {
            byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
            if(encryptedPacket != null) {
                dxhDevice.send(encryptedPacket);
            }
        }
    }
}
