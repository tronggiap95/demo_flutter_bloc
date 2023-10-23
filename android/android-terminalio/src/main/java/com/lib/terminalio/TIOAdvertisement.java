/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

/**
 *  TIOAdvertisement instances represent a remote TerminalIO peripherals's advertisement data.
 *  The application retrieves TIOAdvertisement instances as the {@link TIOPeripheral#getAdvertisement()
 *  TIOPeripheral.getAdvertisement()} property.   The application shall not create any
 *  TIOAdvertisement instances of its own.
 */ 
public class TIOAdvertisement {

	/**
	 *  TerminalIO peripheral operation mode constants.
	 */
	 enum OperationMode {
		/**
		 *  The peripheral is (temporarily) in bonding operation mode. A central shall perform the specified bonding procedure when connecting.
		 */
		BondingOnly(0x0),
		/**
		 *  The peripheral is in functional operation mode. A central may connect in order to transmit and receive UART data (or GPIO states, if supported).
		 */
		Functional(0x1),
		/**
		 *  The peripheral is in bondable and functional mode. A central may connect and perform the specified bonding procedure or transmit and receive UART data (or GPIO states, if supported).
		 */
		BondableFunctional(0x10);

		private int _value;
		private OperationMode(int value) { this._value = value; }

		/**
		 * Creates a TIO.OperationMode value from an integer value.
		 * @param value The Integer to create a TIO.OperationMode value from.
		 * @return The requested TIO.OperationMode value.
		 */
		public static OperationMode fromValue(int value) {
			if (value == BondingOnly._value)
				return BondingOnly;
			if (value == Functional._value)
				return Functional;
			return BondableFunctional;
		}

		/**
		 * Gets this value's Integer value.
		 * @return An Integer containing this value's Integer value.
		 */
		public int getValue() { return this._value; }

		/**
		 * Compares this value an another value for equality.
		 * @param operationMode TIO.OperationMode value to compare this value to.
		 * @return <code>true</code> if both value are equal, <code>false</code> otherwise.
		 */
		public boolean equals(OperationMode operationMode) { return this._value == operationMode._value; }
	}


	private String        mLocalName = "";
	private int           mRssi;
	private OperationMode mOperationMode = OperationMode.BondableFunctional;
	private boolean       mConnectionRequested;

	//******************************************************************************
	// Initialization 
	//******************************************************************************

	private TIOAdvertisement(String localName,int rssi)	{
		mLocalName = localName;
		mRssi      = rssi;
	}
	
	
	//******************************************************************************
	// Properties
	//******************************************************************************
	
	/**
	 * Gets the peripheral's name as contained within the peripheral's advertisement data.
	 * @return A String instance containing the local name as contained within the peripheral's advertisement data.
	 */
	String getName() {
		return mLocalName;
	}

	/**
	 * Gets the RSSI value from discovery.
	 * @return
	 */
	public int getRssi() { return mRssi; }
	
	/**
	 * Gets the peripheral's operation mode as contained within the peripheral's advertisement data.
	 * @return A {@link TIOAdvertisement.OperationMode TIOAdvertisement.OperationMode} value
	 * extracted from the peripheral's advertisement data.
	 */
	 OperationMode getOperationMode() {
		return mOperationMode;
	}
	
	/**
	 * Gets the peripheral's connection requested state as contained within the peripheral's advertisement data.
	 * @return <code>true</code> if the peripheral requests a connection, <code>false</code> otherwise. 
	 */
	boolean isConnectionRequested() {
		return mConnectionRequested;
	}

	
	/**
	 * Gets a string representation of this instance
	 * @return A String instance representing this instance.
	 */
	@Override
	public String toString() {
		String description = mLocalName + " [" + mOperationMode.toString();
		if (mConnectionRequested)
			description += " connection requested";
		description +=  "]";
		return description;
	}
	
	
	//******************************************************************************
	// Public methods
	//******************************************************************************
	
	/**
	 *  Compares this instance to another TIOAdvertisement instance for equality of contents	.
	 *  @param advertisement The TIOAdvertisement instance to compare this instance to.
	 *  @return <code>true</code>, if local name, operation mode and connection requested state are equal,
	 *  <code>false</code> otherwise.
	 */ 
	public boolean equals(TIOAdvertisement advertisement) {
		if ( ! mLocalName.equals(advertisement.mLocalName))
			return false;
		if (! mOperationMode.equals(advertisement.mOperationMode))
			return false;
		if (! mConnectionRequested == advertisement.mConnectionRequested)
			return false;
		return true;
	}


	//******************************************************************************
	// Internal methods
	//******************************************************************************
	
	private boolean evaluateData(byte[] data) {
		boolean result = false;
		do
		{
			if (data.length < 7)
				break;
			
			// Check for mandatory TerminalIO specific values.
			if ((data[0] & 0xff) != 0x8f || (data[1] & 0xff) != 0x0 || (data[2] & 0xff) != 0x9 || (data[3] & 0xff) != 0xb0)
				break;
			
			// Extract peripheral state information.
			mConnectionRequested = (data[6] == 1);
			mOperationMode       = OperationMode.fromValue(data[5]);
		
			result = true;
			
		} while (false);
		
		return result;
	}
	
	
	//******************************************************************************
	// Internal interface towards TIOManager
	//******************************************************************************
	
	/**
//	 * @deprecated (exclude for javadoc documentation generation) 
	 * Internal method to be called by TIOManager only; do not call from application code.
	 */
	static final TIOAdvertisement create(String localName,int rssi, byte[] manufacturerSpecificData) {
		TIOAdvertisement advertisement = new TIOAdvertisement(localName,rssi);
		if (advertisement.evaluateData(manufacturerSpecificData) == false) {
			return null;
		}
		return advertisement;
	}

}
