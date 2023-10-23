/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.bluetooth.BluetoothDevice;
import android.content.Context;

//import TIOConnectionImpl;

class TIOConnectionProvider extends TIOConnectionImpl {

    TIOService mService;
    int        mId;

    TIOConnectionProvider( TIOService service,BluetoothDevice device, Context context,int id) {
        super(device, context);
      mService = service;
      mId      = id;
    }

    public int getId() {
        return mId;
    }

    @Override
    protected void signalDisconnected(final String message) {
       mService.sendDisconnectIndication(mId,message);
    }

    @Override
    protected void signalConnectFailed(final String message) {
        mService.sendCallFailed(mId,message);
    }

    @Override
    protected void signalConnected() {
        mService.sendConnectionIndication(mId);
    }

    @Override
    protected void signalData(final byte[] data) {
        mService.sendDataIndication(mId,data);
    }

    @Override
    protected void signalDataTransmitted(final int status, final int bytesWritten) {
        mService.sendDataConfirmation(mId,status,bytesWritten);
    }

    @Override
    protected void signalRssi(final int status,final int rssi) {
        mService.sendRssiIndication(mId,status,rssi);
    }

    @Override
    protected void signalLocalMtu(final int localMtuSize) {
        mService.sendLocalMtuIndication(mId, 0, localMtuSize);
    }

    @Override
    protected void signalRemoteMtu(final int remoteMtuSize) {
        mService.sendRemoteMtuIndication(mId, 0, remoteMtuSize);
    }
}