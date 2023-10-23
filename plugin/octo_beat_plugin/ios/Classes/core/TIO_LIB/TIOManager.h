//
//  TIOManager.h
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) 2013,2014 Telit Wireless Solutions GmbH, Germany
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIOPeripheral.h"


@class TIOManager;

/**
 *  The TIOManager's delegate must adopt the TIOManagerDelegate protocol. The delegate uses this protocol's methods to monitor system Bluetooth availability and to manage information about TIOPeripheral objects.
 */
@protocol TIOManagerDelegate <NSObject>

///@{
/// @name Monitoring System Bluetooth Availability

/**
 *  Invoked when the operating system grants Bluetooth availability.
 *
 *  The operating system calls this method asynchronously after the TIOManager initialization, if Bluetooth is available within the system. Before this method has been called, no TIOManager scan operations shall be performed.
 *  @param manager The TIOManager singleton instance.
 */
- (void)tioManagerBluetoothAvailable:(TIOManager *)manager;

/**
 *  Invoked when the operating system does no longer support Bluetooth functionality (e.g. Bluetooth has been switched off within Settings).
 *
 *  When this method is invoked, a scan operation that may have been started before will have been stopped by the operating system. The application should update its user interface accordingly.
 *  Scan operations may only be re-started after the tioManagerBluetoothAvailable: method has been invoked.
 *  @param manager	The TIOManager singleton instance.
 */
- (void)tioManagerBluetoothUnavailable:(TIOManager *)manager;

///@}


///@{
/// @name Managing TIOPeripheral Information

/**
 *  Invoked when a TerminalIO peripheral has been newly discovered.
 *
 *  This method is invoked when a TerminalIO peripheral currently not contained within the TIOManager peripherals list has been discovered during a scan procedure,
 *  i.e. after having called one of the TIOManager methods [startScan]([TIOManager startScan]) or [startUpdateScan]([TIOManager startUpdateScan]).
 *  The peripheral will then be added to the TIOManager peripherals list, and this method will not be invoked again.
 *
 *  If a known peripheral with an updated advertisement is detected, the tioManager:didUpdatePeripheral: method will be invoked.
 *  @param manager	The TIOManager singleton instance.
 *  @param peripheral A TIOPeripheral instance representing the discovered TerminalIO peripheral.
 */
- (void)tioManager:(TIOManager *)manager didDiscoverPeripheral:(TIOPeripheral *)peripheral;

/**
 *  Invoked when a TerminalIO peripheral has been reconstructed.
 *
 *  This method is invoked for each TIOPeripheral instance having been reconstructed from a serialized CBPeripheral identifier after a call to the TIOManager method [loadPeripherals]([TIOManager loadPeripherals]).
 *  @param manager    The TIOManager singleton instance.
 *  @param peripheral A TIOPeripheral instance representing the known TerminalIO peripheral.
 */
- (void)tioManager:(TIOManager *)manager didRetrievePeripheral:(TIOPeripheral *)peripheral;

/**
 *  Invoked when an update of a TerminalIO peripheral's advertisement has been detected.
 *
 *  This method is invoked when a known TerminalIO peripheral with a changed advertisement is discovered
 *  after starting a new scan procedure ([startScan]([TIOManager startScan])) or during an update scan ([startUpdateScan]([TIOManager startUpdateScan])).
 *  @param manager	The TIOManager singleton instance.
 *  @param peripheral A TIOPeripheral instance representing the TerminalIO peripheral having updated its advertisement.
 */
@optional
- (void)tioManager:(TIOManager *)manager didUpdatePeripheral:(TIOPeripheral *)peripheral;

///@}

@end



/**
 *  The TIOManager is the fundamental class to provide TerminalIO functionality towards the application. It exists as one instance only per application (singleton),
 *  encapsulating the TerminalIO Bluetooth Low Energy functionality and supplying its TIOManagerDelegate with TerminalIO relevant events.
 */
@interface TIOManager : NSObject

///@{
/// @name Retrieving the TIOManager Instance

/**
 *  Returns the singleton TIOManager instance.
 *
 *  The TIOManager singleton is "lazily" instantiated and initialized - including the tying up to CoreBluetooth's CBCentralManager - during the first call to this static message function.
 *  It is therefore recommended to call this message at an early state of application startup, e.g. within the AppDelegate's 'didFinishLaunchingWithOptions' callback.
 *  No TIOManager scan operations shall be performed until the TIOManagerDelegate method [tioManagerBluetoothAvailable:]([TIOManagerDelegate tioManagerBluetoothAvailable:]) has been invoked.
 *  @return The singleton TIOManager instance.
 */
+ (TIOManager *)sharedInstance;

///@}

/**
 *  Returns the singleton TIOManager instance.
 *
 *  The TIOManager singleton is "lazily" instantiated and initialized - including the tying up to CoreBluetooth's CBCentralManager - during the first call to this static message function.
 *  It is therefore recommended to call this message at an early state of application startup, e.g. within the AppDelegate's 'didFinishLaunchingWithOptions' callback.
 *  No TIOManager scan operations shall be performed until the TIOManagerDelegate method [tioManagerBluetoothAvailable:]([TIOManagerDelegate tioManagerBluetoothAvailable:]) has been invoked.
 *  This variant of sharedInstance initializes the Bloetiith manager with the queue provided. In consequence, all delegate callbacks occur in the same queue!
 *  @return The singleton TIOManager instance.
 */

+ (TIOManager *)sharedInstanceWithQueue: (dispatch_queue_t) queue;

///@}


///@{
/// @name Receiving TerminalIO Relevant Events

/**
 *  The delegate object to receive TIOManager events, see TIOManagerDelegate.
 *
 *  TIOManager invokes all TIOMangerDelegate methods on the main thread.
 */
@property (weak, nonatomic) NSObject <TIOManagerDelegate> *delegate;

///@}


///@{
/// @name Scanning for TerminalIO Peripherals

/**
 *  Starts a CoreBluetooth scan for TerminalIO peripherals discovering each peripheral within range only once.
 *
 *  This scan method uses CoreBluetooth's scan functionality with the 'AllowDuplicates' key set to NO.
 *  This means that any peripheral once discovered during this scan procedure will not cause any further discovery events
 *  and that advertisements changing dynamically during this scan procedure will not be detected.
 *  After having called stopScan though, a new call to this method will lead to the recognition of advertisements having changed in the meantime.
 *
 *  This scan method is the method recommended by iOS programming guidelines and is optimized for low power consumption.
 *  In background mode, peripheral detection is significantly slowed down.
 *
 *  If a detection of advertisements dynamically changing during the scan procedure is required, call startUpdateScan instead.
 *
 *  Call stopScan to stop the scan procedure and save battery power.
 *
 *  This method shall not be called before the TIOManagerDelegate method [tioManagerBluetoothAvailable:]([TIOManagerDelegate tioManagerBluetoothAvailable:]) has been invoked.
 */
- (void)startScan;

/**
 *  Starts a CoreBluetooth scan for TerminalIO peripherals with repeated discovery of each peripheral in range.
 *
 *  This scan method uses CoreBluetooth's scan functionality with the 'AllowDuplicates' key set to YES.
 *  Dynamically changing advertisements can thus be detected during this scan procedure.
 *
 *  This scan method is declared as 'not recommended' by iOS programming guidelines for reasons of high power consumption.
 *  According to iOS programming guidelines, the operation system may disable the 'AllowDuplicates' key when the application is operating in background mode.
 *
 *  Call stopScan to stop the scan procedure and save battery power.
 *
 *  This method shall not be called before the TIOManagerDelegate method [tioManagerBluetoothAvailable:]([TIOManagerDelegate tioManagerBluetoothAvailable:]) has been invoked.
 */
- (void)startUpdateScan;

/**
 *  Stops a currently running scan procedure.
 *
 *  It is recommended to stop scanning whenever all required detection events have been received in order to save battery power.
 */
- (void)stopScan;

///@}


///@{
/// @name Managing TerminalIO Peripherals

/**
 *  An array of TIOPeripheral instances representing all currently known TerminalIO peripherals.
 */
@property	(readonly, nonatomic) NSArray *peripherals;

/**
 *  Loads TIOPeripherals previously saved with savePeripherals.
 *
 *  Populates the TIOManager's peripherals list with TIOPeripheral instances created from a serialized list of CBPeripheral identifiers.
 *  Call this method before performing any other Bluetooth activity, preferably within the AppDelegate's 'didFinishLaunchingWithOptions' callback.
 *
 *  For each reconstructed TIOPeripheral instance, the TIOManagerDelegate method 'tioManager:didRetrievePeripheral:' will be invoked.
 *  This enables a TerminalIO application to re-populate a table view or to otherwise represent the known peripherals.
 *  The reconstructed TIOPeripheral instances do not contain any advertisement information. If any advertisement information (e.g. local name, TIOPeripheralOperationMode) is required, call startScan in order to refresh the advertisement information of peripherals within radio range.
 */
- (void)loadPeripherals;

/**
 *  Serializes the list of CBPeripheral identifiers to a persistent file in the application directory.
 */
- (void)savePeripherals;

/**
 *  Removes the specified peripheral from the TIOManager's peripheral list.
 *
 *  @param peripheral The TIOPeripheral instance to remove from the TIOManager's peripheral list.
 */
- (void)removePeripheral:(TIOPeripheral *)peripheral;

/**
 *  Removes all peripherals from the TIOManager's peripheral list.
 */
- (void)removeAllPeripherals;

- (TIOPeripheral *)createPeripheral:(NSUUID *)uuid;

///@}

@end
