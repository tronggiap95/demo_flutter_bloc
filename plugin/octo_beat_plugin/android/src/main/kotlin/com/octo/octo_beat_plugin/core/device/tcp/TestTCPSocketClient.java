package com.octo.octo_beat_plugin.core.device.tcp;

import android.util.Log;

import com.octo.octo_beat_plugin.core.utils.ByteUtils;

/**
 * Created by caoxuanphong on 12/20/17.
 */

public class TestTCPSocketClient {
    private static final String TAG = "TestTCPSocketClient";

    public static void start() {
        test_01();
    }

    public static void test_01() {
        final TCPSocketClient tcpSocketClient = new TCPSocketClient();
        tcpSocketClient.connectToServer("192.168.11.36", 5000, 30000, new TCPClientCallback() {
            @Override
            public void didConnected() {
                Log.d(TAG, "didConnected: ");

                tcpSocketClient.send("Hello world!".getBytes());
            }

            @Override
            public void didLostConnection() {
                Log.d(TAG, "didLostConnection: ");
            }

            @Override
            public void didReceiveData(byte[] data) {
                Log.d(TAG, "didReceiveData: " + ByteUtils.toHexString(data));
            }

            @Override
            public void connectFailed() {
                Log.d(TAG, "connectFailed: ");
            }

            @Override
            public void timeout() {
                Log.d(TAG, "timeout: ");
            }
        });
    }
}
