/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCallback;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;
import android.bluetooth.BluetoothGattService;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;
import java.util.concurrent.Semaphore;

import static android.os.Build.VERSION.RELEASE;

//import java.util.Queue;
//import java.util.concurrent.ConcurrentLinkedQueue;

class TIOConnectionImpl  implements TIOConnection {

    /**
     *  The TerminalIO UART RX characteristic UUID.
     *  This characteristic is used by the central to transmit UART data to the peripheral.
     *  @return A UUID instance containing the TerminalIO UART characteristic UUID.
     */
    private static final UUID UART_RX_UUID = UUID.fromString("00000001-0000-1000-8000-008025000000");

    /**
     *  The TerminalIO UART TX characteristic UUID.
     *  This characteristic is used by the peripheral to transmit UART data to the central.
     *  @return A UUID instance containing the TerminalIO UART characteristic UUID.
     */
    private static final UUID UART_TX_UUID = UUID.fromString("00000002-0000-1000-8000-008025000000");

    /**
     *  The TerminalIO UART RX credits characteristic UUID.
     *  This characteristic is used by the central to grant UART credits to the peripheral.
     *  @return A UUID instance containing the TerminalIO UART credits characteristic UUID.
     */
    private static final UUID UART_RX_CREDITS_UUID = UUID.fromString("00000003-0000-1000-8000-008025000000");

    /**
     *  The TerminalIO UART TX credits characteristic UUID.
     *  This characteristic is used by the peripheral to grant UART credits to the central.
     *  @return A UUID instance containing the TerminalIO UART credits characteristic UUID.
     */
    private static final UUID UART_TX_CREDITS_UUID = UUID.fromString("00000004-0000-1000-8000-008025000000");

    /**
     *  Returns the TerminalIO UART_RX_MTU_UUID characteristic UUID.
     *  This characteristic is used by the central to MTU size negotitation for UART data.
     *  @return A UUID instance containing the TerminalIO UART MTU size characteristic UUID.
     */
    private static final UUID UART_RX_MTU_UUID = UUID.fromString("00000009-0000-1000-8000-008025000000");

    /**
     *  Returns the TerminalIO UART_TX_MTU_UUID characteristic UUID.
     *  This characteristic is used by the central to MTU size negotitation for UART data.
     *  @return A UUID instance containing the TerminalIO UART MTU size characteristic UUID.
     */
    private static final UUID UART_TX_MTU_UUID = UUID.fromString("0000000A-0000-1000-8000-008025000000");

    /**
     *  The TerminalIO service UUID.
     *  @return A UUID instance containing the TerminalIO service UUID.
     */
    private static final UUID TIO_SERVICE_UUID = UUID.fromString("0000FEFB-0000-1000-8000-00805F9B34FB");

    private static final UUID CCC_BITS_UUID = UUID.fromString("00002902-0000-1000-8000-00805F9B34fB");

    protected static final int MAX_RX_CREDITS_COUNT           = 64;
    protected static final int DEFAULT_MIN_RX_CREDITS_COUNT   = 16;
    protected static final int WRITE_CALLBACK_TIMEOUT         = 1000;
    protected static final int RSSI_DEFERRAL_INTERVAL         = 1200;

    private enum ConnectionState {
        csDisconnected,
        csConnectPending,
        csGattConnected,
        csSetMtu,
        csServicesDiscovered,
        csTxSubscribed,
        csTxCreditsSubscribed,
        csGrantCredits,
        csWaitTxCredits,
        csConnected,
        csDisconnectPending,
        csCallFailed,
        csPairingRequest,
        csCallRetry,
        csIdle
    }

    protected static int                    mInstanceCount;
    private int                             mInstanceId;
    private boolean                         mIsAndroid4;
	private int                             mAndroidVersionMain;
    private BluetoothDevice                 mDevice;
    private BluetoothGatt                   mGatt;
    private BluetoothGattService            mGattService;
    private BluetoothGattCharacteristic     mTxCharacteristic;
    private BluetoothGattCharacteristic     mTxCreditsCharacteristic;
    private BluetoothGattCharacteristic     mRxCharacteristic;
    private BluetoothGattCharacteristic     mRxCreditsCharacteristic;

    private BluetoothGattCharacteristic     mRxMtuCharacteristic;
    private BluetoothGattCharacteristic     mTxMtuCharacteristic;

    private BroadcastReceiver               mBondingReceiver;
    private BroadcastReceiver               mPairingReceiver;
    private BroadcastReceiver               mAclDisconnectedReceiver;

    private int                             mWriteCharacteristicPending;
    private boolean                         mTxSubscribed;
    private boolean                         mTxCreditsSubscribed;
    private boolean                         mTxMtuSubscribed;
    private long                            mStartTime;
    private long                            mLastTimeStamp;

    private TIOManager                      mTio;
    private ConnectionState                 mState ;
    private TIOConnectionCallback           mListener;
    private TIOPeripheralImpl               mPeripheral;
    private Context                         mApplicationContext;
    private int                             mLastStatus;
    private String                          mAddress;

    private boolean                         mIsWriting;
    private Semaphore                       mWriteTrigger;
    private Thread                          mWriteThread;
    private boolean                         mWriteRx;

    private final Object                    mWriteLock  = new Object();
    private TransmitFifo                    mFifo;

    private int                             mRemoteCredits;  // TX credits granted by the peripheral
    private int                             mLocalCredits;   // RX credits granted to the peripheral

    private int                             mLastRssi;
    private boolean                         mRssiPending;
    private Timer                           mRssiTimer;
    private int                             mRssiDelay = RSSI_DEFERRAL_INTERVAL;

    private int                             mMaxLocalCredits = MAX_RX_CREDITS_COUNT;
    private int                             mMinLocalCredits = DEFAULT_MIN_RX_CREDITS_COUNT;

    private Timer                           mDeferrTimer;
    private Timer                           mDisconnectWatch;
    private boolean                         mIsCallRetry;
    private int                             mCallCount;

    private boolean                         mReconnectRequested;
    private Timer                           mReconnectWatch;

    private int                             mMaxFrameSize             = MAX_TX_DATA_SIZE;

    private int                             mRemoteUartMtuSize = MAX_TX_DATA_SIZE; // UART MTU size of remote side
    private int                             mLocalUartMtuSize  = MAX_TX_DATA_SIZE; // UART MTU size of local side
    private int                             mPendingLocalUartMtuSize; // UART MTU size of local side

    private interface TransmitCompletedListener {
        void onTransmitCompleted(int status, int bytesWritten);
    }


    private class TransmitFifo extends ArrayList<byte []> {

        private TransmitCompletedListener mListener;
        private int                       mTxCount;
        private byte []                   mNextBlock;
        private int                       mNextBlockSize;
        private int                       mBytesWritten;
        private int                       mRemoteCharacteristicSize;
        private int                       mLastBytesWritten;

        TransmitFifo(TransmitCompletedListener listener) {
            mListener                 = listener;
            reset();
        }

        /**
         * Clear FIFO and discard all pending data
         */
        @Override public void clear() {
            super.clear();
            reset();
        }

        @Override public boolean isEmpty() {
            boolean  empty = super.isEmpty();

            if ( empty ) {
                return mNextBlock == null;
            }

            return false;
        }


        /**
         * Get next data block with given size for transmit. Called synchronized.
         * @param size
         * @return null if no more data avail in FIFO.
         */
        byte [] getNext(final int size) {

            byte[] data   = null;
            int    length = 0;

            //
            // Check for the next block
            //
            if ( mNextBlock == null ) {
                if ( ! isEmpty() ) {
                    mNextBlock     = remove(0);
                    mNextBlockSize = mNextBlock.length;
                    mBytesWritten  = 0;
                }
            }

            if  ( mNextBlock == null) {
                if ( mTio.isTraceEnabled() ) {
                    STTrace.line("fifo empty");
                }
                return null;
            }

            //
            // Determine length of next data block
            //
            length = mNextBlockSize - mBytesWritten;
            if ( length > size ) {
                length = size;
            }

            // copy data to be written from buffer
            data = new byte [ length ];

            // We check param again to make it safer
            if ( mBytesWritten + length > mNextBlock.length) {
                STTrace.error("! error out if bounds in given block "+mBytesWritten+length+ " > "+mNextBlock.length);
            } else {
                System.arraycopy(mNextBlock,mBytesWritten,data,0,length);
            }

            if ( mTio.isTraceEnabled() ) {
                STTrace.line("<< writing " + length + "  bytes (" + mBytesWritten + "," + mNextBlockSize + ")");
            }

            mLastBytesWritten = length;
            return data;
        }

        /**
         * Block successfully transmitted when status = 0. Update current transfer and signal when completed.
         * @param status of write operation
         * @return true if we have more to send.
         */
        boolean update(int status) {

            boolean moreToSent = true;

            if ( status == 0) {

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line(" update  (" + (mBytesWritten+mLastBytesWritten) + "," + mNextBlockSize + ") q("+size()+")");
                }

                boolean signalComplete = false;
                int     size           = 0;

                synchronized (mWriteLock) {
                    mBytesWritten += mLastBytesWritten;
                    if (mBytesWritten >= mNextBlockSize) {
                        size           = mNextBlockSize;
                        mNextBlock     = null;
                        mNextBlockSize = 0;
                        signalComplete = true;
                        mTxCount++;

                        // more to sent when we have someting more in our queue
                        moreToSent = ! isEmpty();
                    }
                }

                if ( signalComplete ) {
                    mListener.onTransmitCompleted(0, size);
                }

            } else {
                synchronized (mWriteLock) {
                    mNextBlock     = null;
                    mNextBlockSize = 0;
                }

                // TX error, we stop sending of data
                moreToSent = false;
                mListener.onTransmitCompleted(status,0);
            }

            return moreToSent;
        }


        /**
         * Register new special value for data transfer operations.
         * @param value
         */
        void setRemoteCharacteristicSize(int value) {
            mRemoteCharacteristicSize = value;
        }

        /**
         * Set all internals to standard values.
         */
        private void reset() {
            mTxCount                  = 0;
            mNextBlock                = null;
            mRemoteCharacteristicSize = 0;
            mBytesWritten             = 0;
            mNextBlockSize            = 0;
            mLastBytesWritten         = 0;
        }
    }


    TIOConnectionImpl(TIOPeripheralImpl peripheral,TIOConnectionCallback listener) {
        mListener   = listener;
        mPeripheral = peripheral;

        create(peripheral.getDevice(), peripheral.getApplicationContext());
    }

    protected TIOConnectionImpl(BluetoothDevice device, Context context) {
        mListener   = null;
        mPeripheral = null;

        create(device, context);
    }

    private void create(BluetoothDevice device, Context context) {
        mTio                 = TIOManager.getInstance();
        mDevice              = device;
        mApplicationContext  = context;
        mInstanceId          = ++mInstanceCount;
        mState               = ConnectionState.csDisconnected;
        mDeferrTimer         = new Timer();
        mDisconnectWatch     = new Timer();
        mReconnectWatch      = new Timer();
        mWriteTrigger        = new Semaphore(256, true);
        mBondingReceiver     = new BondingReceiver();
        mPairingReceiver     = new PairingReceiver();
        mAclDisconnectedReceiver = new AclDisconnectedReceiver();
        mAclDisconnectedReceiver = new AclDisconnectedReceiver();
        mAddress                 = device.getAddress();
        mWriteTrigger.drainPermits();
        mFifo                = new TransmitFifo(new TransmitCompletedListener() {
            @Override
            public void onTransmitCompleted(int status, int bytesWritten) {
                signalDataTransmitted( status, bytesWritten);
            }
        });

        String aVersion     = RELEASE;
		if ( aVersion.charAt(0) == '4' ) {
            mIsAndroid4 = true;
        }
		mAndroidVersionMain = aVersion.charAt(0) - 48;

        mApplicationContext.registerReceiver(mBondingReceiver, new IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED));

        mApplicationContext.registerReceiver(mPairingReceiver, new IntentFilter(BluetoothDevice.ACTION_PAIRING_REQUEST));
        mApplicationContext.registerReceiver(mAclDisconnectedReceiver, new IntentFilter(BluetoothDevice.ACTION_ACL_DISCONNECTED));

        onHandleConnectionState(ConnectionState.csConnectPending);
    }

    @Override
    public void setListener(TIOConnectionCallback listener) {
        mListener = listener;
    }

    @Override
    public int getRemoteMtuSize() { return mRemoteUartMtuSize; }

    @Override
    public int getLocalMtuSize() { return mLocalUartMtuSize; }

    /** --------------------------------------------------------------------------------------------
     * Disconnects an established connection, or cancels a connection attempt currently in progress.
     *
     * ----------------------------------------------------------------------------------------- */
    @Override
    public void disconnect() throws IOException {

        if ( mTio.isTraceEnabled() ) {
            STTrace.method("disconnect for #" + mInstanceId);
        }

        if ( (mState == ConnectionState.csDisconnected)||(mState==ConnectionState.csDisconnectPending)) {
            throw new IOException("! neither connected nor connecting...");
        }

        onHandleConnectionState(ConnectionState.csDisconnectPending);
    }

    @Override
    public void cancel() throws IOException {
        STTrace.method("cancel for #" + mInstanceId);

        if ( (mState == ConnectionState.csDisconnected)||(mState==ConnectionState.csDisconnectPending)) {
            throw new IOException("! neither connected nor connecting...");
        }

        if(mReconnectRequested) {
            mReconnectWatch.cancel();
            mReconnectRequested = false;
        }

        onHandleConnectionState(ConnectionState.csDisconnected);
    }

    @Override
    public void clear() {
        try {
            mReconnectWatch.cancel();
            mReconnectWatch = null;
            mReconnectRequested = false;
        } catch (RuntimeException ex) {
          ex.printStackTrace();
        }
        try {
            reset();
        } catch (RuntimeException ex) {
            ex.printStackTrace();
        }
    }

    /** --------------------------------------------------------------------------------------------
     *
     * @param delay
     * @throws IOException
     * ----------------------------------------------------------------------------------------- */
    @Override
    public void readRemoteRssi(int delay) throws IOException {

        if ( delay == 0) {
            // stop running RSSI process
            mRssiDelay = 0;
            if(mRssiTimer != null) mRssiTimer.cancel();
        } else {

            if ( mState != ConnectionState.csConnected) {
                throw new IOException("! not connected");
            }

            if ( delay < RSSI_DEFERRAL_INTERVAL ) {
                if ( mTio.isTraceEnabled() ) {
                    STTrace.error("RSSI delay too small, use standard");
                }

                mRssiDelay = RSSI_DEFERRAL_INTERVAL;
            } else {
                mRssiDelay = delay;
            }

            if ( mRssiPending ) {
                // Android BLE stack is not ready to handle a new readRemoteRSSI request,
                // so we transmit the last known value here...
                signalRssi(0,mLastRssi);
            } else if ( mGatt != null) {
                // TODO check if synchronize with transmit is required
                mRssiPending = true;
                mGatt.readRemoteRssi();
            }
        }
    }


    /** ---------------------------------------------------------------------------------------------
     *  Writes data to the remote device. Requires the peripheral to be TerminalIO connected.
     *
     *  The specified data will be appended to a write queue, so there is generally no limitation for
     *  the data's size except for memory conditions within the operating system.
     *  Nevertheless, data sizes should be considered carefully and transmission rates and power
     *  consumption should be taken into account.
     *
     *  For each data block written, the TIOPeripheralCallback method {@link TIOConnectionCallback#onDataTransmitted(TIOConnection, int,int)
     *  onTransmitCompleted()} will be invoked reporting the number of bytes written and the status.
     *
     *  @param data Data to be written.
    --------------------------------------------------------------------------------------------- */
    @Override
    public void transmit(byte[] data) throws IOException {

        if ( mTio.isTraceEnabled() ) {
            STTrace.method("transmit, length " + data.length + "("+mFifo.size()+")" );
        }

        if ( data == null) {
            throw new NullPointerException();
        }

        if ( data.length == 0) {
            throw new IllegalArgumentException("! Data length cannot be 0");
        }


        if ( mState != ConnectionState.csConnected )
        {
            throw new IOException("! Peripheral is not connected...");
        }

        addTransmitJob(data);
    }

    /** ---------------------------------------------------------------------------------------------
     *  Returns the peripheral instance for this TIOConnection
     * @return
     * ----------------------------------------------------------------------------------------- */
    @Override
    public TIOPeripheral  getPeripheral() {
        return (TIOPeripheral) mPeripheral;
    }

    /** ---------------------------------------------------------------------------------------------
     * Returns current connection state
     * @return
     * ----------------------------------------------------------------------------------------- */
    @Override
    public int  getConnectionState() {
        int state;

        // we translate our internal state to known application state
        switch ( mState ) {
            case csDisconnected:
                state = STATE_DISCONNECTED;
                break;

            case csConnected:
                state = STATE_CONNECTED;
                break;

            case csDisconnectPending:
                state = STATE_DISCONNECTING;
                break;

            default:
                state = STATE_CONNECTING;
                break;
        }

        return state;
    }


    /*
     * Add new data to our transmit fifo and start TRANSMIT thread when not running. For processing
     * trigger our TX semaphore.
     * @param data
     */
    private void addTransmitJob(byte [] data) {

        if ( mWriteThread == null ) {
            mWriteThread = new Thread( new Runnable() {
                @Override
                public void run() {
                    writeThread();
                }
            });
            mWriteThread.start();
        }

        synchronized (mWriteLock) {
            mFifo.add(data);
        }

        triggerTransmit();
    }

    /*
     * Trigger TX semaphore for processing
     */
    private void triggerTransmit() {
        // STTrace.line("  trigger TX " );
        mWriteTrigger.release();
    }

    /*
     * Connection state machine. This controls the whole connection process step by step.
     * @param nextState
     */
    private void onHandleConnectionState(ConnectionState nextState) {

        ConnectionState oldState = mState;

        if ( mTio.isTraceEnabled() ) {
            STTrace.line("## " + mInstanceCount + " onHandleConnectionState in state " + mState + " -> " + nextState);
        }

        mState = nextState;
        switch ( mState ) {
            case csConnectPending:
                if ( mCallCount >= 5) {
                    signalConnectFailed("! Too many call retries");
                    return;
                }

                // first we need to establish a BLE connection, we track the time for each step
                startRunTime();
                mGatt      = mDevice.connectGatt( mApplicationContext, false, new GattListener());
                if ( mGatt == null ) {
                    mState = ConnectionState.csDisconnected;
                    signalConnectFailed("! cannot create GATT instance");
                }
                else {
                    mCallCount++;
                    if ( mTio.isTraceEnabled() ) {
                        STTrace.line("New GATT instance created, connect pending ("+mCallCount+")" );
                    }
                }
                break;

            case csGattConnected:
                // reset local credits number
                mLocalCredits = 0;

                // reset mtu sizes
                mRemoteUartMtuSize = MAX_TX_DATA_SIZE;
                mLocalUartMtuSize  = MAX_TX_DATA_SIZE;
                mPendingLocalUartMtuSize = 0;

                // discover all services and characteristics
                discoverServicesAndCharacteristics();
                break;

            case csDisconnected:
                // reset mtu sizes
                mRemoteUartMtuSize = MAX_TX_DATA_SIZE;
                mLocalUartMtuSize  = MAX_TX_DATA_SIZE;
                mPendingLocalUartMtuSize = 0;

                // inform upper layer
                signalRemoteMtu(mRemoteUartMtuSize);
                signalLocalMtu(mLocalUartMtuSize);

              //  mApplicationContext.unregisterReceiver(mBondingReceiver);
              //  mApplicationContext.unregisterReceiver( mPairingReceiver );

                if (mBondingReceiver != null) {
                    try {
                        mApplicationContext.unregisterReceiver(mBondingReceiver);
                    } catch (Exception ex) {
                        // we expect an exception if the bonding receiver has already been unregistered, see onDescriptorWrite()
                    }
                }
                if (mPairingReceiver != null) {
                    try {
                        mApplicationContext.unregisterReceiver(mPairingReceiver);
                    } catch (Exception ex) {
                        // we expect an exception if the mPairingReceiver has already been unregistered, see onDescriptorWrite()
                    }
                }

                try {
                    if(mRssiTimer != null) mRssiTimer.cancel();
                } catch (Exception ex) { }

                try {
                    mGatt.close();
                    mGatt = null;
                } catch (Exception ex) { }

                if ( oldState != ConnectionState.csDisconnectPending ) {
                    mState = ConnectionState.csIdle;
                    signalDisconnected(getErrorMessage(mLastStatus));
                } else {
                    if ( mTio.isTraceEnabled() ) {
                        STTrace.line("Wait for ACL_DISCONNECT before signaling, start 500 ms watch dog");
                    }

                    //  We saw sometimes problems to receive this events, so better start a
                    // a watchdog

                    try {
                        mDisconnectWatch.schedule(new TimerTask() {
                            @Override
                            public void run() {
                                mState = ConnectionState.csIdle;
                                signalDisconnected(getErrorMessage(mLastStatus));
                            }
                        }, 500);
                    }
                    catch(Exception ex) {
                    }

                }
                break;

            case csSetMtu:
                discoverServicesAndCharacteristics();
                break;

            case csServicesDiscovered:
                if ( oldState == ConnectionState.csConnectPending) {
                    // We saw this race in traces ...
                    mState = ConnectionState.csConnectPending;
                    break;
                }

                // Check if UART TX MTU notification subscription is required.
                if ((mTxMtuCharacteristic != null) && (!mTxMtuSubscribed)) {
                    if ( ! subscribeTxMtu() ) {
                        handleConnectionError(true, "Subscribe to TX MTU failed");
                    } else {
                        break;
                    }
                }

                if ( mTxCreditsSubscribed ) {
                    onHandleConnectionState(ConnectionState.csTxCreditsSubscribed);
                } else {
                    if ( ! subscribeTxCredits() ) {
                        handleConnectionError(true, "Subscribe to TX credits failed");
                    }
                }

                break;

            case csTxCreditsSubscribed:// UART TX credits notification subscription is required.
                if ( mTxSubscribed ) {
                    onHandleConnectionState(ConnectionState.csTxSubscribed);
                } else {
                    if ( ! subscribeTx() ) {
                        handleConnectionError( true, "Subscribe to TX failed");
                    } 
                }
                break;

            case csTxSubscribed:				// UART TX data notification subscription is required.
                mTxCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
                //
                // UART RX credits have to be granted to the peripheral in order to establish the
                // TerminalIO connection
                //

                if(mPendingLocalUartMtuSize != 0) {
                    if ( ! grantLocalMtu() ) {
                        handleConnectionError( true, "Grant local rx mtu failed");
                    }
                }else if ( ! grantLocalCredits() ) {
                    handleConnectionError( true, "Grant local rx credits failed");
                }
                break;


            case csGrantCredits:

            case csConnected:
                // set appropriate write mode for characteristics
                mTxCreditsCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
                mTxCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);

                // TIO connection has been established
                signalConnected();
                break;

            case csDisconnectPending:
            case csCallFailed:
                if ( mGatt != null) {
                    mGatt.disconnect();
                }
                break;

            case csWaitTxCredits:   // just wait here only for onCharacteristicChanged()
                break;

            case csPairingRequest:
                break;

            case csCallRetry:
                if ( mGatt != null) {
                    mGatt.disconnect();
                    mGatt.close();
                    mGatt = null;
                }
                mIsCallRetry = true;
                onHandleConnectionState(ConnectionState.csConnectPending);
                break;
        }
    }

    /*
     * For Android version >= 5.0 we can change the MTU size for this connection
     */

    // @TargetApi(21)
    private void changeMTU() {
        /*
        mGatt.requestMtu(118);
        */
        discoverServicesAndCharacteristics();
    }


    /*
     * Something during TIO session establishment is wrong. Disconnect low level GATT and signal
     * failed call.
     * @param disconnectRequired
     * @param message
     */
    private void handleConnectionError(boolean disconnectRequired, String message) {

        STTrace.error("handleConnectionError " + message);

        if (disconnectRequired) {
            onHandleConnectionState(ConnectionState.csCallFailed);
        } else {
            reset();
        }

        signalConnectFailed(message);
    }

    /*
     * Disconnect from remote during normal csConnected state
     * @param message
     */
    private void handleDisconnect(String message) {

        if ( mTio.isTraceEnabled() ) {
            STTrace.method("handleDisconnect");
        }

        reset();

        if (mBondingReceiver != null) {
            try {
                mApplicationContext.unregisterReceiver(mBondingReceiver);
            } catch (Exception ex) {
                // we expect an exception if the bonding receiver has already been unregistered, see onDescriptorWrite()
            }
        }

        signalDisconnected(message);
    }

    private void reset() throws RuntimeException {
        mState                    = ConnectionState.csDisconnected;
        mLocalCredits             = 0;
        mRemoteCredits            = 0;
        mLocalCredits             = 0;

        mGatt.close();
        mGatt                    = null;
        mTxCharacteristic        = null;
        mTxCreditsCharacteristic = null;

        mTxMtuCharacteristic = null;
        mRxMtuCharacteristic = null;

        mMaxFrameSize      = MAX_TX_DATA_SIZE;
        mRemoteUartMtuSize = MAX_TX_DATA_SIZE;
        mLocalUartMtuSize  = MAX_TX_DATA_SIZE;
        mPendingLocalUartMtuSize = 0;
    }

    /* Next connection step after GATT is successfully connected. We discover the remote services
    */
    private boolean discoverServicesAndCharacteristics() {

        if ( mTio.isTraceEnabled() ) {
            STTrace.line("<< discoverServicesAndCharacteristics");
        }

        // erase invalid characteristics instances first
        mTxCharacteristic        = null;
        mTxCreditsCharacteristic = null;
        mTxMtuCharacteristic = null;
        mRxMtuCharacteristic = null;
        mLastTimeStamp           = new Date().getTime();
        return mGatt.discoverServices();
    }

    private boolean subscribeTx() {

        if ( mGatt == null) {
            return false;
        }

        if ( mTio.isTraceEnabled() ) {
                STTrace.line("<< Subscribe to TX characteristic " + mTxCharacteristic.getUuid().toString() );
        }

        mGatt.setCharacteristicNotification(mTxCharacteristic, true);

        mTxCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);

        BluetoothGattDescriptor descriptor = mTxCharacteristic.getDescriptor(CCC_BITS_UUID);

        descriptor.setValue(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE);

        if ( mGatt.writeDescriptor(descriptor) ) {
            mWriteCharacteristicPending++;
            return true;
        }

        return false;
    }

    /**
     * @return
     */
    private boolean subscribeTxCredits() {

        if ( mGatt == null) {
            return false;
        }

        if ( mTio.isTraceEnabled() ) {
            STTrace.line("<< Subscribe to TX CREDITS characteristic " + mTxCreditsCharacteristic.getUuid().toString() );
        }

        mGatt.setCharacteristicNotification(mTxCreditsCharacteristic, true);

        mTxCreditsCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);

        BluetoothGattDescriptor descriptor = mTxCreditsCharacteristic.getDescriptor(CCC_BITS_UUID);

        descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);

        startRunTime();
        if ( mGatt.writeDescriptor(descriptor) ) {
            mWriteCharacteristicPending++;
            return true;
        }

        return false;
    }

    /**
     * @return
     */
    private boolean subscribeTxMtu() {

        if ( mGatt == null) {
            return false;
        }

        if ( mTio.isTraceEnabled() ) {
            STTrace.line("<< Subscribe to TX MTU characteristic " + mTxMtuCharacteristic.getUuid().toString() );
        }

        mGatt.setCharacteristicNotification(mTxMtuCharacteristic, true);

        mTxMtuCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);

        BluetoothGattDescriptor descriptor = mTxMtuCharacteristic.getDescriptor(CCC_BITS_UUID);

        descriptor.setValue(BluetoothGattDescriptor.ENABLE_INDICATION_VALUE);

        startRunTime();
        if ( mGatt.writeDescriptor(descriptor) ) {
            mWriteCharacteristicPending++;
            return true;
        }

        return false;
    }


    /**
     * Send the local RX credit information to remote
     * @return
     */
    private boolean grantLocalCredits() {
        int credits = mMaxLocalCredits - mLocalCredits;

        mLocalCredits += credits;

        if ( mTio.isTraceEnabled() ) {
//            STTrace.line("<< GrantLocalCredits  " + credits);
        }

        // Convert data into characteristic value
        byte[] value = new byte[] { (byte) (credits & 0xff) };

        // Set new characteristic value
        mRxCreditsCharacteristic.setValue(value);

        // We must access to GATT synchronize with other TX actions when write thread is active
        if ( mWriteThread != null ) {
           mWriteRx = true;

           triggerTransmit();
           return true;
        }

        startRunTime();
        return mGatt.writeCharacteristic(mRxCreditsCharacteristic);
    }


    /**
     * Send the local MTU size information to remote
     * @return
     */
    private boolean grantLocalMtu() {
        int mtuSize = mPendingLocalUartMtuSize;

        // Convert data into characteristic value
        byte[] value = new byte[2];
        value[1] = (byte) (mtuSize >> Byte.SIZE);
        value[0] = (byte)  mtuSize;

        // Set new characteristic value
        mRxMtuCharacteristic.setValue(value);

        startRunTime();
        return mGatt.writeCharacteristic(mRxMtuCharacteristic);
    }


    /** --------------------------------------------------------------------------------------
     * @param status
     * @return
     ----------------------------------------------------------------------------------------*/
    protected String getErrorMessage(int status) {
        String errorMessage = "";
        if (status != BluetoothGatt.GATT_SUCCESS) {
            errorMessage = "Android error# " + status;
        }
        return errorMessage;
    }

    private void onRxCredits(int status) {
        if (status == BluetoothGatt.GATT_SUCCESS) {
            //
            // granting of local credits to remote device was successful
            //
            if ( mState == ConnectionState.csTxSubscribed) {

                // we wait now normally for remote TX credits here, but some time it is
                // is possible that we have already this info

                if ( mRemoteCredits != 0 ) {
                    onHandleConnectionState(ConnectionState.csConnected);
                } else {
                    onHandleConnectionState(ConnectionState.csWaitTxCredits);
                }
            }

            signalLocalCredits(mLocalCredits);
        } else {
            //
            // granting of local credits failed, abort connection establisment
            //
            STTrace.error("error status " + status);

            if ( mState == ConnectionState.csTxSubscribed) {
                handleConnectionError(true, "Failed to grant initial UART credits; " + getErrorMessage(status));
            }
        }
    }

    /**
     * Our serialized write thread. Triggered from
     *    - Start a new TX cycle
     *    - One low level frame is transmitted
     *    - New credits info avail and before was a RNR situation
     */
    private void writeThread() {

        if ( mTio.isTraceEnabled() ) {
            STTrace.line("Enter write thread ...");
        }

        do
        {
            // Wait for the next write trigger.

            try {

                 {   mWriteTrigger.acquire(); }
            }
            catch (Exception ex) {
                STTrace.error("mWriteTrigger failed !!! +\n" + ex.toString() );
                break;
            }

            if ( mTio.isTraceEnabled() ) {
//                STTrace.line(" +++ mWrite Trigger + " + mRemoteCredits + " " + mIsWriting);
            }

            //
            // Check for some end condition
            //
            if ( mState != ConnectionState.csConnected)
            {
                mIsWriting = false;
                break;
            }

            //
            //  A characteristic write already pending, wait for completion trigger
            //
            if (  mIsWriting ) {
                continue;
            }

            //
            // We must insert writing of new "RX credits" into data stream since the lower
            // stack can handle only one pending request.
            //
            if ( mWriteRx ) {
                mIsWriting = true;
//                STTrace.line("writeThread mWriteRx" + Arrays.toString(mRxCreditsCharacteristic.getValue()));
                if ( ! mGatt.writeCharacteristic(mRxCreditsCharacteristic)) {
                    mIsWriting = false;
                }
                mWriteRx = false;
                continue;
            }

            if ( mFifo.isEmpty() ) {
                continue;
            }

            if (mRemoteCredits == 0)
            {
                // no more UART credits for remote device
                if ( mTio.isTraceEnabled() ) {
                    STTrace.line("No credits, RNR");
                }
                mIsWriting = false;
                continue;
            }


            //
            // Get next data block
            //
            byte[] data;

            synchronized (mWriteLock) {
                if (mRemoteUartMtuSize != mMaxFrameSize) {
                    data = mFifo.getNext(mRemoteUartMtuSize);
                } else {
                    data = mFifo.getNext(mMaxFrameSize);
                }
            }

            if ( data != null ) {
                // write data to TX UART characteristic without expecting a response

                mRxCharacteristic.setValue(data);
                mIsWriting = true;
                startRunTime();
                if ( ! mGatt.writeCharacteristic(mRxCharacteristic) ) {
                    // TODO what can we do here ??
                    mIsWriting = false;
                }
            } else {
                if ( mTio.isTraceEnabled() ) {
                    STTrace.line("no more tx data");
                }
            }

        } while (true);

        if ( mTio.isTraceEnabled() ) {
            STTrace.line("Exit write thread ...");
        }
    }


    /**
     * Data received from remote process them
     * @param rxData
     */
    void onDataReceived(final byte []  rxData) {

        mLocalCredits--;

        if ( mTio.isTraceEnabled() ) {
//            STTrace.line(">> onCharacteristicChanged, RX data "+rxData.length+" rx credits "+mLocalCredits + ", remote " + mRemoteCredits);
        }

        signalData( rxData );

        // by sending this data packet, the remote device has consumed one of the granted local credits

        signalLocalCredits(mLocalCredits);

        // check pending local UART MTU size
        if(mPendingLocalUartMtuSize != 0) {
            if(mLocalCredits == 0) {
                // grant local UART MTU size
                grantLocalMtu();
            }
        } else if (mLocalCredits <= mMinLocalCredits)  {
            // grant a reasonable amount of new credits before an underrun occurs on the remote device
            grantLocalCredits();
        }
    }

    /**
     * The remote device has granted additional credits, extract credits count from characteristic value
     * @param data
     */
    void onRemoteCreditNotification(byte [] data){

        byte creditCount = mTxCreditsCharacteristic.getValue()[0];

        if ( mTio.isTraceEnabled() ) {
            STTrace.line(">> #"+mInstanceId+" EVENT onCharacteristicChanged, tx credit count " + creditCount);
        }

        // add received credits to counter taking care of write thread safety

        // We check for Receiver NOT READY condition before. In this case we must retrigger
        // our 'suspended' write thread

        boolean rnrBefore;

        rnrBefore = mRemoteCredits <= 0;

        mRemoteCredits += creditCount;
        if (mRemoteCredits > MAX_RX_CREDITS_COUNT)
        {
            STTrace.error("invalid remote UART credit count " + mRemoteCredits);
            mRemoteCredits = MAX_RX_CREDITS_COUNT;
        }

        if ( mState == ConnectionState.csWaitTxCredits ) {

            // Now we have all information and can enter connected state

            onHandleConnectionState(ConnectionState.csConnected);

            signalRemoteCredits(mRemoteCredits);

        } else if ( mState == ConnectionState.csConnected) {

            signalRemoteCredits(mRemoteCredits);

            if ( rnrBefore ) {

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line("RR again, signal thread, new credits for TX = " + mRemoteCredits);
                }

                triggerTransmit();
            }
        }
    }

    /**
     * The remote device has provided UART MTU size
     * @param data
     */
    void onRemoteMtuNotification(byte [] data){
        int mtuSize = 0;

        // extract UART MTU size from characteristic value
        mtuSize |=  data[1] << (Byte.SIZE * 1);
        mtuSize |= (data[0] & 0xFF);

        if ( mTio.isTraceEnabled() ) {
            STTrace.line(">> #"+mInstanceId+" EVENT onCharacteristicChanged, TX MTU size " + mtuSize);
        }

        // taking care of write thread safety
        synchronized (mWriteLock) {
            // set new UART MTU size
            mRemoteUartMtuSize = mtuSize;
            mPendingLocalUartMtuSize = mRemoteUartMtuSize;

            signalRemoteMtu(mRemoteUartMtuSize);
        }
    }

    /**
     * Local MTU size to remove device successfully transmitted.
     */
    void onRemoteWriteLocalMtuCompletion(int status) {
        if ( mState == ConnectionState.csTxSubscribed) {
            onHandleConnectionState(ConnectionState.csTxSubscribed);
        }

        mMaxFrameSize = mLocalUartMtuSize;
        mFifo.setRemoteCharacteristicSize(mLocalUartMtuSize);

        // notify upper layer
        signalLocalMtu(mLocalUartMtuSize);
    }

    /**
     * Data block to remove device successfully transmitted. Remote credit count is changed.
     * Update our TX fifo
     */
    void onRemoteWriteCompletion(int status) {
        // update remote credits

        synchronized (mWriteLock) {
            mRemoteCredits--;
        }

        // notify upper layer
        signalRemoteCredits(mRemoteCredits);

         if ( mFifo.update(status) )
         {
            // Ok more data exists, trigger next writing step when credits avail
             if ( mRemoteCredits > 0) {
                 mIsWriting = false;
                 triggerTransmit();
             }
             else {
                 STTrace.line("RNR wait for tx credits");
                 mIsWriting = false;
             }
        } else {
             mIsWriting = false;
        }

    }


    //******************************************************************************
    // BluetoothGattCallback implementation
    //******************************************************************************

    protected class GattListener extends BluetoothGattCallback {

        //-----------------------------------------------------------------------------------------
        //	Callback triggered as a result of a remote characteristic notification.
        //-----------------------------------------------------------------------------------------
        @Override
        public void onCharacteristicChanged(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic) {

            if (gatt != mGatt) {
                return;
            }

            if (characteristic.getUuid().equals(UART_TX_UUID)) {
                onDataReceived(characteristic.getValue());
            }
            else if (characteristic.getUuid().equals(UART_TX_CREDITS_UUID)) {
                onRemoteCreditNotification(characteristic.getValue());
            }
            else if (characteristic.getUuid().equals(UART_TX_MTU_UUID)) {
                onRemoteMtuNotification(characteristic.getValue());
            }
        }

        //-----------------------------------------------------------------------------------------
        //	Callback indicating the result of a characteristic write operation.
        //-----------------------------------------------------------------------------------------
        @Override
        public void onCharacteristicWrite(BluetoothGatt gatt, BluetoothGattCharacteristic characteristic, int status) {

            if (gatt != mGatt) {
                return;
            }

//            STTrace.line("characteristic written " + characteristic.getUuid().toString());


            mLastStatus = status;

            if (characteristic.getUuid().equals(UART_RX_CREDITS_UUID)) {

                if ( mTio.isTraceEnabled() ) {
//                    STTrace.line(">> #"+mInstanceId+" EVENT onCharacteristicWrite(RX) completed, status " + status + " ("+getRunTime()+" ms)");
                }

                onRxCredits(status);

                // When write thread is active we need a trigger to fetch normal TX
                if ( mWriteThread != null ) {

                    synchronized (mWriteLock) {
                        mIsWriting = false;
                    }

                    triggerTransmit();
                }

            } else if (characteristic.getUuid().equals(UART_RX_UUID)) {

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line(">> #"+mInstanceId+" EVENT onCharacteristicWrite(TX) completed, status " + status + " rc="+mRemoteCredits+ " ("+getRunTime()+" ms)");
                }

                onRemoteWriteCompletion(status);

            }
            else if (characteristic.getUuid().equals(UART_RX_MTU_UUID)) {
                // granting of local UART mtu size to remote device was successful

                mLocalUartMtuSize = mPendingLocalUartMtuSize;
                mPendingLocalUartMtuSize = 0;

                onRemoteWriteLocalMtuCompletion(status);

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line(">> #"+mInstanceId+" EVENT onCharacteristicWrite(RX MTU) completed, status " + status + " localMtu="+mLocalUartMtuSize+ " ("+getRunTime()+" ms)");
                }
            } else {
                STTrace.error("unknown characteristic written " + characteristic.getUuid().toString());
            }
        }

        /** ---------------------------------------------------------------------------------------------
         * Callback indicating when GATT client has connected/disconnected to/from a remote GATT server.
         * We have seen some strange behavior. Some CONNECT events with old deprecated GATT informations
         --------------------------------------------------------------------------------------------- */
        @Override
        public void onConnectionStateChange(BluetoothGatt gatt, int status, int newState) {

            if (gatt != mGatt) {
                return;
            }

            mLastStatus = status;
            switch (newState) {
                case BluetoothGatt.STATE_CONNECTED:
                    if (status != BluetoothGatt.GATT_SUCCESS) {

                        if ( mTio.isTraceEnabled() ) {
                            STTrace.line(">> #"+mInstanceId+" EVENT GATE_CONNECT_FAILED in " + mState);
                        }
                        handleConnectionError(false, getErrorMessage(status) );

                    } else {

                        if ( mTio.isTraceEnabled() ) {
                            STTrace.line(">> #"+mInstanceId+" EVENT GATE_CONNECT #" + mInstanceId + " in " + mState + "("+getRunTime()+" ms)");
                        }

                        if ( mState == ConnectionState.csConnectPending) {
                            if(mReconnectRequested) {
                                mReconnectWatch.cancel();
                                mReconnectRequested = false;
                            }
                            onHandleConnectionState( ConnectionState.csGattConnected);
                        }
                        else {
                            STTrace.error(" CONNECT in already connected state, ignore ");
                        }
                    }
                    break;

                case BluetoothGatt.STATE_DISCONNECTED:
                    if ( mState != ConnectionState.csDisconnected ) {

                        if ( mTio.isTraceEnabled() ) {
                            STTrace.line(">> #"+mInstanceId+" EVENT GATE_DISCONNECT in " + mState);
                        }

                        switch ( mState ) {
                            case csCallFailed:
                                mGatt.close();   // can we do this here ????
                                mGatt = null;

                                if ( mIsCallRetry ) {
                                    mIsCallRetry = false;
                                    onHandleConnectionState(ConnectionState.csConnectPending);
                                }
                                break;

                            case csServicesDiscovered:
                                if ( mAndroidVersionMain == 4 ) {

                                    // We assumes that just works security for Android 4 is not
                                    // working here when we have a local link key and remote
                                    // link key is deleted. Than we can have this szenario.

                                    if ( mTio.isTraceEnabled() ) {
                                        STTrace.line(" Start internal call retry for Android 4");
                                    }

                                    mGatt.close();
                                    onHandleConnectionState(ConnectionState.csConnectPending);
                                } else {
                                    onHandleConnectionState(ConnectionState.csDisconnected);
                                }
                                break;

                            case csConnectPending:
                                // Error code 133: try to make one re-connect in background mode
                                if(status == 133){
                                    if ((!mReconnectRequested) && mGatt.connect()) {
                                        // We saw sometimes problems if remote device not available at this time, so better start
                                        // a watchdog for 60 seconds
                                        mReconnectWatch.schedule(new TimerTask() {
                                            @Override
                                            public void run() {
                                                signalReconnectionFailed(getErrorMessage(mLastStatus));
                                            }
                                        }, 60000);

                                        mReconnectRequested = true;
                                        return;
                                    } else {
                                        mReconnectWatch.cancel();
                                        mReconnectRequested = false;
                                    }
                                }
                                onHandleConnectionState(ConnectionState.csDisconnected);
                                break;

                            default:
                                onHandleConnectionState(ConnectionState.csDisconnected);
                                break;
                        }

                    } else {
                        STTrace.error("! ignore GATE_DISCONNECT for #" + mInstanceId + " already in csDisconnect");
                    }
                    break;

                default:
                    break;
            }
        }

        //-----------------------------------------------------------------------------------------
        //	Callback indicating the result of a descriptor write operation.
        //-----------------------------------------------------------------------------------------
        @Override
        public void onDescriptorWrite(BluetoothGatt gatt, BluetoothGattDescriptor descriptor, int status) {

            if (gatt != mGatt) {
                STTrace.error("! onDescriptorWrite not our GATT instance");
                return;
            }

            BluetoothGattCharacteristic characteristic = descriptor.getCharacteristic();
            mLastStatus                 = status;
            mWriteCharacteristicPending--;

            if (status != BluetoothGatt.GATT_SUCCESS) {

                onDescriptorWriteFailed(characteristic, status);

            }
            else if (characteristic.getUuid().equals(UART_TX_UUID))	{

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line(">> EVENT onDescriptorWrite,  sucessfully subscribed to TX characteristic ("+getRunTime()+" ms)");
                }
                mTxSubscribed = true;
                onHandleConnectionState(ConnectionState.csTxSubscribed);
            }
            else if (characteristic.getUuid().equals(UART_TX_CREDITS_UUID)) {

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line(">> EVENT onDescriptorWrite,  sucessfully subscribed to TX CREDITS characteristic ("+getRunTime()+" ms)");
                }
                mTxCreditsSubscribed = true;
                onHandleConnectionState(ConnectionState.csTxCreditsSubscribed);
            }
            else if (characteristic.getUuid().equals(UART_TX_MTU_UUID)) {

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line(">> EVENT onDescriptorWrite,  sucessfully subscribed to TX MTU characteristic ("+getRunTime()+" ms)");
                }
                mTxMtuSubscribed = true;
                onHandleConnectionState(ConnectionState.csServicesDiscovered);
            }
        }

        //-----------------------------------------------------------------------------------------
        //	Callback reporting the RSSI for a remote device connection.
        //-----------------------------------------------------------------------------------------
        @Override
        public void onReadRemoteRssi(BluetoothGatt gatt, int rssi, int status) {

            if ( (gatt != mGatt) || (mGatt == null ) ) {
                return;
            }

            if ( mTio.isTraceEnabled() ) {
                STTrace.line(">> #"+mInstanceId+" EVENT onReadRemoteRssi "+ rssi);
            }

            mLastRssi    = rssi;
            mRssiPending = false;

            if ( mRssiDelay != 0) {

                // Indicates not cancelled before

                signalRssi(status,rssi);

                // Android BLE stack is not ready to handle a new readRemoteRSSI request before another approx.
                // 1000ms have passed, so we defer calls to readRemoteRSSI() accordingly
                mRssiTimer = new Timer();
                mRssiTimer.schedule(new TimerTask() {
                    @Override
                    public void run() {
                        try {
                            mRssiPending = true;
                            mGatt.readRemoteRssi();
                        }
                        catch (Exception ex)
                        {
                        }
                    }
                }, mRssiDelay);
            }
        }

        //-----------------------------------------------------------------------------------------
        //	Callback invoked when the list of remote services, characteristics and descriptors for
        // the remote device have been updated, ie new services have been discovered.
        //-----------------------------------------------------------------------------------------
        @Override
        public void onServicesDiscovered(BluetoothGatt gatt, int status) {

            // Track duration for service discovery to detect cached infos ...

            long  duration = System.currentTimeMillis() - mLastTimeStamp;
            if (gatt != mGatt) {
               return;
            }

            if ( mTio.isTraceEnabled() ) {
                STTrace.line(">> EVENT onServicesDiscovered status " + status + " ("+duration+" ms)");
            }

            if ( status != 0) {
                if ( mIsAndroid4 && (status == 129)) { // && (duration < 500) ) {
                    //
                    // The call terminates very earlier with an error. So it seems Android 4
                    // has problems with internally cached information. This is BUG, than no real
                    // discovery on remote device is performed.

                    STTrace.line(" Perform call retry, something seems wrong with chached BT info in Android 4");
                    mIsCallRetry = true;
                    onHandleConnectionState(ConnectionState.csCallFailed);
                } else {
                    handleConnectionError(true, "TIO service not discovered, status "+status);
                }
                return;
            }

            mGattService             = null;
            mTxCharacteristic        = null;
            mTxCreditsCharacteristic = null;
            mTxMtuCharacteristic = null;
            mRxMtuCharacteristic = null;
            mState                   = ConnectionState.csServicesDiscovered;

            if ( mTio.isTraceEnabled() ) {
                STTrace.line(" found " + mGatt.getServices().size() + " services");
            }

            for (BluetoothGattService service: mGatt.getServices()) {

                if ( mTio.isTraceEnabled() ) {
                    STTrace.line("    - service " + service.getUuid().toString());
                }

                if (service.getUuid().equals(TIO_SERVICE_UUID)) {
                    // memorize Android service instance
                    mGattService = service;

                    for (BluetoothGattCharacteristic characteristic: service.getCharacteristics()) {

                        if (characteristic.getUuid().equals(UART_TX_CREDITS_UUID)) {

                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("       'TxCredits' characteristic " + characteristic.getUuid().toString() +
                                                     "; properties = " + characteristic.getProperties() +
                                                     "; permissions = " + characteristic.getPermissions());
                            }
                            // memorize Android characteristic instance
                            mTxCreditsCharacteristic = characteristic;
                        }
                        else if (characteristic.getUuid().equals(UART_TX_UUID)) {

                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("       'Tx' characteristic " + characteristic.getUuid().toString() +
                                                    "; properties = " + characteristic.getProperties() +
                                                    "; permissions = " + characteristic.getPermissions());
                            }
                            // memorize Android characteristic instance
                            mTxCharacteristic = characteristic;
                        }
                        else if (characteristic.getUuid().equals(UART_RX_CREDITS_UUID)) {

                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("       'RxCredits' characteristic " + characteristic.getUuid().toString() +
                                                   "; properties = " + characteristic.getProperties() +
                                                   "; permissions = " + characteristic.getPermissions());
                            }

                            // memorize Android characteristic instance
                            mRxCreditsCharacteristic = characteristic;
                        }
                        else if (characteristic.getUuid().equals(UART_RX_UUID)) {

                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("       'Rx' characteristic " + characteristic.getUuid().toString() +
                                                    "; properties = " + characteristic.getProperties() +
                                                    "; permissions = " + characteristic.getPermissions());
                            }
                            // memorize Android characteristic instance
                            mRxCharacteristic  = characteristic;
                            // set write mode without response for UART characteristic
                            mRxCharacteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
                        }
                        else if (characteristic.getUuid().equals(UART_TX_MTU_UUID)) {

                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("       'MTU Tx' characteristic " + characteristic.getUuid().toString() +
                                        "; properties = " + characteristic.getProperties() +
                                        "; permissions = " + characteristic.getPermissions());
                            }
                            // memorize Android characteristic instance
                            mTxMtuCharacteristic = characteristic;
                        }
                        else if (characteristic.getUuid().equals(UART_RX_MTU_UUID)) {

                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("       'MTU Rx' characteristic " + characteristic.getUuid().toString() +
                                        "; properties = " + characteristic.getProperties() +
                                        "; permissions = " + characteristic.getPermissions());
                            }
                            // memorize Android characteristic instance
                            mRxMtuCharacteristic = characteristic;
                        }

                        if ( mTio.isTraceEnabled() ) {
                            for (BluetoothGattDescriptor descriptor : characteristic.getDescriptors()) {
                                STTrace.line("            descriptor " + descriptor.getUuid().toString());
                            }
                        }
                    }
                }
            }

            if ( mGattService == null) {
                // the remote module does not provide the TIO service (should not occur...)
                handleConnectionError(true, "TIO service not discovered.");
            }
            else  if ( mTxCharacteristic == null || mTxCreditsCharacteristic == null  || mRxCharacteristic == null || mRxCreditsCharacteristic == null) {
                // the remote module does not provide mandatory TIO characteristics (should not occur...)
                handleConnectionError(true, "TIO characteristics missing.");
            }
            else {
                // TIO service and characteristics have been discovered; proceed with next step in TIO connection establishment

                //onHandleConnectionState(ConnectionState.csServicesDiscovered);

                // With security we saw that the second connection after bonding failes when we
                // process next actions without delay. Security manager in Android needs some time
                // to start up and when the discovery info is taken from cache and bluetooth is
                // turned on and this is the first connection.
                // Here is a  bug in Android Bluetooth  stack than establish a establishing an
                // encrpyted secure channel cost time. Android knows that pairing exits and needed
                // for this remote device but sent the indication for established connection
                // to earlier. Discovery info is taken from cache.

                // So in the result we must delay all actions here to bypass this error.
                // when we detect a bond state for the device.

                if ( mDevice.getBondState() != BluetoothDevice.BOND_NONE) {

                    // Cache service discovery info has a small duration until completed
                    duration = (duration > 150) ? 20 : 700;

                    if (mTio.isTraceEnabled()) {
                        STTrace.line("Device already bonded, wait "+ duration+" ms to get encryption start a chance");
                    }

                    mDeferrTimer.schedule(new TimerTask() {
                        @Override
                        public void run() {
                            onHandleConnectionState(ConnectionState.csServicesDiscovered);
                        }
                    }, duration);

                } else {
                    // It seems that we have no bonding, so we can process without delay

                    if (mTio.isTraceEnabled()) {
                        STTrace.line("Device not bonded, process immediatly");
                    }

                    onHandleConnectionState(ConnectionState.csServicesDiscovered);
                }


            }
        }


        //-----------------------------------------------------------------------------------------
        //
        //-----------------------------------------------------------------------------------------
        public void onDescriptorWriteFailed(BluetoothGattCharacteristic characteristic, int status) {


            if ( mTio.isTraceEnabled() ) {
                if (status == 5) {// GATT_INSUFFICIENT_AUTHENTICATION )
                    STTrace.error(">> !! onDescriptorWriteFailed(+"+mWriteCharacteristicPending+"),  status " + status + " (GATT_INSUFFICIENT_AUTHENTICATION), wait for bonding event ("+getRunTime()+" ms)");
                } else {
                    STTrace.error(">> !! onDescriptorWriteFailed ("+mWriteCharacteristicPending+"),  status " + status+ "("+getRunTime()+" ms)");
                }
            }

            mLastStatus = status;

            if ( characteristic.getUuid().equals(UART_TX_CREDITS_UUID) ) {
                mTxCreditsSubscribed    = false;

               // if (Build.VERSION.SDK_INT < 5.0) {

                 if ( status == 133 ) {

                    if ( mState == ConnectionState.csPairingRequest) {
                        if ( mTio.isTraceEnabled() ) {
                            STTrace.error("Retry subscribe TX credits");
                        }
                        onHandleConnectionState(ConnectionState.csServicesDiscovered);
                    } else {

                        if ( mAndroidVersionMain > 4 ) {
                            handleConnectionError(true, "Cannot subscribe TX credits, Bluedroid error 133 (BTA_GATT_ERROR)");
                        } else if  ( mIsAndroid4 ) {

                            if ( mWriteCharacteristicPending  == 0) {
                                if (mTio.isTraceEnabled()) {
                                    STTrace.error("wait for bonding, but here is a BUG in Android 4.x and disconnect follows");
                                }
                                // We knows that Android is not able to resolve such situations. we expects a later
                                // a disconnect here

                            } else {
                                if (mTio.isTraceEnabled()) {
                                    STTrace.error("It seems  a BUG in Android 4.x, we try a call retry");
                                }

                                mIsCallRetry = true;
                                onHandleConnectionState(ConnectionState.csCallFailed);
                            }
                        }
                    }
                }

            } else if (characteristic.getUuid().equals(UART_TX_MTU_UUID)) {
                mTxMtuSubscribed = false;

                if ( status == 133 ) {
                    handleConnectionError(true, "Cannot subscribe TX MTU, Bluedroid error 133 (BTA_GATT_ERROR)");
                }
            }
        }

        /*  Only valid for Android SDK >= 21
        @Override
        public void onMtuChanged(BluetoothGatt gatt, int mtu, int status) {

            if (gatt != mGatt) {
                return;
            }

            if ( mTio.isTraceEnabled() ) {
                STTrace.line("onMtuChanged, status " + status + " mtu="+mtu);
            }

            if ( status == 0) {
                mMaxFrameSize = mtu - 3;
            }
            onHandleConnectionState(ConnectionState.csSetMtu);
        }
       */
    }



    //-----------------------------------------------------------------------------------------
    // Signal Callback events
    //-----------------------------------------------------------------------------------------

    protected void runSignal(Runnable proc) {
        if ( mListener != null) {
            if (mListener instanceof Activity) {
                ((Activity) mListener).runOnUiThread(proc);
            } else {
                new Thread(proc).start();
            }
        }
    }


    /**
     * Signal established TIO session
     */
    protected void signalConnected() {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                mListener.onConnected(TIOConnectionImpl.this);
            }
        };
        runSignal(runnable);
    }

    /**
     * Signal TIO session establishment failed
     * @param message - Error message string
     */
    protected void signalConnectFailed(final String message) {

        mPeripheral.onDisconnect();
        Runnable runnable = new Runnable() {
           @Override
           public void run() {
               mListener.onConnectFailed(TIOConnectionImpl.this, message);
           }
        };
        runSignal(runnable);
    }

    /**
     * Signal that connection TIO session is now disconnected
     * @param message  Error message
     */
    protected void signalDisconnected(final String message) {
        mFifo.clear();

        mPeripheral.onDisconnect();
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                mListener.onDisconnected(TIOConnectionImpl.this, message);
            }
        };
        runSignal(runnable);
    }

    /**
     * Signal that re-connection to a remote device failed
     * @param message  Error message
     */
    protected void signalReconnectionFailed(final String message) {
        STTrace.line(">> -----------------------------------------------------------------");
        STTrace.line("Status " + message);
        STTrace.line(">> -----------------------------------------------------------------");
        onHandleConnectionState(ConnectionState.csDisconnected);
    }

    /**
     * Signal received data for this session
     * @param data The data block received
     */
    protected void signalData(final byte[] data) {
        mListener.onDataReceived(TIOConnectionImpl.this, data);
//
//        Runnable runnable = new Runnable() {
//            @Override
//            public void run() {
//                mListener.onDataReceived(TIOConnectionImpl.this, data);
//            }
//        };
//        runSignal(runnable);
    }

    /**
     * Signal that last transmit is completed
     * @param status  Status of transmit operation
     * @param bytesWritten The number of bytes written from last block
     */
    protected void signalDataTransmitted(final int status, final int bytesWritten) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                mListener.onDataTransmitted(TIOConnectionImpl.this, status, bytesWritten);
            }
        };
        runSignal(runnable);
    }

    /**
     * Signals RSSI information
     * @param status
     * @param rssi
     */
    protected void signalRssi(final int status,final int rssi) {
        Runnable runnable = new Runnable() {
            @Override
            public void run() {
                mListener.onReadRemoteRssi(TIOConnectionImpl.this, status, rssi);
            }
        };
        runSignal(runnable);
    }

    protected void signalLocalCredits(final int creditsCount) {
        // TODO add credits listener when real required this feature
    }

    protected void signalRemoteCredits(final int creditsCount) {
        // TODO add credits listener when real required this feature
    }

    protected void signalLocalMtu(final int localMtuSize) {
        // TODO add credits listener when real required this feature
    }

    protected void signalRemoteMtu(final int remoteMtuSize) {
        // TODO add credits listener when real required this feature
    }

    long getRunTime() {
        return System.currentTimeMillis() - mStartTime;
    }

    long startRunTime() {
        mStartTime = System.currentTimeMillis();
        return mStartTime;
    }


    /*
     * Track the bonding process to start connection state machine again when required
     */
    private class BondingReceiver extends  BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

            BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

            if ( (mGatt == null) || (device == null) ) {
                return;
            }

            if ( ! device.getAddress().equals(mGatt.getDevice().getAddress())) {
                return;
            }

            int bondState         = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, -1);
            int previousBondState = intent.getIntExtra(BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE, -1);

            if ( mTio.isTraceEnabled() ) {
                STTrace.line(">> -----------------------------------------------------------------");
                STTrace.line(">> Bonding intent, bond state " + previousBondState + " -> " + bondState+ " in state "+mState);
                STTrace.line(">> -----------------------------------------------------------------");
            }

            if (bondState == BluetoothDevice.BOND_BONDED) {

                //
                // Successfully Bonding completed, check current state and Android version for
                // next actions
                //

                switch ( mState ) {
                    case csPairingRequest:
                        //
                        // PIN input dialog and bonding was successfully
                        //
                        if (mTio.isTraceEnabled()) {
                            STTrace.line("Successfully paired/bonded");
                        }

                        if ( mWriteCharacteristicPending != 0) {
                            if (mTio.isTraceEnabled()) {

                                if (mIsAndroid4) {
                                    STTrace.line("wait for outstandig negative completion");
                                } else {
                                    STTrace.line("wait for outstandig completion");
                                }
                            }
                        }
                        break;

                    case csServicesDiscovered:
                        //
                        // This is for just works security without PIN exchange
                        //
                        if ( mWriteCharacteristicPending == 0) {
                            // Negative completion already received. We must subscribe again


                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("Successfully bonded, restart connection state machine");
                            }
                            onHandleConnectionState(ConnectionState.csServicesDiscovered);
                        } else {
                            if ( mTio.isTraceEnabled() ) {
                                STTrace.line("Successfully bonded, but missing completion proc");

                                if ( mAndroidVersionMain == 5 ) {
                                    STTrace.line("! here seems a bug in Android 5, so later local disconnect cannot real shutdown the remote bluetooth link");
                                    STTrace.line("! in this case ACL_DISCONNECT is missing");
                                }
                            }

                            if ( mAndroidVersionMain > 4 ) {

                                mDeferrTimer.schedule(new TimerTask() {
                                    @Override
                                    public void run() {
                                        onHandleConnectionState(ConnectionState.csServicesDiscovered);
                                    }
                                }, 100);
                            }
                        }
                        break;
                }



            }
        }
    };

    /*
     * Track the bonding process to enter new state for connection state machine
     */
    private class PairingReceiver extends  BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

            BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

            if ( (mGatt == null) || (device == null) ) {
                return;
            }

            if (! device.getAddress().equals(mGatt.getDevice().getAddress())) {
                return;
            }

            if ( mTio.isTraceEnabled() ) {
                STTrace.line(">> ----------------------------------------");
                STTrace.line(">> Receive PAIRING request, start activity ");
                STTrace.line(">> ----------------------------------------");
            }

            onHandleConnectionState(ConnectionState.csPairingRequest);

            // We assumes that the system starts this activity, we track only this state,
            // but sometime (everytime ?) this activity is not started in foreground.

            // mApplicationContext.startActivity( intent );
        }
    };

    /*
     * Track the bonding process to enter new state for connection state machine
     */
    private class AclDisconnectedReceiver extends  BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

            BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

            if ( device == null ) {
                return;
            }

            if (! device.getAddress().equals(mAddress))  {
                return;
            }

            try {
                mDisconnectWatch.cancel();
            }
            catch(Exception ex) {
            }

            if ( mTio.isTraceEnabled() ) {
                STTrace.line(">> #"+mInstanceId+" ACL Disconnected in state "+mState);
            }

            if ( mState == ConnectionState.csDisconnected ) {
                mState = ConnectionState.csIdle;
               // mApplicationContext.unregisterReceiver( mAclDisconnectedReceiver );

                if (mAclDisconnectedReceiver != null) {
                    try {
                        mApplicationContext.unregisterReceiver(mAclDisconnectedReceiver);
                    } catch (Exception ex) {
                        // we expect an exception if the mAclDisconnectedReceiver has already been unregistered, see onDescriptorWrite()
                    }
                }
                signalDisconnected("");
            }
        }
    };
}
