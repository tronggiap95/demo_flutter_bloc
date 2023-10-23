package com.octo.octo_beat_plugin.core.bluetooth;

import android.bluetooth.BluetoothDevice;
import android.os.Parcel;
import android.os.Parcelable;

public class BluetoothSocketBundle implements Parcelable {
    BluetoothDevice bluetoothDevice;

    protected BluetoothSocketBundle(Parcel in) {
        bluetoothDevice = in.readParcelable(BluetoothDevice.class.getClassLoader());
    }

    public static final Creator<BluetoothSocketBundle> CREATOR = new Creator<BluetoothSocketBundle>() {
        @Override
        public BluetoothSocketBundle createFromParcel(Parcel in) {
            return new BluetoothSocketBundle(in);
        }

        @Override
        public BluetoothSocketBundle[] newArray(int size) {
            return new BluetoothSocketBundle[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(bluetoothDevice, flags);
    }

}
