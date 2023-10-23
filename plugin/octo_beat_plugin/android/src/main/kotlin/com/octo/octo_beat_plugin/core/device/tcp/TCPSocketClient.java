package com.octo.octo_beat_plugin.core.device.tcp;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketTimeoutException;

import android.annotation.SuppressLint;
import android.util.Log;

import com.octo.octo_beat_plugin.core.utils.ByteUtils;

/**
 * Socket manager: connect, disconnect, send, receive
 *
 * @author cxphong
 */
public class TCPSocketClient {
    private static final String TAG = "TCPSocketClient";
    private Socket mSocket;
    private OutputStream senderStream;
    private InputStream readerStream;
    private byte[] mReceiveBuffer = new byte[2048];
    private TCPClientCallback callback;
    private boolean isOpened;

    public boolean isOpened() {
        return isOpened;
    }

    // Connect
    public synchronized void connectToServer(final String address,
                                             final int port,
                                             final int timeout,
                                             final TCPClientCallback callback) {
        this.callback = callback;

        new Thread(new Runnable() {

            @Override
            public void run() {
                try {
                    mSocket = new Socket();
                    mSocket.connect(new InetSocketAddress(address, port), timeout*1000);
                } catch (SocketTimeoutException e) {
                    e.printStackTrace();

                    if (callback != null) {
                        callback.timeout();
                    }

                    return;
                } catch (IOException e) {
                    e.printStackTrace();

                    if (callback != null) {
                        callback.connectFailed();
                    }

                    return;
                }

                if (mSocket != null) {
                    Log.v(TAG, "Connect server success");
                    try {
                        isOpened = true;
                        senderStream = mSocket.getOutputStream();
                        readerStream = mSocket.getInputStream();

                        receive();

                        if (callback != null) {
                            callback.didConnected();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();

                        if (callback != null) {
                            callback.connectFailed();
                        }
                    }
                }
            }
        }).start();
    }

    // disconnect
    public synchronized void close() {
        try {
            isOpened = false;
            callback = null;

            if (mSocket != null) {
                mSocket.shutdownInput();
                mSocket.shutdownOutput();
                mSocket.close();
            }

            if (readerStream != null) {
                readerStream.close();
            }

            if (senderStream != null) {
                senderStream.close();
                senderStream.flush();
            }

            Log.v(TAG, "Closed socket");
        } catch (IOException e) {
            e.printStackTrace();
        }

        mSocket = null;
    }

    // send
    public synchronized boolean send(byte[] data) {
        if (mSocket == null) {
            Log.v(TAG, "Socket is not connecting. Connect again");
            return false;
        }

        try {
            senderStream.write(data);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }

        Log.v(TAG, "send = " + ByteUtils.toHexString(data));
        return true;
    }

    // receive
    public synchronized void receive() {
        new Thread(new Runnable() {

            @SuppressLint("NewApi")
            @Override
            public void run() {
                int readNum = 0;

                while (true) {
                    try {
                        Log.d(TAG, "reading ...");
                        readNum = readerStream.read(mReceiveBuffer);
                    } catch (IOException e) {
                        e.printStackTrace();

                        if (callback != null) {
                            callback.didLostConnection();
                        }

                        isOpened = false;
                        break;
                    }

                    if (readNum < 0) {
                        if (callback != null) {
                            callback.didLostConnection();
                        }

                        break;
                    }

                    if (readNum > 0) {
                        byte[] data = ByteUtils.subByteArray(mReceiveBuffer, 0, readNum);

                        if (callback != null) {
                            callback.didReceiveData(data);
                        }
                    }
                }

                Log.d(TAG, "run: Stop receive");
            }
        }).start();

    }
}
