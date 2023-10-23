package com.octo.octo_beat_plugin.core.device.handler;

import android.content.Context;
import android.util.Log;

import org.json.JSONArray;

import com.octo.octo_beat_plugin.core.device.command.CommandUtils;
import com.octo.octo_beat_plugin.core.device.command.NotifyOpenTcpCmd;
import com.octo.octo_beat_plugin.core.device.command.OpenTCPCmd;
import com.octo.octo_beat_plugin.core.device.model.DXHDevice;
import com.octo.octo_beat_plugin.core.device.model.TCPConnection;
import com.octo.octo_beat_plugin.core.device.tcp.TCPClientCallback;
import com.octo.octo_beat_plugin.core.device.tcp.TCPClientSupportSSL.SSLTCPSocketClient;
import com.octo.octo_beat_plugin.core.device.tcp.TCPSocketClient;
import com.octo.octo_beat_plugin.core.utils.ConnectivityUtils;
import com.octo.octo_beat_plugin.core.utils.MyLog;

import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_CONN_OPENED;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_CONN_TIMEOUT;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_NO_NETWORK;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PARAM;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_ERR_PERMISSION;
import static com.octo.octo_beat_plugin.core.device._enum.ResponseCode.BB_RSP_OK;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class HandleOpenTcp {
    private static final String TAG = "HandleOpenTcp";

    private static boolean parse(JSONArray messagePack) {
        try {
            int connectionId = messagePack.getInt(1);
            String address = messagePack.getString(2);
            int port = messagePack.getInt(3);
            int connectionTimeout = messagePack.getInt(4);

            MyLog.log(TAG, "connectionId: " + connectionId);
            MyLog.log(TAG, "address: " + address);
            MyLog.log(TAG, "port: " + port);
            MyLog.log(TAG, "connectionTimeout: " + connectionTimeout);
            return true;
        } catch (Exception e) {
            e.printStackTrace();

            return false;
        }
    }

    private static void connectToServer(Context context, DXHDevice dxhDevice, JSONArray messagePack,
                                        TCPClientCallback tcpClientCallback) {
        try {
            int connectionId = messagePack.getInt(1);
            String address = messagePack.getString(2);
            int port = messagePack.getInt(3);
            int connectionTimeout = messagePack.getInt(4);
            boolean isSSLEnabled = messagePack.getBoolean(5);

            TCPConnection tcpConnection = dxhDevice.retrieveTCPConnection(connectionId);
            String serverCA = dxhDevice.retrieveServerCa(connectionId);

            MyLog.log(TAG, ": serverCA: " + serverCA);
            if (tcpConnection != null && isSSLEnabled && serverCA != null) {
                tcpConnection.isSSLEnabled = true;
                switch (tcpConnection.authMode) {
                    case ONE_WAY_AUTH:
                        if (dxhDevice.getSsltcpSocketClient() != null) {
                            dxhDevice.getSsltcpSocketClient().destroy();
                        }
                        dxhDevice.setSsltcpSocketClient(new SSLTCPSocketClient());
                        dxhDevice.getSsltcpSocketClient().setupConnection(context,
                                serverCA,
                                address,
                                port,
                                connectionTimeout,
                                tcpClientCallback);
                        break;

                    case TWO_WAY_AUTH: // Not implemented
                        break;
                }
            } else {
                dxhDevice.setTcpSocketClient(new TCPSocketClient());
                dxhDevice.getTcpSocketClient().connectToServer(address, port, connectionTimeout, tcpClientCallback);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void handle(DXHDevice dxhDevice, JSONArray messagePack,
                              Context context,
                              TCPClientCallback tcpClientCallback) {
        if (dxhDevice == null || !dxhDevice.isBluetoothConnected()) {
            Log.e(TAG, "handle: null");
            return;
        }

        byte[] data = checkException(dxhDevice, messagePack, context);

        if (data != null) {
            byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
            if (encryptedPacket != null) {
                dxhDevice.send(encryptedPacket);
            }
        } else {
            if (dxhDevice.getApiVersion() > 4) {
                data = OpenTCPCmd.response(BB_RSP_OK.value);
                byte[] encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
                if (encryptedPacket != null) {
                    dxhDevice.send(encryptedPacket);
                }
            }
            connectToServer(context, dxhDevice, messagePack, tcpClientCallback);
        }
    }

    public static void handleConnected(final DXHDevice dxhDevice) {
        if (dxhDevice == null || dxhDevice.getTcpConnections().size() < 1) {
            Log.e(TAG, "handleConnected: dxhDevice is null");
            return;
        }
        byte[] data;
        byte[] encryptedPacket;
        if (dxhDevice.getApiVersion() > 4) {
            data = NotifyOpenTcpCmd.INSTANCE.notify(dxhDevice.getTcpConnections().get(0).id, true);
            encryptedPacket = CommandUtils.packPacketNotify(data, dxhDevice);
        } else {
            data = OpenTCPCmd.response(BB_RSP_OK.value);
            encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
        }
        if (encryptedPacket != null) {
            dxhDevice.send(encryptedPacket);
        }
        dxhDevice.getCallback().updateInfo(dxhDevice);
    }

    public static void handleTimeout(DXHDevice dxhDevice) {
        if (dxhDevice == null || dxhDevice.getTcpConnections().size() < 1) {
            Log.e(TAG, "handleConnected: dxhDevice is null");
            return;
        }
        byte[] data;
        byte[] encryptedPacket;
        if (dxhDevice.getApiVersion() > 4) {
            data = NotifyOpenTcpCmd.INSTANCE.notify(dxhDevice.getTcpConnections().get(0).id, false);
            encryptedPacket = CommandUtils.packPacketNotify(data, dxhDevice);
        } else {
            data = OpenTCPCmd.response(BB_RSP_ERR_CONN_TIMEOUT.value);
            encryptedPacket = CommandUtils.packPacketResponse(data, dxhDevice);
        }
        if (encryptedPacket != null) {
            dxhDevice.send(encryptedPacket);
        }
    }

    public static byte[] checkException(DXHDevice dxhDevice,
                                        JSONArray messagePack, Context context) {
        byte[] data = null;

        if (!parse(messagePack)) {
            data = OpenTCPCmd.response(BB_RSP_ERR_PARAM.value);
            Log.w(TAG, "checkException: BB_RSP_ERR_PARAM");
        } else if (!dxhDevice.getHandShaked()) {
            data = OpenTCPCmd.response(BB_RSP_ERR_PERMISSION.value);
            Log.w(TAG, "checkException: BB_RSP_ERR_PERMISSION");
        } else if (!ConnectivityUtils.isConnected(context)) {
            data = OpenTCPCmd.response(BB_RSP_ERR_NO_NETWORK.value);
            Log.w(TAG, "checkException: BB_RSP_ERR_NO_NETWORK");
        } else if (dxhDevice.getSsltcpSocketClient() != null && dxhDevice.getSsltcpSocketClient().isOpened()) {
            data = OpenTCPCmd.response(BB_RSP_ERR_CONN_OPENED.value);
            Log.w(TAG, "checkException: BB_RSP_ERR_CONN_OPENED");
        }

        if (data != null) {
            return data;
        } else {
            return null;
        }
    }

}
