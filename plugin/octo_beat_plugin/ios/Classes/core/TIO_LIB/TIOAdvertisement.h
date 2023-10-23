//
//  TIOAdvertisement.h
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) 2013,2014 Telit Wireless Solutions GmbH
//

#import <Foundation/Foundation.h>
#import "TIO.h"


/**
 *  TIOAdvertisement instances represent a remote TerminalIO device's advertisement data.
 *  The application retrieves TIOAdvertisement instances as the TIOPeripheral 'advertisement' readonly property.
 *  The application shall not alloc/init any TIOAdvertisement instances of its own.
 */
@interface TIOAdvertisement : NSObject

///@{
/// @name Instantiation

/**
 *  Creates a TIOAdvertisement instance from the specified data received during a TIOManager scan procedure.
 *  @param data Data to create the advertisement instance from.
 *  @return A TIOAdvertisement instance created from the specified data.
 */
+ (TIOAdvertisement *)advertisementWithData:(NSDictionary *)data;

///@}


///@{
/// @name Retrieving Properties Information

/**
 *  The local name contained within the advertisement data.
 */
@property	(strong, readonly, nonatomic) NSString *localName;

/**
 *  YES if the remote device requests a connection, NO otherwise.
 */
@property (readonly, nonatomic) BOOL connectionRequested;

/**
 *  The remote device's current TIOPeripheralOperationMode.
 */
@property (readonly, nonatomic) TIOPeripheralOperationMode operationMode;

/**
 *  A textual description composed from the remote peripheral's name, local name, operation mode and connection requested state.
 */
@property	(readonly, nonatomic) NSString *displayDescription;

///@}


///@{
/// @name Comparing Advertisements

/**
 *  Compares this instance to another TIOAdvertisement instance for equality of contents	.
 *  @param advertisement The TIOAdvertisement instance to compare this instance to.
 *  @return YES, if local name, operation mode and connection requested state are equal, NO otherwise.
 */
- (BOOL)isEqualToAdvertisement:(TIOAdvertisement *)advertisement;

///@}

@end
