package com.octo.octo_beat_plugin.core.device.handler;

import android.util.Log;

import org.msgpack.value.Value;

import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.model.TCPConnection;
import com.octo.octo_beat_plugin.core.utils.ByteUtils;
import com.octo.octo_beat_plugin.core.utils.MessagePackHelper;

/**
 * Created by caoxuanphong on 12/21/17.
 */

public class TransmitDataHandler {
    private static final String TAG = "TransmitDataHandler";

    public static void handle(DXHDevice dxhDevice, byte[] payloadData) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        if (!dxhDevice.getHandShaked()) {
            Log.e(TAG, "handle: device did not handshake");
            return;
        }

        try {
            Value value = MessagePackHelper.unpackRaw(payloadData);

            int connectionId = value.asArrayValue().get(1).asIntegerValue().asInt();
            byte[] bin = value.asArrayValue().get(2).asBinaryValue().asByteArray();

            if (bin != null) {
                dxhDevice.sendDataToTCPServer(dxhDevice, connectionId, bin);
            } else {
                Log.e(TAG, "handle: data is null");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static void sendDataToTCPServer(final DXHDevice dxhDevice, int connectionId, byte[] data) {
        if (!dxhDevice.isTCPSocketOpened()) {
            Log.d(TAG, "sendDataToTCPServer: tcp client is not running");
            return;
        }

        TCPConnection tcpConnection = dxhDevice.retrieveTCPConnection(connectionId);
        if (tcpConnection != null && tcpConnection.isSSLEnabled) {
            dxhDevice.getSsltcpSocketClient().send(data);
        } else {
            dxhDevice.getTcpSocketClient().send(data);
        }
    }

}
