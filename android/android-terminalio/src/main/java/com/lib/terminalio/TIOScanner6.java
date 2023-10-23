/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.annotation.TargetApi;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanSettings;
import android.content.Context;

import java.util.ArrayList;
import java.util.List;

@TargetApi(21)
final class TIOScanner6 extends TIOScanner {

    private BluetoothLeScanner scanner;
    private ScanCallback mScanCallback;

    public TIOScanner6(BluetoothAdapter adapter, TIOPeripheralList list) {
        super(adapter,list);

        scanner = mBluetoothAdapter.getBluetoothLeScanner();

        mScanCallback = new ScanCallback() {
            @Override
            public void onScanResult(int callBackType, ScanResult result) {
                super.onScanResult(callBackType, result);

                onLeScan(result.getDevice(), result.getRssi(), result.getScanRecord().getBytes());
            }

            @Override
            public void onBatchScanResults(List<ScanResult> results) {
                for(ScanResult scanResult : results) {
                    STTrace.line("ScanResult: " + scanResult.toString());
                }
            }

            @Override
            public void onScanFailed(int errorCode) {
                STTrace.line("Scan failed with error code: " + errorCode);
            }
        };
    }

    public  void start(TIOManagerCallback listener,Context context) {
        mListener           = listener;
        mApplicationContext = context;

        ScanSettings settings = new ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .build();

        List<ScanFilter> filters = new ArrayList<ScanFilter>();

        scanner.startScan(filters, settings, mScanCallback);
    }

    public  void stop() {
        scanner.stopScan(mScanCallback);
    }

}
