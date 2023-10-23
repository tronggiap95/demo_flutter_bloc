/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

/**
 * Listener for events for created TIOConnection instance.
 */
public interface TIOConnectionCallback {
    /**
     *  Invoked when a TerminalIO connection has successfully been established.
     *  @param connection The TIOConnection instance this event applies for.
     */
    void onConnected(TIOConnection connection);

    /**
     *  Invoked when a TerminalIO connection establishment has failed.
     *  @param connection The TIOConnection instance this event applies for.
     *  @param errorMessage A String containing information about the cause of the disconnect..
     */
    void onConnectFailed(TIOConnection connection, String errorMessage);

    /**
     *  Invoked when an established TerminalIO connection is disconnected.
     *  @param connection The TTIOConnection instance this event applies for.
     *  @param errorMessage A String containing information about the cause of the disconnect.
     *                      or an empty String on intentional disconnects.
     */
    void onDisconnected(TIOConnection connection, String errorMessage);

    /**
     *  Invoked  when data has been received.
     *  @param connection The TIOConnection instance this event applies for.
     *  @param data A byte array containing the received  data.
     */
    void onDataReceived(TIOConnection connection, byte[] data);

    /**
     *  Invoked when a data block has been written to the remote device.
     *  @param connection The TIOConnection instance this event applies for.
     *  @param status  The status of the write operation. The value is 0 for success.
     *  @param bytesWritten The number of bytes written when status is successfully.
     */
    void onDataTransmitted(TIOConnection connection, int status, int bytesWritten);

    /**
     *  Invoked when an RSSI value is reported as a response to calling {@link TIOConnection#readRemoteRssi(int delay) TIOConnection.readRemoteRssi()}.
     *  @param connection The TIOConnection instance this event applies for.
     *  @param status The status of the RSSI operation. The value is 0 for success.
     *  @param rssi The latest RSSI value ? (in dBm, as signed value) when status is successfully.
     */
    void  onReadRemoteRssi(TIOConnection connection,int status, int rssi);


    /**
     *  Invoked when the number of local UART credits has changed due to received data or new UART credits granted to the remote peripheral.
     *  @param connection The TIOConnection instance this event applies for.
     *  @param mtuSize The current size of local UART MTU.
     */
    void  onLocalUARTMtuSizeUpdated(TIOConnection connection, int mtuSize);


    /**
     *  Invoked when the number of remote UART credits has changed due to sent data or new UART credits granted by the remote peripheral.
     *  @param connection The TIOConnection instance this event applies for.
     *  @param mtuSize The current size of remote UART MTU.
     */
    void  onRemoteUARTMtuSizeUpdated(TIOConnection connection, int mtuSize);
}
