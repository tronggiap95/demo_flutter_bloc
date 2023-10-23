package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import org.json.JSONArray;
import org.json.JSONException;

import java.nio.ByteBuffer;

import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.HandShakeCmd;
import com.octo.octo_beat_plugin.core.device.command.ReadReceiveDataCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;

import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_CONN_CLOSED;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class ReadTcpDataHandler {
    private static final String TAG = "ReadTcpDataHandler";

    private static boolean parse(JSONArray messagePack) {
        try {
            int connectionId = messagePack.getInt(1);
            int length = messagePack.getInt(2);
            Log.d(TAG, "connection id: " + connectionId);
            Log.d(TAG, "length: " + length);

            return true;
        } catch (Exception e) {
            e.printStackTrace();

            return false;
        }
    }

    private static byte[] readTcpBuffer(DXHDevice dxhDevice, int length) {
        ByteBuffer buffer = dxhDevice.getTcpBuffer();
        int mLength  = 0;

        if (length > buffer.position()) {
            mLength = buffer.position();
        } else {
            mLength = length;
        }

        byte[] resultData = new byte[mLength];

        buffer.flip();
        buffer.get(resultData, 0, mLength);
        buffer.compact();

        return resultData;
    }

    public static void handle(DXHDevice dxhDevice, JSONArray messagePack) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        byte[] data = null;

        if (!dxhDevice.getHandShaked()) {
            data = ReadReceiveDataCmd.response(BB_RSP_ERR_PERMISSION.value, null);
            Log.d(TAG, "handle: BB_RSP_ERR_PERMISSION");
        } else if (!dxhDevice.isTCPSocketOpened()) {
            data = ReadReceiveDataCmd.response(BB_RSP_ERR_CONN_CLOSED.value, null);
            Log.e(TAG, "handle: BB_RSP_ERR_CONN_CLOSED");
        } else {
            if (parse(messagePack)) {
                try {
                    byte[] tcpData = readTcpBuffer(dxhDevice, messagePack.getInt(2));
                    data = ReadReceiveDataCmd.response(BB_RSP_OK.value, tcpData);
                    Log.d(TAG, "handle: BB_RSP_OK");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                data = ReadReceiveDataCmd.response(BB_RSP_ERR_PARAM.value, null);
                Log.d(TAG, "handle: BB_RSP_ERR_PARAM");
            }
        }

        if (data != null) {
            byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
            if(encryptedPacket != null) {
                dxhDevice.send(encryptedPacket);
            }
        } else {
            Log.e(TAG, "handle: data is null");
        }

    }
}
