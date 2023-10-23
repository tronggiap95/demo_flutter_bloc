package com.octomed.octo360.scanner;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

/**
 * Created by Manh Tran
 */

public class BleStateController {
    //TAG
    private final String TAG = this.getClass().getName();

    private static BleStateController mBleController = null;
    private BluetoothAdapter mBtAdapter;

    private BluetoothStateListener mListener;


    private BleStateController(Context context) {
        try {
            mBtAdapter = BluetoothAdapter.getDefaultAdapter();
            IntentFilter BTIntent = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
            context.registerReceiver(mReceiver, BTIntent);
        }catch (Exception ex) {
            ex.printStackTrace();
        }

    }

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(mBtAdapter.ACTION_STATE_CHANGED)) {
                final int state = intent.getIntExtra(mBtAdapter.EXTRA_STATE, mBtAdapter.ERROR);
                if (mListener == null) return;
                switch (state){
                    case BluetoothAdapter.STATE_OFF:
                        mListener.onBluetoothOff();
                        break;
                    case BluetoothAdapter.STATE_ON:
                        mListener.onBluetoothOn();
                        break;
                }
            }
        }
    };

    /**
     * Get a Controller
     *
     * @return
     */
    public static BleStateController getDefaultBleController(Context context) {
        if (mBleController == null) {
            mBleController = new BleStateController(context);
        }
        return mBleController;
    }

    public void setListener(BluetoothStateListener listener) {
        this.mListener = listener;
    }

    public boolean isBluetoothEnabled() {
        if (mBtAdapter == null) {
            return false;
        }
        return mBtAdapter.isEnabled();
    }
    /**
     * enable bluetooth adapter
     */
    @SuppressLint("MissingPermission")
    public void enableBtAdapter() {
        if (!mBtAdapter.isEnabled()) {
            mBtAdapter.enable();
        }
    }

    public interface BluetoothStateListener {

        void onBluetoothOn();

        void onBluetoothOff();
    }
}