package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import org.json.JSONArray;

import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.SetSeverCertificateCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * created by Banh Le Minh Nha
 */
public class SetSeverCertificateHandler {
    private static final String DEBUG_TAG = "SetSeverCertHandler";
    private static int pem;

    private static boolean parse(JSONArray messagePack) {
        try {
            int certificateId = messagePack.getInt(1);
            String certificate = messagePack.getString(2);

            Log.d(DEBUG_TAG, "certificate ID : " + certificateId);
            Log.d(DEBUG_TAG, "certificate : " + certificate);
            return true;
        } catch (Exception e) {
            e.printStackTrace();

            return false;
        }
    }

    public static void handle(DXHDevice dxhDevice, JSONArray messagePack) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(DEBUG_TAG, "handle: null");
            return;
        }

        byte[] data;
        if (!dxhDevice.getHandShaked()) {
            data = SetSeverCertificateCmd.response(BB_RSP_ERR_PERMISSION.value);
        } else {
            try {
                int certificateId = messagePack.getInt(1);
                String certificate = messagePack.getString(2);

                dxhDevice.getServerCA().put(certificateId, certificate);
                data = SetSeverCertificateCmd.response(BB_RSP_OK.value);
            } catch (Exception e) {
                e.printStackTrace();
                data = SetSeverCertificateCmd.response(BB_RSP_ERR_PARAM.value);
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
