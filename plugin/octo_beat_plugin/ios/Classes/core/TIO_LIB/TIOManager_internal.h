//
//  TIOManager.h
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) 2013,2014 Telit Wireless Solutions GmbH
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIOManager.h"
#import "TIOPeripheral.h"


@interface TIOManager ()

- (void)connectPeripheral:(TIOPeripheral *) peripheral;
- (void)cancelPeripheralConnection:(TIOPeripheral *) peripheral;

@end
