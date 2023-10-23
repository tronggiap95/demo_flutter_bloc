/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;

abstract class TIOScanner implements BluetoothAdapter.LeScanCallback {

    protected TIOPeripheralList     mList;
    protected TIOManagerCallback    mListener;
    protected BluetoothAdapter      mBluetoothAdapter;
    protected Context               mApplicationContext;
    protected TIOManager            mTio;

    TIOScanner() {
    }

    public TIOScanner(BluetoothAdapter adapter,TIOPeripheralList list) {
        mList             = list;
        mBluetoothAdapter = adapter;
        mTio              = TIOManager.getInstance();
    }

    public abstract void start(TIOManagerCallback listener,Context context);

    public abstract void stop();


    /**
     * Callback called from Android GATT when an device is scanned
     * @param device
     * @param rssi
     * @param scanRecord
     */
    public void onLeScan(final BluetoothDevice device, int rssi, byte[] scanRecord) {

        if ( mTio.isTraceEnabled() ) {
//            STTrace.line("onLeScan " + device.getAddress()  + " rssi " + rssi);
        }

        // So this is called from low level native scanning process. We start a thread
        // for each device found, so all CPU's have some to do :)

        AndroidBLEScanRecord record = AndroidBLEScanRecord.createFromRecordData(scanRecord);

        if (! record.containsServiceUuid( TIOManager.TIO_SERVICE_UUID)) {
//            STTrace.line(" Device without TIO, ignored");
            return;
        }

       new Thread( new ScannedDevice(device, rssi, record) ).start();
    }


    //******************************************************************************
    // LeScanCallback implementation
    //******************************************************************************
    private class ScannedDevice implements Runnable {

        private BluetoothDevice      mDevice;
        private int                  mRssi;
        private AndroidBLEScanRecord mScanRecord;

        public ScannedDevice(final BluetoothDevice device, int rssi, AndroidBLEScanRecord record) {
            mDevice     = device;
            mRssi       = rssi;
            mScanRecord = record;
        }

        @Override
        public void run() {
            // extract TerminalIO advertisement info
            TIOAdvertisement advertisement = TIOAdvertisement.create( mScanRecord.getLocalName(),mRssi, mScanRecord.getManufacturerSpecificData());

            if (advertisement == null) {
                STTrace.error("invalid advertisement");
                return;
            }

            // parse scan record for matching service UUID; this is the replacement for the filtering function missing in Android 4.4
//            STTrace.line("found TIO preripheral address = " + mDevice.getAddress() + "; name = " + mScanRecord.getLocalName() + "; rssi = " + mRssi);

            //STTrace.line("read advertisement = " + advertisement.toString());

            // check for known peripheral
            TIOPeripheralImpl knownPeripheral = (TIOPeripheralImpl) mList.find(mDevice.getAddress());

            if (knownPeripheral != null) {
//                STTrace.line("Scanned device already known, update");

                // check for possible advertisement update
                if (knownPeripheral.update(advertisement)) {
                    STTrace.line("advertisement has changed");
                    signalUpdate(knownPeripheral);
                }
                return;
            }

            onDeviceFound(mDevice, mRssi, advertisement);
        }
    }

    private void onDeviceFound(BluetoothDevice mDevice, int rssi,TIOAdvertisement advertisement) {
        // create new TIOPeripheral instance

        final TIOPeripheralImpl peripheral = new TIOPeripheralImpl(mDevice,mApplicationContext, advertisement);

        // add peripheral to list
        mList.add(peripheral);

        // notify to application
        signalDiscover(peripheral);

        // save updated peripheral list
        mList.save(mApplicationContext);
    }


    //******************************************************************************
    // Callback events, start each callback in his own thread
    //******************************************************************************

    protected void runSignal(Runnable proc) {
        if (mListener instanceof Activity) {
            ((Activity) mListener).runOnUiThread(proc);
        } else {
            new Thread(proc).start();
        }
    }

    protected void signalDiscover(final TIOPeripheral peripheral) {

         Runnable runnable = new Runnable() {
                @Override
                public void run() {
                    try {
                        mListener.onPeripheralFound(peripheral);
                    }
                    catch(Exception ex) {
                        STTrace.error("! Error calling lisener.onPeripheralFound() ");
                        STTrace.error(ex.toString());
                    }
                }
            };

         runSignal(runnable);
    }

    /**
     * Signals the right event to listener
     * @param peripheral
     */
    protected void signalUpdate(final TIOPeripheral peripheral) {

        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                try {
                    mListener.onPeripheralUpdate(peripheral);
                }
                catch(Exception ex) {
                    STTrace.error("! Error calling lisener.onPeripheralUpdate() ");
                    STTrace.error(ex.toString());
                }

            }
        };

        runSignal(runnable);
    }
}
