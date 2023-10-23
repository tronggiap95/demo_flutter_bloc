/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothManager;
import android.content.Context;
import android.content.pm.PackageManager;

import java.io.InvalidObjectException;
import java.util.UUID;

import static android.os.Build.VERSION.RELEASE;
import static android.os.Build.VERSION.SDK_INT;
import static android.os.Build.VERSION_CODES.LOLLIPOP;

/**
 * The TIOManager is the fundamental class to provide TerminalIO functionality towards the application. It exists as one instance only per application (singleton),
 * encapsulating the TerminalIO Bluetooth Low Energy functionality and supplying its listener {@link TIOManagerCallback} with TerminalIO related events.
 */
public final class TIOManager {

    /**
     *  The TerminalIO service UUID.
     *  @return A UUID instance containing the TerminalIO service UUID.
     */
    static final UUID TIO_SERVICE_UUID = UUID.fromString("0000FEFB-0000-1000-8000-00805F9B34FB");
    static final String SERVICE_PACKAGE_NAME = "TioService";


    private static TIOManager       mInstance = null;
    private static boolean          mIsTrace  = true;
    private Context                 mApplicationContext;
    private BluetoothAdapter        mBluetoothAdapter;
    private TIOPeripheralList       mPeripherals;
    private TIOScanner              mScanner;
    private TIOServiceConnection    mServiceConnection;


    //******************************************************************************
    // Initialization
    //******************************************************************************

    /**
     * Create the singleton TIOManager instance - including the tying up to the Android BluetoothAdapter -
     * and loads the list of know peripherals. It is therefore recommended to call this message at
     * an early state of application startup, e.g. within the appliction's onCreate() override.
     * <p/>
     * No TIOManager operations shall be performed before this method has been called.
     *
     * @return The singleton TIOManager instance.
     */
    public static void initialize(Context applicationContext) throws RuntimeException {
        STTrace.setTag("TerminalIo");

        if ( mIsTrace ) {
          STTrace.method("initialize");
        }

        if (applicationContext == null) {
            throw new NullPointerException("Context may not be null");
        }

        TIOManager.mInstance = new TIOManager(applicationContext);
    }


    /**
     * Private constructor for this singleton instance
     * @param applicationContext Needed context fron Android application
     * @throws RuntimeException
     */
    private TIOManager(Context applicationContext) throws RuntimeException {
        mApplicationContext = applicationContext;

        //checkLeSupport(applicationContext);

        BluetoothManager bluetoothManager = (BluetoothManager) applicationContext.getSystemService(Context.BLUETOOTH_SERVICE);
        mBluetoothAdapter   = bluetoothManager.getAdapter();
        mPeripherals        = new TIOPeripheralList(mBluetoothAdapter);

        mPeripherals.load(applicationContext);

        startService();
    }

    /**
     * Must be called when application is terminated. Perform a cleanup and disconnect any
     * established connection if avail.
     */
    public void done() {
        if ( mIsTrace ) {
            STTrace.method("done");
        }
        for (TIOPeripheralImpl peripheral : mPeripherals) {
            peripheral.cleanup();
        }
    }


    /**
     * Check if Bluetooth LE is supported by this Android device, and if so, make sure it is enabled.
     *
     * @return false if it is supported and not enabled
     * @throws RuntimeException if Bluetooth LE is not supported.  (Note: The Android emulator will do this)
     */
    //@TargetApi(18)
    private boolean checkLeSupport(Context context) throws RuntimeException {

        if (android.os.Build.VERSION.SDK_INT < 18) {
            throw new RuntimeException("Bluetooth LE not supported by this device");
        }

        if (! context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
           throw new RuntimeException("Bluetooth LE not supported by this device");
        }

        return true;
    }

    //******************************************************************************
    // Properties
    //******************************************************************************

    /**
     * Gets the current Bluetooth enabled state.
     *
     * @return <code>true</code> if Bluetooth is enabled on the Smart Phone, <code>false</code> otherwise.
     */
    public boolean isBluetoothEnabled() {
        return mBluetoothAdapter.isEnabled();
    }


    /**
     * Gets all TIOPeripheral instances representing the currently known TerminalIO peripherals.
     *
     * @return An array of TIOPeripheral instances representing all currently known TerminalIO peripherals.
     */
    public TIOPeripheral[] getPeripherals() {
        return mPeripherals.getList();
    }


    //******************************************************************************
    // Public methods
    //******************************************************************************

    /**
     * Returns the singleton TIOManager instance.
     *
     * @return The singleton TIOManager instance.
     */
    public static final TIOManager getInstance() {
        return mInstance;
    }

    public  TIOPeripheral getPeripheral(String address) {
        for (int i = 0; i < mPeripherals.size(); i++) {
            if (mPeripherals.get(i).getAddress().equalsIgnoreCase(address)){
                return mPeripherals.get(i);
            }
        }
        return null;
    }

    public void removePeripheral(String address) {
        TIOPeripheral tioPeripheral = getPeripheral(address);
        if (tioPeripheral != null){
            removePeripheral(tioPeripheral);
        }
    }

    /**
     * Enable/disable Terminal-IO module trace information.
     * @param flag  If flag is TRUE than Terminal-IO create trace information. Default is disabled.
     */
    public static void enableTrace(boolean flag) {
        mIsTrace = flag;
    }

    /**
     *
     * @return return state of traces enabled.
     */
    public static boolean isTraceEnabled() {
        return mIsTrace;
    }


    /**
     * Starts a Bluetooth Low Energy scan procedure.
     * <p/>
     * Discovered TerminalIO peripherals will be reported via the {@link TIOManagerCallback#onPeripheralFound(TIOPeripheral) TIOManagerCallback.onPeripheralFound())} method.
     * <p/>
     * Call stopScan to stop the scan procedure and save battery power.
     */
    public void startScan(TIOManagerCallback listener) {
        if ( mIsTrace ) {
            STTrace.method("startScan");
        }

        if ( listener == null) {
            throw new NullPointerException("! listener is undefined" );
        }

        if (mScanner == null) {
            if (SDK_INT > LOLLIPOP) {
                STTrace.line("Detected android version " + RELEASE);
                mScanner = new TIOScanner6(mBluetoothAdapter,mPeripherals);
            } else {
                mScanner = new TIOScanner4(mBluetoothAdapter,mPeripherals);
            }
        }

        mScanner.start(listener, mApplicationContext);
    }

    /**
     * Stops a currently active scan procedure. Throws an exception when no scan is currently active.
     */
    public void stopScan() throws InvalidObjectException {

        if ( mIsTrace ) {
            STTrace.method("stopScan");
        }

        if ( mScanner == null ) {
            throw new InvalidObjectException("! Scan process not started before");
        }
        mScanner.stop();
    }

    /**
     * Loads TIOPeripherals previously saved with {@link #savePeripherals() savePeripherals()}.
     * <p/>
     * Populates the TIOManager's peripherals list with TIOPeripheral instances created from a serialized
     * list of Bluetooth addresses. This method is called implicitly
     * during initialization via {@link #initialize(Context) initialize()}.
     * <p/>
     * The reconstructed TIOPeripheral instances do not contain any advertisement information.
     * If Bluetooth has been switched off, also the name information will be lost.
     * If any advertisement information (e.g. local name, TIOPeripheralOperationMode) or name information is required,
     * call {@link #startScan(TIOManagerCallback listener) startScan()} in order to refresh the
     * advertisement information of peripherals within radio range.
     * Called internally when TIOManager is created.
     * @return returns true when successfully loaded the cached informations.
     */
    public boolean loadPeripherals() {
        if ( mIsTrace ) {
            STTrace.method("loadPeripherals");
        }

        return mPeripherals.load(mApplicationContext);
    }

    public TIOPeripheral createPeripheral(String address) {
        if ( mIsTrace ) {
            STTrace.method("loadPeripherals");
        }

        for (int index = 0; index < mPeripherals.size(); index++){
            TIOPeripheral peripheral = mPeripherals.get(index);
            if (peripheral.getAddress().equalsIgnoreCase(address)) {
                if(peripheral.getConnection() != null) {
                    peripheral.getConnection().clear();
                }
                removePeripheral(peripheral.getAddress());
            }
        }
        return mPeripherals.createPheripheral(mApplicationContext, address);
    }

    /**
     * Serializes a list of known peripheral Bluetooth addresses to a persistent file in the application directory.
     * Not called internally.
     * @return returns true when successfully cached the device informations.
     */
    public boolean savePeripherals() {
        if ( mIsTrace ) {
            STTrace.method("savePeripherals");
        }

        return mPeripherals.save(mApplicationContext);
    }

    /**
     * Retrieves the TIOPeripheral instance with the specified address.
     * <p/>
     * Applications may use this method to retrieve an object instance in cases where the Bluetooth
     * address string has been transmitted within a message, e.g. a broadcast or an intent.
     *
     * @param address A Bluetooth address string to retrieve a TIOPeripheral instance for; format is [00:11:22:AA:BB:CC].
     * @return The requested TIOPeripheral instance, or null, if no matching instance could be found.
     */
    public TIOPeripheral findPeripheral(String address) {
        return mPeripherals.find(address);
    }

    /**
     * Removes the specified peripheral from the TIOManager's peripheral list.
     */
    public void removePeripheral(TIOPeripheral peripheral) {
        if ( mIsTrace ) {
            STTrace.method("removePeripheral", peripheral.toString());
        }

        TIOPeripheralImpl instance = (TIOPeripheralImpl) peripheral;

        // First make shure that we are not connected

        instance.cleanup();

        mPeripherals.remove( instance );
        mPeripherals.save(mApplicationContext);
    }

    /**
     * Removes all peripherals from the TIOManager's peripheral list.
     */
    public void removeAllPeripherals() {
        if ( mIsTrace ) {
            STTrace.method("removeAllPeripherals");
        }

        for (TIOPeripheralImpl peripheral : mPeripherals) {
            peripheral.cleanup();
        }

        mPeripherals.clear();
        mPeripherals.save(mApplicationContext);
    }


    /**
     * Internal, start the connection to internal service instance.
     * @return Result of operation
     */
    boolean startService() {

        mServiceConnection = new TIOServiceConnection(mApplicationContext);

        if ( ! mServiceConnection.start() ) {
            if ( mIsTrace ) {
                STTrace.error("cannot start service");
            }
            return false;
        }

       return true;
    }

    /**
     * Internal, create new TIOConnection instance
     * @param peripheral
     * @param listener
     * @return
     */
    TIOConnection createConnectionInstance(TIOPeripheralImpl peripheral, TIOConnectionCallback listener) {
         return  new TIOConnectionImpl(peripheral,listener);

//        return new TIOConnectionProxy(peripheral,listener,mServiceConnection);
    }


}
