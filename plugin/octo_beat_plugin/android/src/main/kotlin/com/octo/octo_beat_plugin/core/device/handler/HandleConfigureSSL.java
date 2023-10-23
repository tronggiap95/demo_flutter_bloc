package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;

import com.octo.octo_beat_plugin.core.device._enum.SSLAuthMode;
import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.ConfigureSSLCommand;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.model.TCPConnection;

import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class HandleConfigureSSL {
    private static final String TAG = "HandleConfigureSSL";

    private static boolean parse(JSONArray messagePack) {
        try {
            int connectionId = messagePack.getInt(0);
            Log.d(TAG, "connection id: " + connectionId);

            return true;
        } catch (Exception e) {
            e.printStackTrace();

            return false;
        }
    }

    public static void handle(DXHDevice dxhDevice, JSONArray messagePack) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        byte[] data;
        if (!dxhDevice.getHandShaked()) {
            data = ConfigureSSLCommand.response(BB_RSP_ERR_PERMISSION.value);
        } else {
            try {
                int connectionId = messagePack.getInt(1);
                int authMode = messagePack.getInt(2);
                int serverCaId = messagePack.getInt(3);
                int clientCaId = messagePack.getInt(4);
                int clientPrivateKeyId = messagePack.getInt(5);

                dxhDevice.addNewTCPConnection(new TCPConnection(
                        connectionId,
                        authMode == 0 ? SSLAuthMode.ONE_WAY_AUTH : SSLAuthMode.TWO_WAY_AUTH,
                        serverCaId,
                        clientCaId,
                        clientPrivateKeyId
                ));

                data = ConfigureSSLCommand.response(BB_RSP_OK.value);
            } catch (JSONException e) {
                e.printStackTrace();

                data = ConfigureSSLCommand.response(BB_RSP_ERR_PARAM.value);
            }
        }

        if (data != null) {
            byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
            if (encryptedPacket != null) {
                dxhDevice.send(encryptedPacket);
            }
        }

    }
}
