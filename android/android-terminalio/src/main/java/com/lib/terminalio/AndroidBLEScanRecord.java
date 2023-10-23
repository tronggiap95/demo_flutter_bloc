/* ------------------------------------------------------------------------------------------------
*
* Copyright (C) 2016 Telit Wireless Solutions GmbH, Germany
*
-------------------------------------------------------------------------------------------------*/

package com.lib.terminalio;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.UUID;

class AndroidBLEScanRecord {

	protected static final int BLE_SCAN_RECORD_VALUE_TYPE_MORE_16_BIT_UUIDS = 0x02;
	protected static final int BLE_SCAN_RECORD_VALUE_TYPE_16_BIT_UUID_LIST = 0x03;
	protected static final int BLE_SCAN_RECORD_VALUE_TYPE_MORE_128_BIT_UUIDS = 0x06;
	protected static final int BLE_SCAN_RECORD_VALUE_TYPE_128_BIT_UUID_LIST = 0x07;
	protected static final int BLE_SCAN_RECORD_VALUE_TYPE_SHORTENED_LOCAL_NAME = 0x08;
	protected static final int BLE_SCAN_RECORD_VALUE_TYPE_COMPLETE_LOCAL_NAME = 0x09;
	protected static final int BLE_SCAN_RECORD_VALUE_TYPE_MANUFACTURER_SPECIFIC_DATA = 0xFF;

	protected ArrayList<UUID> 	mServiceUuids = new ArrayList<UUID>();
	protected String		  	mLocalName = "";
	protected boolean 			mIsLocalNameShortened;
	protected byte[] 			mManufacturerSpecificData = new byte[0];
	
	public static final AndroidBLEScanRecord createFromRecordData(byte[] recordData) {
		AndroidBLEScanRecord record = new AndroidBLEScanRecord();
		try {
			record.parseRecordData(recordData);
		} catch (Exception ex) {
			STTrace.exception(ex);
		}
		return record;
	}
	
	public UUID[] getSerivceUuids() {
		return this.mServiceUuids.toArray(new UUID[this.mServiceUuids.size()]);
	}
	
	public boolean containsServiceUuid(UUID servieUuid) {
		for (UUID uuid: this.mServiceUuids) {
			if (uuid.equals(servieUuid))
				return true;
		}
		return false;
	}
	
	public final String getLocalName() {
		return this.mLocalName;
	}
	
	public boolean isLocalNameShortened() {
		return this.mIsLocalNameShortened;
	}
	
	public final byte[] getManufacturerSpecificData() {
		return this.mManufacturerSpecificData;
	}
	
	protected void parseRecordData(byte[] data) {
		
		int pos = 0;
		while(true) {
			
			int length = data[pos++];
			if (length == 0)
				break;
			
			if (pos >= data.length)
				break;
			
			int end = pos + length;
			if (end >= data.length)
				break;
			
			int type = data[pos++] & 0xFF;
			byte[] field = Arrays.copyOfRange(data, pos, end);
			this.handleField(type, field);
			pos = end;
		}
	}
	
	protected void handleField(int type, byte[] data) {
		switch (type) {
			case AndroidBLEScanRecord.BLE_SCAN_RECORD_VALUE_TYPE_MORE_16_BIT_UUIDS:
			case AndroidBLEScanRecord.BLE_SCAN_RECORD_VALUE_TYPE_16_BIT_UUID_LIST:
				this.handle16BitUuid(data);
				break;
			
			case AndroidBLEScanRecord.BLE_SCAN_RECORD_VALUE_TYPE_MORE_128_BIT_UUIDS:
			case AndroidBLEScanRecord.BLE_SCAN_RECORD_VALUE_TYPE_128_BIT_UUID_LIST:
				this.handle128BitUuid(data);
				break;
			
			case AndroidBLEScanRecord.BLE_SCAN_RECORD_VALUE_TYPE_SHORTENED_LOCAL_NAME:
				this.handleLocalName(data, true);
				break;
			
			case AndroidBLEScanRecord.BLE_SCAN_RECORD_VALUE_TYPE_COMPLETE_LOCAL_NAME:
				this.handleLocalName(data, false);
				break;
			
			case AndroidBLEScanRecord.BLE_SCAN_RECORD_VALUE_TYPE_MANUFACTURER_SPECIFIC_DATA:
				this.handleManufacturerSpecificData(data);
				break;
			
			default:
				break;
		}
	}
	
	protected void handle16BitUuid(byte[] data) {

		StringBuilder builder = new StringBuilder();
		builder.append("0000");
		for (int n = 0; n < 2; n++) {
			builder.append(String.format("%02x", data[1 - n]&0xff));
		}
		builder.append("-0000-1000-8000-00805F9B34FB");
		UUID uuid = UUID.fromString(builder.toString());
		this.mServiceUuids.add(uuid);
	}
	
	protected void handle128BitUuid(byte[] data) {
		
		StringBuilder builder = new StringBuilder();
		for (int n = 0; n < 16; n++) {
			builder.append(String.format("%02x", data[15 - n]&0xff));
			if (n == 3 || n == 5 || n == 7 || n == 9)
				builder.append('-');
		}
		UUID uuid = UUID.fromString(builder.toString());
		this.mServiceUuids.add(uuid);
	}
	
	protected void handleLocalName(byte[] data, boolean isShortened) {
		try {
			this.mLocalName = new String(data, "UTF-8");
			this.mIsLocalNameShortened = isShortened;
		} catch (Exception ex) {
			STTrace.exception(ex);
		}
	}
	
	protected void handleManufacturerSpecificData(byte[] data) {
		this.mManufacturerSpecificData = data;
	}
	
	private AndroidBLEScanRecord() { }
	
}
