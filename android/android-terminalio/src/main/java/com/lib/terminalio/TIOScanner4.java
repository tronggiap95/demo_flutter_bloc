/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.bluetooth.BluetoothAdapter;
import android.content.Context;


final class TIOScanner4 extends TIOScanner {

    public TIOScanner4(BluetoothAdapter adapter, TIOPeripheralList list) {
        super(adapter,list);
    }

    public  void start(TIOManagerCallback listener,Context context) {
        mListener           = listener;
        mApplicationContext = context;

        // We would like to filter scan results for the TerminalIO service UUID, but Android 4.4 does
        // not support the filtering of scan records containing 128-bit UUIDs;
        // so we have to consume all scan results and implement our own filtering mechanism.
        //		this.mBluetoothAdapter.startLeScan(new UUID[] { TIO.TIO_SERVICE_UUID }, this._scanListener);
        mBluetoothAdapter.startLeScan( this );
    }

    public  void stop() {
        mBluetoothAdapter.stopLeScan(this);
    }

}
