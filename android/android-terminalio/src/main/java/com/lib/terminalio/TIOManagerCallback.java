/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

/**
 *  The TIOManager's event listener implements the TIOManagerCallback interface in order to monitor information about TIOPeripheral objects.
 */
public interface TIOManagerCallback {
	
	/**
	 *  Invoked when a TerminalIO peripheral has been newly discovered.
	 *
	 *  This method is invoked when a TerminalIO peripheral currently not contained within the
	 *  TIOManager peripherals list has been discovered during a scan procedure,  i.e. after having
	 *  called the TIOManager method {@link TIOManager#startScan(TIOManagerCallback listener) TIOManager.startScan()}.
	 *  The peripheral will then be added to the TIOManager peripherals list, and this method will
	 *  not be invoked again for this specific peripheral.
	 *
	 *  If a known peripheral with an updated advertisement is detected, the
	 *  {@link #onPeripheralUpdate(TIOPeripheral) onPeripheralUpdate()} method will be invoked.
	 *  @param peripheral A TIOPeripheral instance representing the discovered TerminalIO peripheral.
	 */ 
	void onPeripheralFound(TIOPeripheral peripheral);
	 
	/**
	 *  Invoked when an update of a TerminalIO peripheral's advertisement has been detected.
	 *
	 *  This method is invoked when a known TerminalIO peripheral with a changed advertisement is
	 *  discovered  after having started a new scan procedure by calling {@link TIOManager#startScan(TIOManagerCallback listener)
	 *  TIOManager.startScan()}.
	 *  @param peripheral A TIOPeripheral instance representing the TerminalIO peripheral having updated its advertisement.
	 */ 
	void onPeripheralUpdate(TIOPeripheral peripheral);
}
