/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.app.Activity;
import android.util.Log;

import java.io.IOException;
import java.security.InvalidParameterException;

/**
 * TIOConnection implementation and works as proxy object, pass all request to service connection
 * and wait for messages from service to signal results back to application
 */
class TIOConnectionProxy implements TIOConnection {

    static int              mInstanceCount;
    int                     mInstanceId;
    TIOPeripheralImpl       mPeripheral;
    TIOConnectionCallback   mListener;
    TIOServiceConnection    mService;
    int                     mState;

    private int             mRemoteUartMtuSize = MAX_TX_DATA_SIZE; // UART MTU size of remote side
    private int             mLocalUartMtuSize  = MAX_TX_DATA_SIZE; // UART MTU size of local side

    final String TAG = "TIOConnection";

    public TIOConnectionProxy(TIOPeripheral peripheral,TIOConnectionCallback listener,TIOServiceConnection service) {
        mPeripheral = (TIOPeripheralImpl) peripheral;
        mListener   = listener;
        mService    = service;
        mState      = TIOConnection.STATE_CONNECTING;
        mInstanceId = ++mInstanceCount;

        if ( ! mService.connectRequest(this, peripheral.getAddress()) ) {
            // Some things are wrong. We cannot report a result, so signal disconnect
            signalConnectFailed("Start connection failed #"+mInstanceId);
        }
    }

    @Override
    public void setListener(TIOConnectionCallback listener) {
        mListener = listener;
    }

    @Override
    public void disconnect() throws IOException {

        checkConnectionState();

        mState = TIOConnection.STATE_DISCONNECTING;

        if ( ! mService.disconnectRequest(this) ) {
            throw new IOException("Send disconnect failed #"+mInstanceId);
        }
    }

    @Override
    public void cancel() throws IOException {
        mState = TIOConnection.STATE_DISCONNECTING;

        if ( ! mService.cancelRequest(this) ) {
            throw new IOException("Send cancel failed #"+mInstanceId);
        }
    }


    @Override
    public void transmit(byte[] data) throws IOException {
        checkConnectionState();

        if ( data == null ) {
            throw new NullPointerException();
        }

        if ( data.length == 0) {
            throw new InvalidParameterException("Data length cannot be 0");
        }

        mService.dataRequest(this,data);
    }

    @Override
    public void clear() {
        mService.destroy();
    }

    @Override
    public TIOPeripheral getPeripheral() {
      return mPeripheral;
    }

    @Override
    public int   getConnectionState() {
     return mState;
    }

    @Override
    public void readRemoteRssi(int delay) throws IOException {

        checkConnectionState();;
        mService.rssiRequest(this,delay);
    }

    @Override
    public int getRemoteMtuSize() { return mRemoteUartMtuSize; }

    @Override
    public int getLocalMtuSize() { return mLocalUartMtuSize; }

    public int getId() {
        return mInstanceId;
    }

    private void checkConnectionState() throws IOException {
        if ( mState != TIOConnection.STATE_CONNECTED ) {
            throw new IOException("Not connected");
        }
    }


    //-------------------------------------------------------------------------------------------
    // Callback events
    //-------------------------------------------------------------------------------------------

    protected void runSignal(Runnable proc) {
        if ( mListener != null) {
            if (mListener instanceof Activity) {

            } else {
                new Thread(proc).start();
            }
        }
    }

     void signalConnected() {
        mState = TIOConnection.STATE_CONNECTED;
        try {
            mListener.onConnected(TIOConnectionProxy.this);
        }
        catch(Exception ex) {
            Log.e(TAG, "! signalConnected failed "+ex.toString());
        }
    }

    void signalConnectFailed(final String message) {
        mState = TIOConnection.STATE_DISCONNECTED;
        mPeripheral.onDisconnect();
        try {
            mListener.onConnectFailed(TIOConnectionProxy.this, message);
        }
        catch(Exception ex) {
            Log.e(TAG, "! signalConnected failed "+ex.toString());
        }
    }

     void signalDisconnected(final String message) {
        mState = TIOConnection.STATE_DISCONNECTED;
        mPeripheral.onDisconnect();
        try {
            mListener.onDisconnected(TIOConnectionProxy.this, message);
        }
        catch(Exception ex) {
             Log.e(TAG, "! signalDisconnected failed "+ex.toString());
        }
    }

     void signalData(final byte[] data) {
        try {
            mListener.onDataReceived(TIOConnectionProxy.this, data);
        }
        catch(Exception ex) {
            Log.e(TAG, "! signalData failed "+ex.toString());
        }
    }

     void signalDataTransmitted(final int status, final int bytesWritten) {
        try {
            mListener.onDataTransmitted(TIOConnectionProxy.this, status, bytesWritten);
        }
        catch(Exception ex) {
            Log.e(TAG, "! signalDataTransmitted failed "+ex.toString());
        }
    }

    void signalRssi(final int status, final int value) {
       try {
            mListener.onReadRemoteRssi(TIOConnectionProxy.this, status, value);
        }
        catch(Exception ex) {
            Log.e(TAG, "! signalRssi failed "+ex.toString());
        }
    }

    void signalLocalMtuIndication(final int value) {
        try {
            mLocalUartMtuSize = value;
            mListener.onLocalUARTMtuSizeUpdated(TIOConnectionProxy.this, mLocalUartMtuSize);
        }
        catch(Exception ex) {
            Log.e(TAG, "! signalLocalMtuIndication failed "+ex.toString());
        }
    }

    void signalRemoteMtuIndication(final int value) {
        try {
            mRemoteUartMtuSize = value;
            mListener.onRemoteUARTMtuSizeUpdated(TIOConnectionProxy.this, mRemoteUartMtuSize);
        }
        catch(Exception ex) {
            Log.e(TAG, "! signalRemoteMtuIndication failed "+ex.toString());
        }
    }
}
