/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import java.io.IOException;

import android.bluetooth.BluetoothDevice;
import android.content.Context;

/**
 *  TIOPeripheralImpl instances represent remote devices that have been identified as TerminalIO servers
 *  during a TIOManager scan procedure. The application retrieves TIOPeripheral instances by calling the
 *  TIOManager {@link TIOManager#getPeripherals() TIOManager.getPeripherals} property or via invocations of
 *  one of the peripheral relevant {@link TIOManagerCallback} methods.
 */
final class TIOPeripheralImpl implements TIOPeripheral {

	private BluetoothDevice       		mDevice;
	private TIOAdvertisement			mAdvertisement;
	private Context                     mApplicationContext;
	private boolean 					mShallBeSaved;
	private Object						mTag;
	private TIOConnection               mConnection;
	
	//******************************************************************************
	// Initialization 
	//******************************************************************************

	TIOPeripheralImpl(BluetoothDevice device,Context context,TIOAdvertisement advertisement) {
		mDevice              = device;
		mApplicationContext  = context;
		mAdvertisement       = advertisement;
		mShallBeSaved        = true;
	}

	//******************************************************************************
	// Properties
	//******************************************************************************
	
	/**
	 * Gets the preripheral's Bluetooth address.
	 * @return A String instance representing the peripheral's Bluetooth address. 
	 */
	@Override
	public String getAddress() {
		return mDevice.getAddress();
	}
	
	/**
	 * Gets the preripheral's Bluetooth GATT name.
	 * @return A String instance representing the peripheral's Bluetooth GATT name. 
	 */
	@Override
	public String getName() {
		return (mDevice.getName() == null) ? "" : filterBluetoothDeviceName(mDevice.getName());
	}

	/**CUSTOM FUNCTIONS BY MANH TRAN
	 * THIS FUNCTION IS TO FILTER OctoBeat DEVICES
	 * @param name preripheral's Bluetooth GATT name
	 * @return filter name
	 */

	private String filterBluetoothDeviceName(String name) {
		 if (name.contains("Octo-Beat-")) {
			return name.replace("Octo-Beat-", "");
		} else {
			Boolean found = name.matches("[0-9]+");
			if (found) {
				return name;
			} else {
				return "";
			}
		}
	}

	/**
	 *  Gets the TIOAdvertisement instance representing the latest advertisement received from the peripheral within a scan procedure.
	 *
	 *  This property may be null if the TIOPeripheral instance has been reconstructed via a call to {@link TIOManager#loadPeripherals() TIOManager.loadPeripherals()} method
	 *   and no subsequent scan has been performed yet.
	 *   
	 * @return A TIOAdvertisement instance representing the peripheral's TerminalIO advertisement, or null.  
	 */
	@Override
	public TIOAdvertisement getAdvertisement() {
		return mAdvertisement;
	}

	@Override
	public int getConnectionState() {
		return (mConnection != null ) ? mConnection.getConnectionState() : TIOConnection.STATE_DISCONNECTED;
	}

	@Override
	public TIOConnection    getConnection() {
		return mConnection;
	}

	/**
	 * Gets the information whether the peripheral shall be persistently saved to file by the {@link TIOManager#savePeripherals() TIOManager.savePeripherals()} method or not.
	 *  @return <code>true</code> if the peripheral shall be persistently saved to file by the {@link TIOManager#savePeripherals() TIOManager.savePeripherals()} method, <code>false</code> otherwise.
	 */
	@Override
	public boolean shallBeSaved() {
		return mShallBeSaved;
	}
	
	/**
	 * Determines whether the peripheral shall be persistently saved to file by the {@link TIOManager#savePeripherals() TIOManager.savePeripherals()} method or not.
	 */
	@Override
	public void setShallBeSaved(boolean shallBeSaved) {
		mShallBeSaved = shallBeSaved;
	}

	/**
	 * Gets a string representation of this instance consisting of Bluetooth name and Bluetooth address.
	 * @return A String instance consisting of this instance's Bluetooth name and Bluetooth address.
	 */
	@Override
	public String toString() {
		return getName() + " " + getAddress();
	}

	
	/**
	 *  Sets a tag object.
	 *  Allows for 'tagging' any application-defined object to the peripheral instance. This property is not used within the TIOPeripheral implementation.
	 *  @param tag An Object instance to tag to this TIOPeripheral instance.
	 */
	@Override
	public void setTag(Object tag)	{
		mTag = tag;
	}
	
	/**
	 *  Gets the tag object.
	 *  This property is not used within the TIOPeripheral implementation.
	 *  @return tag The Object instance tagged to this TIOPeripheral instance.
	 */
	@Override
	public Object getTag() {
		return mTag;
	}

	//******************************************************************************
	// Public methods
	//******************************************************************************

	/**
	 *  Sets the listener object to receive TIOPeripheral events, see {@link TIOPeripheralCallback TIOPeripheralCallback}.
	 *
	 *  If <code>listener</code> extends Activity, the event methods will be invoked on the UI thread.
	 *
	 *  @param listener TIOPeripheralCallback implementor receiving {@link TIOPeripheralCallback TIOPeripheralCallback} events.
	 */

	/**
	 *  Initiates the establishing of a TerminalIO connection to the remote device.
	 *
	 * The TerminalIO connection establishment consists of various asynchronous operations over the air.
	 * In case of a successful connection establishment, the TIOPeripheralCallback method {@link TIOPeripheralCallback#onConnected(TIOPeripheral)} tioPeripheralDidConnect(TIOPeripheral) tioPeripheralDidConnect()} method is invoked;
	 * otherwise {@link TIOPeripheralCallback#onConnectFailed(TIOPeripheral, String)} (TIOPeripheral, String) tioPeripheralDidFailToConnect()} will be invoked.
	 * Data exchange operations cannot be performed unless {@link TIOPeripheralCallback#onConnected(TIOPeripheral)} tioPeripheralDidConnect(TIOPeripheral) TIOPeripheralCallback.tioPeripheralDidConnect()} has been invoked; the application may also check for {@link #isConnected()}.
	 *
	 * To cancel a pending connection request, call {@link #disconnect disconnect()}.
	 * 
	 * If the remote device is configured to require security and has not been paired before with the local device, a silently running Bluetooth pairing process will be initiated.
	 */
	@Override
	public TIOConnection connect(TIOConnectionCallback listener) throws	IOException {
		int connectionState = getConnectionState();

		STTrace.method("connect in state "+connectionState);

		if ( (mConnection != null) || (connectionState != TIOConnection.STATE_DISCONNECTED)) {
			throw new IOException("Already connected or connecting... ");
		}

		mConnection = TIOManager.getInstance().createConnectionInstance(this,listener);

		return mConnection;
	}

	//******************************************************************************
	// Iternal methodes
	//******************************************************************************

	/**
	 * @exclude (exclude for javadoc documentation generation)
	 */
	BluetoothDevice getDevice() {
		return mDevice;
	}

	/**
	 * @exclude (exclude for javadoc documentation generation)
	 */
	Context getApplicationContext() {
		return mApplicationContext;
	}

	void    setApplicationContext(Context value) {
		mApplicationContext = value;
	}

	/**
	 * @exclude (exclude for javadoc documentation generation)
	 */
	void cleanup() {
		if (mConnection != null) {
			try {
				mConnection.cancel();
				mConnection.disconnect();
				mConnection = null;
			}
			catch (Exception ex) {

			}
		}
	}

	/**
	 * @exclude (exclude for javadoc documentation generation)
	 */
	void onDisconnect() {
		mConnection = null;
	}

	/**
	 * @exclude (exclude for javadoc documentation generation)
	 * Internal method to be called by TIOManager only;
	 */
	boolean update(TIOAdvertisement advertisement) {
		boolean result = false;
		if (mAdvertisement == null || !mAdvertisement.equals(advertisement))
		{
			mAdvertisement = advertisement;
			result         = true;
		}
		
		return result; 		
	}
	
}
