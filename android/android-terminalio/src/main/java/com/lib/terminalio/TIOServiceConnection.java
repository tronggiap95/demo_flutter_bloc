/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.Messenger;
import android.os.RemoteException;
import android.util.Log;

import java.lang.ref.WeakReference;
import java.util.ArrayList;


/**
 * Implements to service connection channel to TIO service implementation. Send request messages
 * to server and receive some messages from server.
 */
class TIOServiceConnection implements ServiceConnection {

    private static String TAG = "TIOServiceConnection";

    public static final int MSG_TIO_BIND                = 9;
    public static final int MSG_TIO_CONNECT_REQ         = 10;
    public static final int MSG_TIO_DISCONNECT_REQ      = 11;
    public static final int MSG_TIO_DATA_REQ            = 12;
    public static final int MSG_TIO_DATA_IND            = 13;
    public static final int MSG_TIO_DATA_CONF           = 14;
    public static final int MSG_TIO_DISCONNECT_IND      = 15;
    public static final int MSG_TIO_CONNECT_IND         = 16;
    public static final int MSG_TIO_RSSI_REQ            = 17;
    public static final int MSG_TIO_RSSI_IND            = 18;
    public static final int MSG_TIO_CONNECT_FAILED_IND  = 19;
    public static final int MSG_TIO_CANCEL_REQ          = 20;
    public static final int MSG_TIO_RX_MTU_IND          = 21;
    public static final int MSG_TIO_TX_MTU_IND          = 22;

    private Context                       mContext;
    private boolean                       mIsBound;
    private Messenger                     mServiceRequest = null;
    private final Messenger               mServiceResponse;
    private Object                        mLock = new Object();
    private ArrayList<TIOConnectionProxy> mConnectionList = new ArrayList<TIOConnectionProxy>();

    public TIOServiceConnection(Context context) {
        mIsBound = false;
        mContext = context;

        mServiceResponse = new Messenger(new IncomingHandler(this));
    }

    public boolean start() {
        Intent intent = new Intent(mContext, TIOService.class);
        return mContext.bindService(intent, this , Context.BIND_AUTO_CREATE);
    }

    void stop() {
        // unbind from service required
        if (mIsBound) {
            mIsBound = false;
            mContext.unbindService(this);
        }
    }

    void destroy() {
        Intent intent = new Intent(mContext, TIOService.class);
        mContext.stopService(intent);
    }



    private  class IncomingHandler extends Handler {
        private final WeakReference<TIOServiceConnection> mActivity;

        public IncomingHandler(TIOServiceConnection activity) {

            mActivity = new WeakReference<TIOServiceConnection>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            //Log.d(TAG, "handleMessage "+msg.what);

            TIOServiceRequest request     = (TIOServiceRequest) msg.obj;
            TIOConnectionProxy connection  = searchConnection( request.getId() );

            if ( connection == null ) {
                Log.e(TAG,"! cannot handle message "+ msg.what+ " for connection #"+request.getId() );
                return;
            }

            switch (msg.what) {
                case MSG_TIO_DATA_IND:
                    connection.signalData(request.getData()) ;
                    break;

                case MSG_TIO_DATA_CONF:
                    connection.signalDataTransmitted(request.getStatus(), request.getValue());
                    break;

                case MSG_TIO_RSSI_IND:
                    connection.signalRssi(request.getStatus(), request.getValue()); ;
                    break;

                case MSG_TIO_DISCONNECT_IND:
                    connection.signalDisconnected(request.getMessage());
                    break;

                case MSG_TIO_CONNECT_IND:
                    connection.signalConnected();
                    break;

                case MSG_TIO_CONNECT_FAILED_IND:
                    connection.signalConnectFailed(request.getMessage());
                    break;

                case MSG_TIO_TX_MTU_IND:
                    connection.signalRemoteMtuIndication(request.getValue());
                    break;

                case MSG_TIO_RX_MTU_IND:
                    connection.signalLocalMtuIndication(request.getValue());
                    break;

                default:
                    super.handleMessage(msg);
                    break;
            }
        }
    }


    /**
     * Setup a new TIOServiceRequest message and send to service implementation
     * @param connection
     * @param address
     * @return
     */
    boolean connectRequest(TIOConnectionProxy connection,String address) {

        Message msg = Message.obtain(null, MSG_TIO_CONNECT_REQ);

        if (msg == null) {
            return false;
        }

        addConnection( connection );
        if ( sendMessage( msg,new TIOServiceRequest(connection.getId(),address) ) ) {
            return true;
        }

        removeConnection(connection);
        return false;
    }

    boolean disconnectRequest(TIOConnectionProxy connection) {
        Message msg = Message.obtain(null, MSG_TIO_DISCONNECT_REQ);

        if (msg == null) {
            return false;
        }

        return sendMessage(msg, new TIOServiceRequest(connection.getId()) );
    }

    boolean cancelRequest(TIOConnectionProxy connection) {
        Message msg = Message.obtain(null, MSG_TIO_CANCEL_REQ);

        if (msg == null) {
            return false;
        }

        return sendMessage(msg, new TIOServiceRequest(connection.getId()) );
    }

    boolean dataRequest(TIOConnectionProxy connection, byte [] data) {
        Message msg = Message.obtain(null, MSG_TIO_DATA_REQ);

        if (msg == null) {
            return false;
        }

        return sendMessage(msg, new TIOServiceRequest(connection.getId(),data));
    }

    boolean rssiRequest(TIOConnectionProxy connection,int delay) {
        Message msg = Message.obtain(null, MSG_TIO_RSSI_REQ);

        if (msg == null) {
            return false;
        }

        return sendMessage(msg, new TIOServiceRequest(connection.getId(),0,delay));
    }

    private boolean sendMessage(Message msg, Object o) {
        msg.replyTo = mServiceResponse;
        msg.obj     = o;
        try {
            mServiceRequest.send(msg);
        } catch (RemoteException ex) {
            if ( TIOManager.getInstance().isTraceEnabled() ) {
                Log.e(TAG,"! sendMessage(), remote exception");
            }
            return false;
        }

        return true;
    }


    /**
     * Later we can here support more connections when needed
     * @param connection
     */
     private void addConnection(TIOConnectionProxy connection) {
         if ( TIOManager.getInstance().isTraceEnabled() ) {
             Log.d(TAG,"Add TIO connection instance #" + connection.getId() );
         }
         mConnectionList.add(connection);
     }

    /**
     * Later we can here support more connections when needed
     * @param connection
     */
     private void removeConnection(TIOConnectionProxy connection) {
         if (TIOManager.getInstance().isTraceEnabled()) {
             Log.d(TAG, "Remove TIO connection instance #" + connection.getId());
         }
         mConnectionList.remove(connection);
     }

    private TIOConnectionProxy searchConnection(int id) {

        for (int i = 0; i < mConnectionList.size(); i++ ) {
            TIOConnectionProxy connection =  mConnectionList.get(i);
            if ( connection.getId() == id) {
                return connection;
            }
        }

        if ( TIOManager.getInstance().isTraceEnabled() ) {
            Log.e(TAG,"TIO connection instance #"+id + " not found !");
        }

        return null;
    }



    /**
     * Called when a connection to the Service has been established, with
     * the {@link android.os.IBinder} of the communication channel to the
     * Service.
     *
     * @param name The concrete component name of the service that has
     * been connected.
     *
     * @param service The IBinder of the Service's communication channel,
     * which you can now make calls on.
     */
    @Override
    public void onServiceConnected(ComponentName name, IBinder service) {
      if ( TIOManager.getInstance().isTraceEnabled() ) {
          Log.d(TAG,"onServiceConnected");
      }

       mIsBound = true;

        // Create a Messenger from a raw IBinder
       mServiceRequest = new Messenger(service);
    }


    /**
     * Called when a connection to the TIOService has been lost.  This typically
     * happens when the process hosting the service has crashed or been killed.
     * This does <em>not</em> remove the ServiceConnection itself -- this
     * binding to the service will remain active, and you will receive a call
     * to {@link #onServiceConnected} when the Service is next running.
     *
     * @param name The concrete component name of the service whose
     * connection has been lost.
     */
    @Override
    public void onServiceDisconnected(ComponentName name) {

        if ( TIOManager.getInstance().isTraceEnabled() ) {
            Log.d(TAG, "onServiceDisconnected");
        }

        mIsBound = false;

        // TODO signal disconnect to all conneions ???
    }
}

