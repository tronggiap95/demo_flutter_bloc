//
//  TIOPeripheral.h
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) Telit Wireless Solutions GmbH, Germany
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIOAdvertisement.h"


@class TIOPeripheral;


/**
 *  The TIOPeripheral's delegate must adopt the TIOPeripheralDelegate protocol. The delegate uses this protocol's methods to monitor connection events, data exchange and peripheral property updates.
 */
@protocol TIOPeripheralDelegate <NSObject>

///@{
/// @name Monitoring Connection Events

/**
 *  Invoked when a TermialIO connection has been successfully established.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 */
- (void)tioPeripheralDidConnect:(TIOPeripheral *)peripheral;

/**
 *  Invoked when a TerminalIO connection establishment has failed.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param error An NSError instance containing information about the failure's cause.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didFailToConnectWithError:(NSError *)error;

/**
 *  Invoked when an established TerminalIO connection is disconnected.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param error An NSError instance containing information about the disconnect's cause.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didDisconnectWithError:(NSError *)error;

///@}


///@{
/// @name Monitoring Data Exchange

/**
 *  Invoked when UART data transmitted by the remote device have been received.
 *
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param data An NSData instance containing the received UART data.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didReceiveUARTData:(NSData *)data;

/**
 *  Invoked when a UART data block has been written to the remote device.
 *
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param bytesWritten The number of bytes written.
 */
@optional
- (void)tioPeripheral:(TIOPeripheral *)peripheral didWriteNumberOfUARTBytes:(NSInteger)bytesWritten;

/**
 *  Invoked when all UART data have been written to the remote device.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 */
- (void)tioPeripheralUARTWriteBufferEmpty:(TIOPeripheral *)peripheral;

///@}


///@{
/// @name Monitoring Peripheral Property Updates

/**
 *  Invoked when an updated advertisement for a known peripheral has been detected after calling one of the TIOManager methods [startScan]([TIOManager startScan]) or [startUpdateScan]([TIOManager startUpdateScan]).
 *  @param peripheral The TIOPeripheral instance this event applies for.
 */
- (void)tioPeripheralDidUpdateAdvertisement:(TIOPeripheral *)peripheral;

/**
 *  Invoked when an RSSI value is reported as a response to calling the TIOPeripheral method [readRSSI]([TIOPeripheral readRSSI]).
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param rssi An NSNumber instance containing the reported RSSI value.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didUpdateRSSI:(NSNumber *)rssi;

/**
 *  Invoked when the number of local UART credits has changed due to received data or new UART credits granted to the remote peripheral.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param creditsCount An NSNumber instance containing the current number of local UART credits.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didUpdateLocalUARTCreditsCount:(NSNumber *)creditsCount;


/**
 *  Invoked when the number of remote UART credits has changed due to sent data or new UART credits granted by the remote peripheral.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param creditsCount An NSNumber instance containing the current number of remote UART credits.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didUpdateRemoteUARTCreditsCount:(NSNumber *)creditsCount;


/**
 *  Invoked when the number of local UART credits has changed due to received data or new UART credits granted to the remote peripheral.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param mtuSize An NSNumber instance containing the current size of local UART MTU.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didUpdateLocalUARTMtuSize:(NSNumber *)mtuSize;


/**
 *  Invoked when the number of remote UART credits has changed due to sent data or new UART credits granted by the remote peripheral.
 *  @param peripheral The TIOPeripheral instance this event applies for.
 *  @param mtuSize An NSNumber instance containing the current size of remote UART MTU.
 */
- (void)tioPeripheral:(TIOPeripheral *)peripheral didUpdateRemoteUARTMtuSize:(NSNumber *)mtuSize;

///@}

@end


/**
 *  TIOPeripheral instances represent remote devices that have been identified as TerminalIO servers during a TIOManager scan procedure.
 *  The application retrieves TIOPeripheral instances by calling the TIOManager 'peripherals' property or via invocations of one of the peripheral relevant TIOManagerDelegate methods.
 *  The application shall not alloc/init any TIOPeripheral instances of its own.
 */
@interface TIOPeripheral : NSObject

///@{
/// @name Receiving TerminalIO Relevant Events

/**
 *  The delegate object to receive TIOPeripheral events, see TIOPeripheralDelegate.
 *
 *  TIOPeripheral instances invoke all TIOPeripheralDelegate methods on the main thread.
 */
@property (weak, nonatomic) NSObject <TIOPeripheralDelegate> *delegate;

///@}


///@{
/// @name Retrieving Properties and Capabilities Information

/**
 *  TIOAdvertisement instance representing the latest advertisement received from the peripheral within a scan procedure.
 *
 *  This property may be nil if the TIOPeripheral instance has been reconstructed via a call to the [TIOManager loadPeripherals]([TIOManager loadPeripherals]) method and no subsequent update scan has been performed.
 */
@property (strong, readonly, nonatomic) TIOAdvertisement *advertisement;

/**
 *  NSUUID instance representing the peripheral's unique identifier as exposed by CoreBluetooth.
 */
@property (readonly, nonatomic) NSUUID *identifier;

/**
 *  The peripheral's name.
 *
 *  This property represents the peripheral's GATT name as retrieved during the scan procedure.
 *
 *  It may differ from the peripheral's local name exposed within the peripheral's advertisement (see [TIOAdvertisement localName]([TIOAdvertisement localName])).
 *
 *  CoreBluetooth may not update a known CBPeripheral's name property even if the name has changed.
 */
@property (readonly, nonatomic) NSString *name;

/**
 *  YES if the peripheral shall be persistently saved to file by the [TIOManager savePeripherals]([TIOManager savePeripherals]) method, NO otherwise.
 */
@property (nonatomic) BOOL shallBeSaved;

///@}


///@{
/// @name Managing Connections

/**
 *  YES if the TIOPeripheral instance is in the process of establishing a TerminalIO connection to the remote device, NO otherwise.
 */
@property	(readonly, nonatomic) BOOL isConnecting;

/**
 *  YES if the TIOPeripheral instance is TerminalIO connected to the remote device, NO otherwise.
 */
@property	(readonly, nonatomic) BOOL isConnected;

/**
 *  UART MTU sizes for remote and local sides.
 */
@property	(readonly, nonatomic) NSInteger remoteUartMtuSize;  // UART MTU size of remote side
@property	(readonly, nonatomic) NSInteger localUartMtuSize;   // UART MTU size of local side

/**
 *  Initiates the establishing of a TerminalIO connection to the remote device.
 *
 *  The TerminalIO connection establishment consists of various asynchronous operations over the air.
 *  In case of a successful connection establishment, the TIOPeripheralDelegate method [tioPeripheralDidConnect:]([TIOPeripheralDelegate tioPeripheralDidConnect:]) method is invoked;
 *  otherwise [tioPeripheral:didFailToConnectWithError:]([TIOPeripheralDelegate tioPeripheral:didFailToConnectWithError:]) will be invoked.
 *  Data exchange operations cannot be perfomed unless [tioPeripheralDidConnect:]([TIOPeripheralDelegate tioPeripheralDidConnect:]) has been invoked; the application may also check for isConnected.
 *
 * The TerminalIO connection request does not time out even if the application moves to the background.
 *
 * To cancel a pending connection request, call cancelConnection.
 * 
 * If the remote device is configured to require security and has not been paired before with the local device, a Bluetooth pairing process will be initiated and the operating system will prompt the user to accept pairing with the remote device.
 */
- (void)connect;

/**
 *  Requests the operating system to disconnect from the remote device.
 *
 *  The operating system does not allow for an enforced connection drop as other applications might be (Bluetooth-)connected to the same remote device.
 *  In a scenario where the TerminalIO connection is the only (Bluetooth-)connection to the remote device, the operating system will asynchronously terminate the connection.
 *  The connection termination will be reported via the TIOPeripheralDelegate method [tioPeripheral:didDisconnectWithError:]([TIOPeripheralDelegate tioPeripheral:didDisconnectWithError:]).
 */
- (void)cancelConnection;

///@}


///@{
/// @name Exchanging Data

/**
 *  Writes UART data to the remote device. Requires the peripheral to be TerminalIO connected.
 *
 *  The specified data will be appended to a write buffer, so there is generally no limitation for the data's size except for memory conditions within the operating system.
 *  Nevertheless, data sizes should be considered carefully and transmission rates and power consumption should be taken into account.
 *
 *  For each data block written, the TIOPeripheralDelegate method [tioPeripheral:didWriteNumberOfUARTBytes:]([TIOPeripheralDelegate tioPeripheral:didWriteNumberOfUARTBytes:]) will be invoked reporting the number of bytes written.
 *  If there are no more data to be written, the TIOPeripheralDelegate method [tioPeripheralUARTWriteBufferEmpty:]([TIOPeripheralDelegate tioPeripheralUARTWriteBufferEmpty:]) will be invoked.
 *  @param data Data to be written.
 */
- (void)writeUARTData:(NSData *)data;

/**
 *  Maximum number of local credits that shall be granted to the remote device.
 *
 *  A credit is defined as the permission to send one data packet of 1 to 20 bytes.
 *  Receiving a UART data packet (1 to 20 bytes) from the remote device decrements the local credit counter by 1.
 *  As soon as the local credit counter reaches minLocalUARTCreditsCount, a number of (maxLocalUARTCreditsCount - minLocalUARTCreditsCount) credits will automatically be granted to the remote device;
 *  the local credit counter will then have the value of maxLocalUARTCreditsCount.
 *
 *  maxLocalUARTCreditsCount shall only be set to values > minLocalUARTCreditsCount and <= 255.
 *  Default value is 255.
 */
@property	(nonatomic) NSInteger maxLocalUARTCreditsCount;

/**
 *  Minimum number of local credits that shall be granted to the remote device.
 *
 *  A credit is defined as the permission to send one data packet of 1 to 20 bytes.
 *  Receiving a UART data packet (1 to 20 bytes) from the remote device decrements the local credit counter by 1.
 *  As soon as the local credit counter reaches minLocalUARTCreditsCount, a number of (maxLocalUARTCreditsCount - minLocalUARTCreditsCount) credits will automatically be granted to the remote device;
 *  the local credit counter will then have the value of maxLocalUARTCreditsCount.
 *
 *  minLocalUARTCreditsCount shall only be set to values < maxLocalUARTCreditsCount and >= 0.
 *  Default value is 32.
 */
@property	(nonatomic) NSInteger minLocalUARTCreditsCount;

/**
 *  Initiates the reading of the current RSSI value. Requires the peripheral to be TerminalIO connected.
 *
 *  Reading of the RSSI value is performed asynchronously. The identified RSSI value will be reported via the TIOPeripheralDelegate method [tioPeripheral:didUpdateRSSI:]([TIOPeripheralDelegate tioPeripheral:didUpdateRSSI:]).
 */
- (void)readRSSI;

///@}


///@{
/// @name Miscellaneous

/**
 *  Allows for 'tagging' any application-defined object to the peripheral instance. This property is not used within the TIOPeripheral implementation.
 */
@property	(strong, nonatomic) NSObject *tag;

///@}

@end
