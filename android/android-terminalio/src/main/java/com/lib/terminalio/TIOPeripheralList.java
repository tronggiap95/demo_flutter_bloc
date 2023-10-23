/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;


import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;

final class TIOPeripheralList extends  ArrayList<TIOPeripheralImpl> {

    private static final String KNOWN_PERIPHERAL_ADDRESSES_FILE_NAME = "OctoBeat_TIOKnownPeripheralAddresses";

    private BluetoothAdapter    mAdapter;

    /**
     * @param adapter
     */
    public TIOPeripheralList(BluetoothAdapter adapter) {
      mAdapter = adapter;
    }


    /**
     * Load peripheral list from internal storage
     * @param context
     * @return
     */
    boolean load (Context context) {

        String[] addresses  = null;

        if ( context == null ) {
            STTrace.error(" ! Undefined context value");
            return false;
        }

        try {
            FileInputStream fileStream     = context.openFileInput(KNOWN_PERIPHERAL_ADDRESSES_FILE_NAME);
            ObjectInputStream objectStream = new ObjectInputStream(fileStream);

            addresses = (String[]) objectStream.readObject();
            objectStream.close();
            fileStream.close();
        } catch (FileNotFoundException ex) {
            STTrace.error("Saved peripheral addresses file not found; application is probably installed for the first time...");
            return false;
        } catch (Exception ex) {
            STTrace.exception(ex);
            return false;
        }

        for (String address : addresses) {

            // check for duplicates
            if ( find(address) != null)
                continue;

            // create TIOPeripheral instance from Bluetooth address
            try {
                BluetoothDevice device = mAdapter.getRemoteDevice(address);

                TIOPeripheralImpl peripheral = new TIOPeripheralImpl(device,context,null);

                STTrace.line("loaded peripheral " + peripheral.toString() + " with name " + device.getName());

                // add peripheral to list
                add(peripheral);
            }
            catch (Exception ex) {

            }
        }

      return true;
    }

    public TIOPeripheral createPheripheral(Context context, String address) {
        // create TIOPeripheral instance from Bluetooth address
        try {
            BluetoothDevice device = mAdapter.getRemoteDevice(address);

            TIOPeripheralImpl peripheral = new TIOPeripheralImpl(device,context,null);

            STTrace.line("loaded peripheral " + peripheral.toString() + " with name " + device.getName());

            // add peripheral to list
            add(peripheral);
            return peripheral;
        }
        catch (Exception ex) {
            return null;
        }
    }

    /**
     * Save peripheral list information persistent
     * @param context
     * @return
     */
    boolean save(Context context) {

        // Build new list with peripherals where save is required
        ArrayList<String> addressList = new ArrayList<String>();
        for (TIOPeripheral peripheral : this) {
            if (peripheral.shallBeSaved()) {
                addressList.add(peripheral.getAddress());
            }
        }

        // write address string array to file
        String[] addresses = addressList.toArray(new String[addressList.size()]);
        try {
            FileOutputStream fileStream = context.openFileOutput(KNOWN_PERIPHERAL_ADDRESSES_FILE_NAME, Context.MODE_PRIVATE);
            ObjectOutputStream objectStream = new ObjectOutputStream(fileStream);
            objectStream.writeObject(addresses);
            objectStream.close();
            fileStream.close();
        } catch (Exception ex) {
            STTrace.exception(ex);
            return false;
        }

       return true;
    }

    /**
     * Find peripheral for given Bluetooth address
     * @param address
     * @return The peripheral when found, otherwise null.
     */
    TIOPeripheral find(String address) {
        for (TIOPeripheral peripheral : this) {
            if (peripheral.getAddress().equals(address)) {
                return peripheral;
            }
        }
        return null;
    }

    /**
     * Returns an array repesentation from peripheral list
     * @return
     */
    public TIOPeripheral[] getList() {
        return toArray(new TIOPeripheral[ size()]);
    }
}
