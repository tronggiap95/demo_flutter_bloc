/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import java.io.IOException;

/**
 *  TIOConnection instances represent a TerminalIO connection to remote peripheral.
 */
public interface TIOConnection {

    /**
     * The Peripheral/connection is in disconnected state
     */
    int STATE_DISCONNECTED  = 0;
    /**
     * The Peripheral/connection is in connected state
     */
    int STATE_CONNECTED     = 2;
    /**
     * The Peripheral/connection is in connecting state
     */
    int STATE_CONNECTING    = 1;
    /**
     * The Peripheral/connection is in disconnecting state
     */
    int STATE_DISCONNECTING = 3;

    /**
     * The default number of bytes contained within the UART characteristic's value.
     */
    static final int MAX_TX_DATA_SIZE = 20;

    /**
     *  Requests to disconnect from the remote device.
     *  The connection termination will be reported via the TIOPeripheralCallback method
     *  {@link TIOConnectionCallback#onDisconnected(TIOConnection, String) onDisconnected()}.
     * @throws IOException when connecion is invalid or internal service communication os broken
     */
    public void disconnect() throws IOException;

    /**
     *  Requests to cancel running connection to the remote device.
     *  The connection termination will be reported via the TIOPeripheralCallback method
     *  {@link TIOConnectionCallback#onDisconnected(TIOConnection, String) onDisconnected()}.
     * @throws IOException when connecion is invalid or internal service communication os broken
     */
    public void cancel() throws IOException;

    //EDITED BY MANH TRAN
    //TO DESTROY CONNECTION
    public void clear();

    /**
     *  Writes data to the remote device. Requires the connection to be in the connected state
     *
     *  The specified data will be appended to a write queue, so there is generally no limitation for
     *  the data's size except for memory conditions within the operating system.
     *  Nevertheless, data sizes should be considered carefully and transmission rates and power
     *  consumption should be taken into account.
     *
     *  For each data block written, the TIOConnectionCallback method {@link TIOConnectionCallback#onDataTransmitted(TIOConnection, int,int)
     *  onDataTransmitted()} will be invoked reporting the number of bytes written and the status.
     *
     * @param data Data to be written.
     * @throws IOException when connecion is invalid or internal service communication os broken
     */
    public void transmit(byte[] data) throws IOException;

    /**
     * Returns the periperal for this connection
     * @return the peripheral object for this connection instance.
     */
    public TIOPeripheral  getPeripheral();

    /**
     * Get connected state for this specific connection.
     * @return Current connection state
     */
    public int getConnectionState();

    /**
     *   Initiates the periodic reading of the RSSI value on this connection. Requires the connection to be in the connected state.
     *  Reading of the RSSI value is performed asynchronously. The identified RSSI value will be reported
     *  via the TIOConnectionCallback method {@link TIOConnectionCallback#onReadRemoteRssi(TIOConnection, int, int)}
     * @param delay  Readout interval provided in milliseconds. With value 0, RSSI notification are stopped.
     * @throws IOException when connecion is invalid or internal service communication is broken
     */
    public void readRemoteRssi(int delay) throws IOException;


    /**
     * new listener when not null. Events are no longer signalled when set to null.
     * @param listener for event when not null. For listener equal null events not longer signalled.
     */
    public void setListener(TIOConnectionCallback listener);

    /**
     * Get UART MATU size on remote side.
     * @return Current MTU size
     */
    public int getRemoteMtuSize();


    /**
     * Get UART MATU size on local side.
     * @return Current MTU size
     */
    public int getLocalMtuSize();

}
