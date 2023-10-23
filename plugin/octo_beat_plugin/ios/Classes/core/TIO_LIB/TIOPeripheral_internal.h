//
//  TIOPeripheral.h
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) 2013,2014 Telit Wireless Solutions GmbH, Germany
//

#import <Foundation/Foundation.h>
#import "TIOPeripheral.h"


@interface TIOPeripheral ()

+ (TIOPeripheral *)peripheralWithCBPeripheral:(CBPeripheral *)cbPeripheral;
+ (TIOPeripheral *)peripheralWithCBPeripheral:(CBPeripheral *)cbPeripheral andAdvertisement:(TIOAdvertisement*)advertisement;

@property (strong, readonly, nonatomic) CBPeripheral *cbPeripheral;

- (void)didConnect;
- (void)didFailToConnectWithError:(NSError *)error;
- (void)didDisconnectWithError:(NSError *)error;
- (BOOL)updateWithAdvertisement:(TIOAdvertisement *)advertisement;

@end
