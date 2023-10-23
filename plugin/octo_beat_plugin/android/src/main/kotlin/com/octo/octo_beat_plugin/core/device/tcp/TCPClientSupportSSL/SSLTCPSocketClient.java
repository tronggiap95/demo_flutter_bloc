package com.octo.octo_beat_plugin.core.device.tcp.TCPClientSupportSSL;


import android.content.Context;
import android.util.Log;

import androidx.core.util.TimeUtils;

import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.UnknownHostException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.concurrent.TimeUnit;

import javax.net.SocketFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.TrustManagerFactory;

import com.octo.octo_beat_plugin.core.device.tcp.TCPClientCallback;
import com.octo.octo_beat_plugin.core.utils.ByteUtils;
import com.octo.octo_beat_plugin.core.utils.DateTimeUtils;
import io.reactivex.Observable;
import io.reactivex.disposables.Disposable;

public class SSLTCPSocketClient {
    private static final String TAG = "SSLTCPSocketClient";
    private final String DEBUG_TAG = "TCPSocketSSLManager";
    private SSLSocket mSocket;
    private OutputStream mDataOutputStream = null;
    private InputStream mDataInputStream = null;
    private byte[] mReceiveBuffer = new byte[2048];
    private TCPClientCallback mListener;
    private boolean isOpened;
    private Disposable sslTimerDisposable;
    private Thread setupConnectionThread;
    private Thread receivingThread;

    //FOR CALCULATE TX SPEED
    private Long tx = 0L;
    private Long initTimeSpeed = 0L;

    public synchronized void setupConnection(final Context context,
                                             final String serverCa,
                                             final String ip,
                                             final int port,
                                             final int connectionTimeout,
                                             TCPClientCallback listener) {
        mListener = listener;
        setupConnectionThread = new Thread(() -> {
            try {
                if (!Utils.hasInternetConnection(context)) {
                    mListener.connectFailed();
                    return;
                }

                SSLContext sslContext = initSSLContext(serverCa);
                connectToSever(sslContext, ip, port, connectionTimeout, listener);
                if (mSocket != null && mSocket.isClosed()) {
                   // close();
                    return;
                }

                if (mSocket == null) {
                    //Don't handle socket connection failed
                   // mListener.connectFailed();
                    return;
                }

                mDataInputStream = getInputStream(mSocket);
                mDataOutputStream = getOutputStream(mSocket);

                if (mDataInputStream == null || mDataOutputStream == null) {
                    if (mListener != null) {
                        mListener.connectFailed();
                    }
                } else {
                    isOpened = true;
                    if (mListener != null) {
                        mListener.didConnected();
                    }
                    startReceive();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
        setupConnectionThread.start();
    }

    private void connectToSever(SSLContext context, String ip, int port, int connectionTimeout, TCPClientCallback listener) {
        Log.d(TAG, "connectToSever " + connectionTimeout);
        try {
            sslTimerDisposable = Observable.interval(connectionTimeout, TimeUnit.SECONDS).map(i -> {
                Log.d(TAG, "connectToSever: timeout: " + i);
                listener.timeout();
                if (sslTimerDisposable != null) {
                    sslTimerDisposable.dispose();
                }

                if (mSocket != null) {
                    mSocket.close();
                }
                return i;
            }).subscribe();

            SocketFactory sf = context.getSocketFactory();
            mSocket = (SSLSocket) sf.createSocket(ip, port);
            mSocket.startHandshake();
            if (sslTimerDisposable != null) {
                sslTimerDisposable.dispose();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private SSLContext initSSLContext(String serverCa) {
        SSLContext sslContext;

        try {
            sslContext = SSLContext.getInstance("TLSv1.2");
            TrustManagerFactory trustManagerFactory = generateTrustManager(serverCa);

            if (trustManagerFactory != null) {
                sslContext.init(null, trustManagerFactory.getTrustManagers(), null);
            } else {
                return null;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }

        return sslContext;
    }

    private InputStream getInputStream(SSLSocket socket) {
        InputStream input = null;

        try {
            input = socket.getInputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return input;
    }

    private OutputStream getOutputStream(SSLSocket socket) {
        OutputStream output = null;

        try {
            output = socket.getOutputStream();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return output;
    }

    private synchronized void startReceive() {
      receivingThread =  new Thread(() -> {
            int readNum;

            while (mSocket != null) {
                try {
                    readNum = mDataInputStream.read(mReceiveBuffer);
                } catch (IOException e) {
                    e.printStackTrace();

                    if (mListener != null) {
                        mListener.didLostConnection();
                    }

                    isOpened = false;
                    break;
                }

                if (readNum < 0) {
                    if (mListener != null) {
                        mListener.didLostConnection();
                    }

                    isOpened = false;
                    break;
                }

                byte[] data = ByteUtils.subByteArray(mReceiveBuffer, 0, readNum);
                if (mListener != null) {
                    mListener.didReceiveData(data);
                }
            }
        }, "Socket receive");
      receivingThread.start();

    }

    public synchronized void close() {
        try {
            if (mSocket != null) {
                mSocket.close();
                isOpened = false;
                mSocket = null;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {
            if (mDataInputStream != null) {
                mDataInputStream.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        try {
            if (mDataOutputStream != null) {
                mDataOutputStream.close();
                mDataOutputStream.flush();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        if (sslTimerDisposable != null) {
            sslTimerDisposable.dispose();
        }

        Log.v(DEBUG_TAG, "closedSocket() : Close Socket");
    }

    public void destroy() {
        try {
            mListener = null;
            close();
            if(receivingThread != null) {
                receivingThread.interrupt();
                receivingThread = null;
            }

            if(setupConnectionThread != null) {
                setupConnectionThread.interrupt();
                setupConnectionThread = null;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean send(String data) {
        try {
            mDataOutputStream.write(data.getBytes());
            mDataOutputStream.flush();
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    public synchronized boolean send(byte[] data) {
        try {
//            caculateSpeed(data.length);
            mDataOutputStream.write(data);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }

        return true;
    }

    private void caculateSpeed(int size) {
        if(initTimeSpeed == 0) {
            initTimeSpeed = DateTimeUtils.currentTimeToEpoch();
        }
        if(DateTimeUtils.currentTimeToEpoch() - initTimeSpeed > 0) {
            tx += size;
            Log.d(TAG, "SPEED-TX " + tx/(DateTimeUtils.currentTimeToEpoch() - initTimeSpeed));
        }
    }

    private TrustManagerFactory generateTrustManager(String serverCa) {
        try {
            TrustManagerFactory trustManagerFactory;
            CertificateFactory cf = CertificateFactory.getInstance("X.509");
            InputStream caInput = new ByteArrayInputStream(serverCa.getBytes());
            Certificate CA = cf.generateCertificate(caInput);
            caInput.close();

            // CA to keystore
            String keyStoreType = KeyStore.getDefaultType();
            KeyStore keyStore = KeyStore.getInstance(keyStoreType);
            keyStore.load(null, null);
            keyStore.setCertificateEntry("ca", CA);
            Log.d(DEBUG_TAG, "generateTrustManager() ca= " + ((X509Certificate) CA).getSubjectDN());

            // init keystore to TrustManagerFactory
            String tmfAlgorithm = TrustManagerFactory.getDefaultAlgorithm();
            trustManagerFactory = TrustManagerFactory.getInstance(tmfAlgorithm);
            trustManagerFactory.init(keyStore);

            return trustManagerFactory;
        } catch (CertificateException e) {
            e.printStackTrace();
        } catch (FileNotFoundException e1) {
            e1.printStackTrace();
        } catch (IOException e2) {
            e2.printStackTrace();
        } catch (NoSuchAlgorithmException e3) {
            e3.printStackTrace();
        } catch (KeyStoreException e4) {
            e4.printStackTrace();
        } catch (Exception exception) {
            exception.printStackTrace();
        }

        return null;
    }

    public boolean isOpened() {
        return isOpened;
    }

}
