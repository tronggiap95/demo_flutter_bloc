/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import java.io.IOException;


/**
 *  TIOPeripheral instances represent remote devices that have been identified as TerminalIO servers
 *  during a TIOManager scan procedure. The application retrieves TIOPeripheral instances by calling the
 *  TIOManager {@link TIOManager#getPeripherals() TIOManager.getPeripherals} property or via invocations of
 *  one of the peripheral relevant {@link TIOManagerCallback} methods.
 */

public interface TIOPeripheral {

    /**
     * Gets the peripheral's Bluetooth address.
     * @return A String instance representing the peripheral's Bluetooth address.
     */
    public String           getAddress();

    /**
     * Gets the peripheral's Bluetooth GATT name.
     * @return A String instance representing the peripheral's Bluetooth GATT name.
     */
    public String           getName();

    /**
     *  Gets the TIOAdvertisement instance representing the latest advertisement received from the
     *  peripheral during a scan procedure.
     *
     *  This property may be null if the TIOPeripheral instance has been reconstructed via a call to
     *  {@link TIOManager#loadPeripherals() TIOManager.loadPeripherals()} method
     *   and no subsequent scan has been performed.
     *
     * @return A TIOAdvertisement instance representing the peripheral's TerminalIO advertisement, or null.
     */
    public TIOAdvertisement getAdvertisement();

    /**
     * Connect to remote TIO peripheral device. A connection might take several seconds to complete.
     * @param listener - Callback listener instance to returns events for new connection instance.
     * @return Return new created TIOConnection object.
     * @throws IOException
     */
    public TIOConnection    connect(TIOConnectionCallback listener) throws IOException;

    /**
     * Get the connected state for this specific peripheral.
     *  Not connected: {@link TIOConnection#STATE_DISCONNECTED STATE_DISCONNECTED}.
     *  Hangup pending: {@link TIOConnection#STATE_DISCONNECTING STATE_DISCONNECTING}.
     *  Setup a connection: {@link TIOConnection#STATE_CONNECTING STATE_CONNECTING}.
     *  Connection is established: {@link TIOConnection#STATE_CONNECTED STATE_CONNECTED}.
     * @return return one of TIOConnection.STATE_XXX values.
     */
    public int              getConnectionState ();

    /**
     * Returns active connection instance if any.
     * @return Returns the active connection object or null if state is disconnected.
     */
    public TIOConnection    getConnection();

    /**
     * Gets the information whether the peripheral shall be persistently saved to file by the
     * {@link TIOManager#savePeripherals() TIOManager.savePeripherals()} method or not.
     *  @return <code>true</code> if the peripheral shall be persistently saved to file by the
     *  {@link TIOManager#savePeripherals() TIOManager.savePeripherals()} method, <code>false</code> otherwise.
     *  Default setting is false.
     */
    public boolean shallBeSaved();

    /**
     * Determines whether the peripheral shall be persistently saved to file by the
     * {@link TIOManager#savePeripherals() TIOManager.savePeripherals()} method or not.
     * @param shallBeSaved
     */
    public void setShallBeSaved(boolean shallBeSaved);

    /**
     *  Sets a tag object.
     *  Allows for 'tagging' any application-defined object to the peripheral instance
     *  and can be used from app developer to make back references to own objects.
     *  @param tag An Object instance to tag to this TIOPeripheral instance.
     */
    public void setTag(Object tag);

    /**
     *  Gets the tag object.
     *  This property is not used within the TIOPeripheral implementation.
     *  @return tag The Object instance tagged to this TIOPeripheral instance.
     */
    public Object getTag();
}
