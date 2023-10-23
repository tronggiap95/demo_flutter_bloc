/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;


import android.app.Service;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import android.util.Log;

import java.lang.ref.WeakReference;
import java.util.ArrayList;


/**
 * <a href="http://d.android.com/tools/testing/testing_android.html">Testing Fundamentals</a>
 */
public class TIOService extends Service {

    private static String LOG_TAG = "TioService";

    private final TioServiceCommandHandler   mHandler;
    private final Messenger                  mMessenger;
    private Messenger                        mClient;
    private ArrayList<TIOConnectionProvider> mConnectionList = new ArrayList<TIOConnectionProvider>();
    private Object                           mLock = new Object();

    public TIOService() {
        super();

        mHandler   = new TioServiceCommandHandler(this);
        mMessenger = new Messenger(mHandler);
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.v(LOG_TAG, "onBind");
        return mMessenger.getBinder();
    }

    @Override
    public void onRebind(Intent intent) {
        Log.v(LOG_TAG, "onRebind");
        super.onRebind(intent);
    }

    @Override
    public boolean onUnbind(Intent intent) {
        Log.v(LOG_TAG, "onUnbind");
        return true;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.v(LOG_TAG, "onDestroy");

        // stop all connections
    }

    TIOConnectionProvider searchConnection(int id) {
        for ( int i = 0; i < mConnectionList.size(); i++ ) {
            TIOConnectionProvider connection = mConnectionList.get(i);

            if ( connection.getId() == id ) {
                return connection;
            }
        }

        Log.e(LOG_TAG, "connection for #" + id + " not found !, in list " + mConnectionList.size());
        return null;
    }

    void addConnection(TIOConnectionProvider connection) {
        if ( connection != null) {
            synchronized (mLock) {
                mConnectionList.add( connection );

                Log.d(LOG_TAG,"Connection #" + connection.getId() + " added, now in list "+mConnectionList.size());
            }
        }
    }

    void removeConnection(int id) {
        TIOConnectionProvider connection = searchConnection(id);
        if ( connection != null) {
            synchronized (mLock) {
                mConnectionList.remove( connection );
                Log.d(LOG_TAG, "Connection #" + connection.getId() + " removed, now in list " + mConnectionList.size());
            }
        }
    }


     void onConnectRequest(Message msg) {

         TIOServiceRequest request = (TIOServiceRequest) msg.obj;
         String     address = request.getAddress();

         mClient = msg.replyTo;
         BluetoothManager bluetoothManager = (BluetoothManager) getApplicationContext().getSystemService(Context.BLUETOOTH_SERVICE);
         BluetoothAdapter  adapter = bluetoothManager.getAdapter();
         BluetoothDevice  device = adapter.getRemoteDevice( address );

         Log.d(LOG_TAG, "onConnectRequest #"+ request.getId() + " to " + address);

         addConnection( new TIOConnectionProvider(this,device,getApplicationContext(),request.getId()) );
    }

    void onDisconnectRequest(Message msg) {

        TIOServiceRequest request = (TIOServiceRequest) msg.obj;

        Log.d(LOG_TAG, "onDisconnectRequest #"+request.getId());

        TIOConnectionProvider connection = searchConnection( request.getId() );

        if ( connection  != null ) {
            try {
                connection.disconnect();
            }
            catch (Exception ex) {

            }
        }
    }

    void onCancelRequest(Message msg) {

        TIOServiceRequest request = (TIOServiceRequest) msg.obj;

        Log.d(LOG_TAG, "onCancelRequest #"+request.getId());

        TIOConnectionProvider connection = searchConnection( request.getId() );

        if ( connection  != null ) {
            try {
                connection.cancel();
            }
            catch (Exception ex) {

            }
        }
    }

    void onTransmitRequest(Message msg) {

        TIOServiceRequest request = (TIOServiceRequest) msg.obj;
        byte [] data = request.getData();
        int status   = 0;

        Log.d(LOG_TAG, "onTransmitRequest #"+request.getId()+" ,length " + data.length);

        TIOConnectionProvider connection = searchConnection( request.getId() );

        if ( connection  != null ) {
            try {
                connection.transmit(data);
            }
            catch ( Exception ex) {
                status = 1;
            }
        } else {
            status = 1;
        }

        if ( status != 0) {
            sendDataConfirmation(request.getId(),1,0);
        }
    }

    void onRssiRequest(Message msg) {

        TIOServiceRequest request = (TIOServiceRequest) msg.obj;
        int        delay   = request.getValue();

        Log.d(LOG_TAG, "onRssiRequest #"+request.getId()+ " delay "+delay);

        TIOConnectionProvider connection = searchConnection( request.getId() );

        if ( connection  != null ) {
            try {
                connection.readRemoteRssi(delay);
            } catch (Exception ex) {

            }
        }
    }


    private boolean sendMessage(Message msg) {
        try {
            mClient.send(msg);
        } catch (RemoteException ex) {
            return false;
        }

        return true;
    }

    /**
     * Signal event for established connection service client instance.
     * @return true if successfully
     */
    boolean sendConnectionIndication(int id) {

        Log.d(LOG_TAG,"sendConnectionIndication >> #"+id);

        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_CONNECT_IND);

        if (msg == null) {
            return false;
        }

        msg.obj = new TIOServiceRequest(id);
        return sendMessage(msg);
    }

    /**
     * Signal event for failed call service client instance.
     * @param message error message string.
     * @return true if successfully
     */
    boolean sendCallFailed(int id,String message) {

        Log.d(LOG_TAG,"sendCallFailed >> #" +id + " "+message);

        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_CONNECT_FAILED_IND);

        if (msg == null) {
            return false;
        }

        removeConnection(id);

        msg.obj     = new TIOServiceRequest(id,message);
        return sendMessage(msg);
    }

    /**
     * Send event for disconnected connection service client instance.
     * @param message error message string.
     * @return true if successfully
     */
    boolean sendDisconnectIndication(int id,String message) {

        Log.d(LOG_TAG,"sendDisconnectIndication >> #"+id+" "+message);

        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_DISCONNECT_IND);

        if (msg == null) {
            return false;
        }

        removeConnection(id);

        msg.obj     = new TIOServiceRequest(id,message);
        return sendMessage(msg);
    }

    /**
     * Send DATA confirmation to service client instance.
     * @param status  Status of DATA_REQ command
     * @param bytesWritten Number of bytes written when status equal 0
     * @return true if successfully
     */
    boolean sendDataConfirmation(int id,int status, int bytesWritten) {
        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_DATA_CONF);

        if (msg == null) {
            return false;
        }

        msg.obj     = new TIOServiceRequest(id,status,bytesWritten);
        return sendMessage(msg);
    }


    /**
     * Send DATA indication to service client instance
     * @param data   Container for received data
     * @return true if successfully
     */
    boolean sendDataIndication(int id,byte [] data) {
        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_DATA_IND);

        if (msg == null) {
            return false;
        }

        msg.obj     = new TIOServiceRequest(id,data);
        return sendMessage(msg);
    }

    /**
     * Send RSSI indication to service client instance
     * @param status of RSSI request operation.
     * @param rssi RSSI value when status is 0.
     * @return true if successfully
     */
    boolean sendRssiIndication(int id,int status, int rssi) {
        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_RSSI_IND);

        if (msg == null) {
            return false;
        }

        msg.obj     = new TIOServiceRequest(id,status,rssi);
        return sendMessage(msg);
    }

    /**
     * Send Local MTU size indication to service client instance
     * @param status Operation status.
     * @param mtuSize UART MTU size.
     * @return true if successfully
     */
    boolean sendLocalMtuIndication(int id,int status, int mtuSize)  {
        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_RX_MTU_IND);

        if (msg == null) {
            return false;
        }

        msg.obj     = new TIOServiceRequest(id,status,mtuSize);
        return sendMessage(msg);
    }

    /**
     * Send Remote MTU size indication to service client instance
     * @param status Operation status.
     * @param mtuSize UART MTU size.
     * @return true if successfully
     */
    boolean sendRemoteMtuIndication(int id,int status, int mtuSize) {
        Message msg = Message.obtain(null, TIOServiceConnection.MSG_TIO_TX_MTU_IND);

        if (msg == null) {
            return false;
        }

        msg.obj     = new TIOServiceRequest(id,status,mtuSize);
        return sendMessage(msg);
    }

    /**
     * Service command handler, handle messages from TIO interface API
     */
    private static class TioServiceCommandHandler extends Handler {
        private final WeakReference<TIOService> mService;

        public TioServiceCommandHandler(TIOService service) {
            mService = new WeakReference<TIOService>(service);
        }

        @Override
        public void handleMessage(Message msg) {
            TIOService service = mService.get();
            if (service != null) {
                switch (msg.what) {
                    case TIOServiceConnection.MSG_TIO_DATA_REQ:
                        service.onTransmitRequest(msg);
                        break;

                    case TIOServiceConnection.MSG_TIO_CONNECT_REQ:
                        service.onConnectRequest(msg);
                        break;

                    case TIOServiceConnection.MSG_TIO_DISCONNECT_REQ:
                        service.onDisconnectRequest(msg);
                        break;

                    case TIOServiceConnection.MSG_TIO_CANCEL_REQ:
                        service.onCancelRequest(msg);
                        break;

                    case TIOServiceConnection.MSG_TIO_RSSI_REQ:
                        service.onRssiRequest(msg);
                        break;

                    default:
                        super.handleMessage(msg);
                        break;
                }
            }
        }
    }
}