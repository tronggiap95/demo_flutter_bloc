//
//  TIOPeripheral.m
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) Telit Wireless Solutions GmbH, Germany
//

#import "TIO.h"
#import "TIOPeripheral_internal.h"
#import "TIOManager_internal.h"


@interface TIOPeripheral () <CBPeripheralDelegate>

@property	(strong, nonatomic) CBService *tioService;

@property	(strong, nonatomic) CBCharacteristic *uartTxCharacteristic;
@property	(strong, nonatomic) CBCharacteristic *uartTxCreditsCharacteristic;
@property	(strong, nonatomic) CBCharacteristic *uartRxCharacteristic;
@property	(strong, nonatomic) CBCharacteristic *uartRxCreditsCharacteristic;
@property	(strong, nonatomic) CBCharacteristic *uartRxMtuCharacteristic;
@property	(strong, nonatomic) CBCharacteristic *uartTxMtuCharacteristic;

@property (nonatomic) BOOL hadToPerformServiceDiscovery;
@property (nonatomic) BOOL didSubscribeUARTTx;
@property (nonatomic) BOOL didSubscribeUARTTxCredits;
@property (nonatomic) BOOL didSubscribeUARTTxMtu;
@property (nonatomic) BOOL didGrantInitialUARTRxCredits;
@property (nonatomic) BOOL didGrantInitialLocalUARTMtuSize;

@property (strong, nonatomic) NSMutableData *uartDataToBeWritten;
@property	(nonatomic) BOOL isWriting;
@property (strong, readonly, nonatomic) NSObject *writeLock;
@property	(nonatomic) NSInteger localUARTCreditsCount;   // RX credits granted to the peripheral
@property (nonatomic)   NSInteger pendingLocalUARTCreditsCount;
@property	(nonatomic) NSInteger remoteUARTCreditsCount;  // TX credits granted by the peripheral
@property	(nonatomic) NSInteger pendingLocalUartMtuSize;   // UART MTU size of local side

@end



@implementation TIOPeripheral

NSInteger const MIN_UART_CREDITS_COUNT = 32;

#pragma  mark - Initialization

- (TIOPeripheral *)initWithCBPeripheral:(CBPeripheral *)cbPeripheral andAdvertisement:(TIOAdvertisement *)advertisement
{
    self = [super init];
    if (self)
    {
        self.cbPeripheral = cbPeripheral;
        cbPeripheral.delegate = self;
        self.advertisement = advertisement;
        self.maxLocalUARTCreditsCount = TIO_MAX_UART_CREDITS_COUNT;
        self.minLocalUARTCreditsCount = MIN_UART_CREDITS_COUNT;
        self.shallBeSaved = YES;
        self->_remoteUartMtuSize = TIO_MAX_UART_DATA_SIZE;
        self->_localUartMtuSize  = TIO_MAX_UART_DATA_SIZE;
        self.pendingLocalUartMtuSize = 0;
    }
    return self;
}


#pragma  mark - Properties

- (NSUUID *)identifier
{
    return self.cbPeripheral.identifier;
}


- (NSString *)name
{
    if (self.advertisement == nil) {
        return [self filterName:self.cbPeripheral.name];
    }
    
    if (![self.advertisement.localName isEqualToString:@""]) {
        return [self filterName:self.cbPeripheral.name];
    }
    
    if (![self.advertisement.localName isEqualToString:self.cbPeripheral.name]) {
        return [self filterName:self.advertisement.localName];
    }
    
    return [self filterName:self.cbPeripheral.name];
}

- (NSString *)filterName:(NSString *)name {
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if([name containsString:@"Octo-Beat-"]) {
        return [name stringByReplacingOccurrencesOfString:@"Octo-Beat-" withString:@""];
    }
    
    if ([name rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        return name;
    }
    return @"";
    
}


- (void)setCbPeripheral:(CBPeripheral *)cbPeripheral
{
    self-> _cbPeripheral = cbPeripheral;
}


- (void)setAdvertisement:(TIOAdvertisement *)advertisement
{
    self-> _advertisement	= advertisement;
}


- (void)setIsConnecting:(BOOL)isConnecting
{
    self->_isConnecting = isConnecting;
}


- (void)setIsConnected:(BOOL)isConnected
{
    self->_isConnected = isConnected;
}


@synthesize uartDataToBeWritten = _uartDataToBeWritten;
- (NSMutableData *)uartDataToBeWritten
{
    if (!self->_uartDataToBeWritten)
    {
        self->_uartDataToBeWritten = [[NSMutableData alloc] init];
    }
    return self->_uartDataToBeWritten;
}


@synthesize writeLock = _writeLock;
- (NSObject *)writeLock
{
    if (!self->_writeLock)
    {
        self->_writeLock = [[NSObject alloc] init];
    }
    return self->_writeLock;
}


- (NSString *)description
{
    return self.cbPeripheral.description;
}


- (void)setMaxLocalUARTCreditsCount:(NSInteger)maxLocalUARTCreditsCount
{
    NSInteger count = (maxLocalUARTCreditsCount < self.minLocalUARTCreditsCount) ? self.minLocalUARTCreditsCount : ((maxLocalUARTCreditsCount > TIO_MAX_UART_CREDITS_COUNT) ? TIO_MAX_UART_CREDITS_COUNT : maxLocalUARTCreditsCount	);
    self->_maxLocalUARTCreditsCount = count;
}


- (void)setMinLocalUARTCreditsCount:(NSInteger)minLocalUARTCreditsCount
{
    NSInteger count = (minLocalUARTCreditsCount > self.maxLocalUARTCreditsCount) ? self.maxLocalUARTCreditsCount : ((minLocalUARTCreditsCount < 0) ? 0 : minLocalUARTCreditsCount	);
    self->_minLocalUARTCreditsCount = count;
}


#pragma  mark - Public methods

- (void)connect
{
    //STTraceMethod(self, @"connect");
    
    if (self.isConnected || self.isConnecting)
    {
        //STTraceError(@"already connected...");
        return;
    }
    
    self.hadToPerformServiceDiscovery = NO;
    self.didSubscribeUARTTx           = NO;
    self.didSubscribeUARTTxCredits    = NO;
    self.didSubscribeUARTTxMtu        = NO;
    self.didGrantInitialUARTRxCredits = NO;
    self.didGrantInitialLocalUARTMtuSize = NO;
    
    self.isWriting    = NO;
    self.isConnecting = YES;
    
    [self processTIOConnection];
}


- (void)cancelConnection
{
    //STTraceMethod(self, @"cancelConnection");
    
    //    if (!self.isConnected && !self.isConnecting)
    //    {
    //        //STTraceError(@"neither connected nor connecting...");
    //        return;
    //    }
    self.isConnected = false;
    self.isConnecting = false;
    [[TIOManager sharedInstance] cancelPeripheralConnection:self];
}


- (void)writeUARTData:(NSData *)data
{
    //STTraceMethod(self, @"writeUARTData %@", data);
    
    if (!self.isConnected)
    {
        //STTraceError(@"not connected...");
        return;
    }
    
    // append data to write buffer taking care of thread safety, as the background thread might be working on the buffer...
    @synchronized(self.writeLock)
    {
        [self.uartDataToBeWritten appendData:data];
    }
    
    [self launchUARTDataWritingOnBackgroundThread];
}


- (void)readRSSI
{
    //	STTraceMethod(self, @"readRSSI");
    
    if (!self.isConnected)
    {
        //STTraceError(@"not connected...");
        return;
    }
    
    [self.cbPeripheral readRSSI];
}


#pragma mark - Internal methods

- (void)processTIOConnection
{
    //STTraceMethod(self, @"processTIOConnection");
    
    if (self.cbPeripheral.state != CBPeripheralStateConnected)
    {
        // first we need to establish a BLE connection
        [[TIOManager sharedInstance] connectPeripheral:self];
    }
    else if (self.cbPeripheral.services == nil || self.tioService == nil)
    {
        // BLE connection has been established but the iOS service instance is not known, so a service discovery is required.
        [self discoverServices];
        self.hadToPerformServiceDiscovery = YES;
    }
    else if (self.hadToPerformServiceDiscovery || self.uartTxCharacteristic == nil || self.uartTxCreditsCharacteristic == nil)
    {
        self.hadToPerformServiceDiscovery = NO;
        // TIO service instance is known but not all characteristics instances are known, so  a characteristics discovery is required.
        [self discoverCharacteristics];
    }
    else if ((!self.didSubscribeUARTTxMtu) && (self.uartTxMtuCharacteristic != nil))
    {
        // UART TX MTU notification subscription is required.
        [self subscribeToCharacteristic:self.uartTxMtuCharacteristic];
    }
    else if (!self.didSubscribeUARTTxCredits)
    {
        // UART TX credits notification subscription is required.
        [self subscribeToCharacteristic:self.uartTxCreditsCharacteristic];
    }
    else if (!self.didSubscribeUARTTx)
    {
        // UART TX data notification subscription is required.
        [self subscribeToCharacteristic:self.uartTxCharacteristic];
    }
    else if (!self.didGrantInitialUARTRxCredits)
    {
        // UART RX credits have to be granted to the peripheral in order to establish the TerminalIO connection
        [self grantLocalUARTCredits];
    }
    else
    {
        // TIO connection has been established
        self.isConnected = YES;
        self.isConnecting = NO;
        [self raiseDidConnect];
    }
}


- (void)handleTIOConnectionErrorWithMessage:(NSString *)message
{
    //STTraceMethod(self, @"handleTIOConnectionErrorWithMessage %@", message);
    
    [self cancelConnection];
    self.isConnecting = NO;
    
    NSError *error = [TIO errorWithCode:TIOConnectionError andMessage:message];
    [self raiseDidFailToConnectWithError:error];
}


- (void)discoverServices
{
    //STTraceMethod(self, @"discoverServices");
    
    // erase invalid characteristics instances
    self.uartTxCharacteristic	= nil;
    self.uartTxCreditsCharacteristic = nil;
    self.uartRxMtuCharacteristic = nil;
    self.uartTxMtuCharacteristic = nil;
    
    [self.cbPeripheral discoverServices: @[[TIO SERVICE_UUID]]];
}


- (void)discoverCharacteristics
{
    //STTraceMethod(self, @"discoverCharacteristics");
    
    [self.cbPeripheral discoverCharacteristics:@[[TIO UART_TX_UUID], [TIO UART_RX_UUID],
                                                 [TIO UART_TX_CREDITS_UUID],[TIO UART_RX_CREDITS_UUID],
                                                 [TIO UART_TX_MTU_UUID],[TIO UART_RX_MTU_UUID]
                                               ] forService:self.tioService];
}


- (void)subscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    //STTraceMethod(self, @"subscribeToCharacteristic %@", characteristic);
    
    [self.cbPeripheral setNotifyValue:YES forCharacteristic:characteristic];
}


- (void)grantLocalUARTCredits
{
    //STTraceMethod(self, @"grantLocalUARTCredits");
    
    if (self.pendingLocalUARTCreditsCount != 0)
        return;
    
    self.pendingLocalUARTCreditsCount = self.maxLocalUARTCreditsCount - self.localUARTCreditsCount;
    Byte value = (Byte) (self.pendingLocalUARTCreditsCount);
    NSData *valueData = [NSData dataWithBytes:&value length:1];
    [self.cbPeripheral writeValue:valueData forCharacteristic:self.uartRxCreditsCharacteristic type:CBCharacteristicWriteWithResponse];
}


- (void)grantLocalUARTMtuSize
{
    NSInteger mtuSize = self.pendingLocalUartMtuSize;
    NSData *valueData = [NSData dataWithBytes:&mtuSize length:2];
    
    //STTraceMethod(self, @"grantLocalUARTMtuSize [%@]", valueData);
    
    [self.cbPeripheral writeValue:valueData forCharacteristic:self.uartRxMtuCharacteristic type:CBCharacteristicWriteWithResponse];
}


- (void)launchUARTDataWritingOnBackgroundThread
{
    //STTraceMethod(self, @"launchUARTDataWritingOnBackgroundThread");
    
    // take care of thread safety of self.isWriting
    @synchronized(self.writeLock)
    {
        if (self.isWriting)
            return;
        
        self.isWriting = YES;
    }
    
    [self performSelectorInBackground:@selector(writeUARTDataBlocks) withObject:nil];
}


- (void)writeUARTDataBlocks
{
    //STTraceMethod(self, @"writeUARTDataBlocks");
    
    // we are in a background thread here and will loop sending as many data blocks as possible...
    do
    {
        // take care of thread safety of self.uartDataToBeWritten, self.isWriting and self.remoteUARTCreditsCount
        @synchronized(self.writeLock)
        {
            if (!self.isConnected)
            {
                self.isWriting = NO;
                break;
            }
            
            if (self.uartDataToBeWritten.length == 0)
            {
                // write buffer empty
                [self performSelectorOnMainThread:@selector(raiseUARTWriteBufferEmpty) withObject:nil waitUntilDone:NO];
                self.isWriting = NO;
                break;
            }
            if (self.remoteUARTCreditsCount == 0)
            {
                // no more UART credits for remote device
                self.isWriting = NO;
                break;
            }
            
            // get next data block
            NSData *data = [self getNextUARTDataBlock];
            // write data to UART characteristic without expecting a response
            //STTraceLine(@"  writing %d bytes", data.length);
            //STTraceLine(@"%@", data);
            
            [self.cbPeripheral writeValue:data forCharacteristic:self.uartRxCharacteristic type:CBCharacteristicWriteWithoutResponse];
            
            self.remoteUARTCreditsCount--;
            // notify upper layer in main thread
            [self performSelectorOnMainThread:@selector(raiseDidWriteNumberOfUARTBytes:) withObject: [NSNumber numberWithLong: data.length] waitUntilDone:NO];
            [self performSelectorOnMainThread:@selector(raiseDidUpdateRemoteUARTCreditsCount:) withObject:[NSNumber numberWithLong:self.remoteUARTCreditsCount] waitUntilDone:NO];
        }
    } while (YES);
}


- (NSData *)getNextUARTDataBlock
{
    // determine length of next data block
    
    NSInteger maxLength = TIO_MAX_UART_DATA_SIZE;
    if (self.remoteUartMtuSize)
        maxLength = self.remoteUartMtuSize;
    NSInteger length = (self.uartDataToBeWritten.length > maxLength) ? maxLength : self.uartDataToBeWritten.length;
    
    // crop data to be written from buffer
    NSData *data = [self.uartDataToBeWritten subdataWithRange:NSMakeRange(0, length)];
    [self.uartDataToBeWritten replaceBytesInRange:NSMakeRange(0, length) withBytes:NULL length:0];
    
    return data;
}


#pragma mark - CBPeripheralDelegate implementation

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //STTraceMethod(self, @"didDiscoverServices, error %@", error);
    
    self.tioService	 = nil;
    for (CBService *service in self.cbPeripheral.services)
    {
        //STTraceLine(@"discovered service %@", service.UUID);
        if ([service.UUID isEqual: [TIO SERVICE_UUID]])
        {
            //STTraceLine(@"TIO service discovered");
            // memorize iOS service instance
            self.tioService = service;
            break;
        }
    }
    
    if (self.tioService == nil)
    {
        // the remote module does not provide the TIO service (should not occur...)
        [self handleTIOConnectionErrorWithMessage:@"TIO service not discovered."];
        return;
    }
    
    // TIO service has been discovered; proceed with TIO connection establishment
    [self processTIOConnection];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    //STTraceMethod(self, @"didDiscoverCharacteristicsForService, error %@", error);
    
    for (CBCharacteristic *characteristic in service.characteristics)
    {
        //STTraceLine(@"found characteristic %@", characteristic.UUID);
        if ([characteristic.UUID isEqual:[TIO UART_TX_UUID]])
        {
            //STTraceLine(@"UART_TX characteristic found, properties = %@", [TIO characteristicsPropertiesToString:characteristic.properties]);
            self.uartTxCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:[TIO UART_TX_CREDITS_UUID]])
        {
            //STTraceLine(@"UART_TX_CREDITS characteristic found, properties = %@", [TIO characteristicsPropertiesToString:characteristic.properties]);
            self.uartTxCreditsCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:[TIO UART_RX_UUID]])
        {
            //STTraceLine(@"UART_RX characteristic found, properties = %@", [TIO characteristicsPropertiesToString:characteristic.properties]);
            self.uartRxCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:[TIO UART_RX_CREDITS_UUID]])
        {
            //STTraceLine(@"UART_RX CREDITS characteristic found, properties = %@", [TIO characteristicsPropertiesToString:characteristic.properties]);
            self.uartRxCreditsCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:[TIO UART_RX_MTU_UUID]])
        {
            //STTraceLine(@"UART_RX MTU characteristic found, properties = %@", [TIO characteristicsPropertiesToString:characteristic.properties]);
            self.uartRxMtuCharacteristic = characteristic;
        }
        else if ([characteristic.UUID isEqual:[TIO UART_TX_MTU_UUID]])
        {
            //STTraceLine(@"UART_TX MTU characteristic found, properties = %@", [TIO characteristicsPropertiesToString:characteristic.properties]);
            self.uartTxMtuCharacteristic = characteristic;
        }
    }
    
    if (self.uartTxCharacteristic == nil || self.uartTxCreditsCharacteristic == nil || self.uartRxCharacteristic == nil || self.uartRxCreditsCharacteristic == nil)
    {
        // the remote module does not provide mandatory TIO characteristics (should not occur...)
        [self handleTIOConnectionErrorWithMessage:@"TIO characteristics missing."];
        
        return;
    }
    
    // TIO characteristics have been discovered; proceed with TIO connection establishment
    [self processTIOConnection];
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //STTraceMethod(self, @"didUpdateNotificationStateForCharacteristic %@, error %@", characteristic.UUID, error);
    
    if (error != nil)
    {
        // an error occurred while subscribing for notifications; cancel connection process
        [self handleTIOConnectionErrorWithMessage:[NSString stringWithFormat: @"Failed to subscribe for %@.", characteristic]];
        return;
    }
    
    if ([characteristic.UUID isEqual:[TIO UART_TX_UUID]])
    {
        //STTraceLine(@"  subscribed to UART characteristic");
        self.didSubscribeUARTTx = YES;
    }
    else if ([characteristic.UUID isEqual:[TIO UART_TX_CREDITS_UUID]])
    {
        //STTraceLine(@"  subscribed to UART_CREDITS characteristic");
        self.didSubscribeUARTTxCredits = YES;
    }
    else if ([characteristic.UUID isEqual:[TIO UART_TX_MTU_UUID]])
    {
        // STTraceLine(@"  subscribed to UART_MTU characteristic");
        self.didSubscribeUARTTxMtu = YES;
    }
    
    // proceed with TIO connection establishment
    [self processTIOConnection];
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //STTraceMethod(self, @"didUpdateValueForCharacteristic %@, value %@, error %@", characteristic.UUID, characteristic.value, error);
    
    if ([characteristic.UUID isEqual:[TIO UART_TX_UUID]])
    {
        // the remote device has sent UART data
        if (error == nil)
        {
            [self raiseDidReceiveUARTData:characteristic.value];
        }
        
        // by sending this UART data packet, the remote device has consumed one of the granted local credits
        self.localUARTCreditsCount--;
        [self raiseDidUpdateLocalUARTCreditsCount:[NSNumber numberWithLong:self.localUARTCreditsCount]];
        
        // check pending local UART MTU size
        if(self.pendingLocalUartMtuSize)
        {
            if(self.localUARTCreditsCount == 0)
            {
                // grant local UART MTU size
                [self grantLocalUARTMtuSize];
            }
        }
        else if (self.localUARTCreditsCount <= self.minLocalUARTCreditsCount)
        {
            // grant a reasonable amount of new credits before an underrun occurs on the remote device
            [self grantLocalUARTCredits];
        }
    }
    else if ([characteristic.UUID isEqual:[TIO UART_TX_CREDITS_UUID]])
    {
        // the remote device has granted additional UART credits
        if (error == nil)
        {
            // extract credits count from characteristic value
            Byte *value = (Byte *) characteristic.value.bytes;
            Byte creditCount = value[0];
            // add received credits to counter taking care of write thread safety
            @synchronized (self.writeLock)
            {
                self.remoteUARTCreditsCount += creditCount;
                if (self.remoteUARTCreditsCount > TIO_MAX_UART_CREDITS_COUNT)
                {
                    //STTraceError(@"invalid remote UART credit count %d", self.remoteUARTCreditsCount);
                    self.remoteUARTCreditsCount = TIO_MAX_UART_CREDITS_COUNT;
                }
                [self raiseDidUpdateRemoteUARTCreditsCount:[NSNumber numberWithLong:self.remoteUARTCreditsCount]];
            }
            // trigger writing if required
            [self launchUARTDataWritingOnBackgroundThread];
        }
    }
    else if ([characteristic.UUID isEqual:[TIO UART_TX_MTU_UUID]])
    {
        // the remote device has provided UART MTU size
        if (error == nil)
        {
            // extract UART MTU size from characteristic value
            int value = *(int*)(characteristic.value.bytes);
            
            // taking care of write thread safety
            @synchronized (self.writeLock)
            {
                // set new UART MTU size
                self->_remoteUartMtuSize = value;
                self.pendingLocalUartMtuSize = self.remoteUartMtuSize;
                
                [self raiseDidUpdateRemoteUARTMtuSize:[NSNumber numberWithLong:self.remoteUartMtuSize]];
            }
            
            if(self.localUARTCreditsCount == 0)
            {
                // grant local UART MTU size
                [self grantLocalUARTMtuSize];
            }
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //STTraceMethod(self, @"didWriteValueForCharacteristic %@, error %@", characteristic.UUID, error);
    
    if ([characteristic.UUID isEqual:[TIO UART_RX_CREDITS_UUID]])
    {
        if (error == nil)
        {
            // granting of local credits to remote device was successful
            if (self.isConnecting)
            {
                self.didGrantInitialUARTRxCredits = YES;
                [self processTIOConnection];
            }
            
            self.localUARTCreditsCount += self.pendingLocalUARTCreditsCount;
            self.pendingLocalUARTCreditsCount = 0;
            [self raiseDidUpdateLocalUARTCreditsCount:[NSNumber numberWithLong:self.localUARTCreditsCount]];
        }
        else
        {
            if (self.isConnecting)
            {
                // an error occurred while granting intital UART credits to the remote device; cancel connection process
                [self handleTIOConnectionErrorWithMessage:[NSString stringWithFormat: @"Failed to grant initial UART credits."]];
                return;
            }
        }
    }
    if ([characteristic.UUID isEqual:[TIO UART_RX_MTU_UUID]])
    {
        if (error == nil)
        {
            // granting of local UART mtu size to remote device was successful
            self->_localUartMtuSize = self.pendingLocalUartMtuSize;
            self.pendingLocalUartMtuSize = 0;
            
            [self raiseDidUpdateLocalUARTMtuSize:[NSNumber numberWithLong:self.localUartMtuSize]];
            
            if (!self.didGrantInitialLocalUARTMtuSize)
            {
                self.didGrantInitialLocalUARTMtuSize = YES;
            }
            else
            {
                // reset local uart credits counter
                self.maxLocalUARTCreditsCount = TIO_MAX_UART_CREDITS_COUNT;
                self.minLocalUARTCreditsCount = MIN_UART_CREDITS_COUNT;
                self.pendingLocalUARTCreditsCount = 0;
                self.localUARTCreditsCount = 0;
                
                // grant a reasonable amount of new credits before an underrun occurs on the remote device
                [self grantLocalUARTCredits];
            }
        }
        else
        {
            if (self.isConnecting)
            {
                // an error occurred while granting intital UART credits to the remote device; cancel connection process
                [self handleTIOConnectionErrorWithMessage:[NSString stringWithFormat: @"Failed to grant local UART mtu size."]];
                return;
            }
        }
    }
}


- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    //	STTraceMethod(self, @"didUpdateRSSI %@, error %@", peripheral.RSSI, error);
    
    if (error != nil)
        return;
    
    [self raiseDidUpdateRSSI:peripheral.RSSI];
}


#pragma mark - Delegate events

- (void)raiseDidConnect
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheralDidConnect:)])
        [self.delegate tioPeripheralDidConnect:self];
}

- (void)raiseDidFailToConnectWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didFailToConnectWithError:)])
        [self.delegate tioPeripheral:self didFailToConnectWithError:error];
}

- (void)raiseDidDisconnectWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didDisconnectWithError:)])
        [self.delegate tioPeripheral:self didDisconnectWithError:error];
}

- (void)raiseDidReceiveUARTData:(NSData *)data
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didReceiveUARTData:)])
        [self.delegate tioPeripheral:self didReceiveUARTData:data];
}

- (void)raiseDidWriteNumberOfUARTBytes:(NSNumber *)bytesWritten
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didWriteNumberOfUARTBytes:)])
        [self.delegate tioPeripheral:self didWriteNumberOfUARTBytes:bytesWritten.intValue];
}

- (void)raiseUARTWriteBufferEmpty
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheralUARTWriteBufferEmpty:)])
        [self.delegate tioPeripheralUARTWriteBufferEmpty:self];
}

- (void)raiseDidUpdateRSSI:(NSNumber *)rssi
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didUpdateRSSI:)])
        [self.delegate tioPeripheral:self didUpdateRSSI:rssi];
}

- (void)raiseDidUpdateLocalUARTCreditsCount:(NSNumber *)creditsCount
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didUpdateLocalUARTCreditsCount:)])
        [self.delegate tioPeripheral:self didUpdateLocalUARTCreditsCount:creditsCount];
}

- (void)raiseDidUpdateRemoteUARTCreditsCount:(NSNumber *)creditsCount
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didUpdateRemoteUARTCreditsCount:)])
        [self.delegate tioPeripheral:self didUpdateRemoteUARTCreditsCount:creditsCount];
}

- (void)raiseDidUpdateLocalUARTMtuSize:(NSNumber *)mtuSize
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didUpdateLocalUARTMtuSize:)])
        [self.delegate tioPeripheral:self didUpdateLocalUARTMtuSize:mtuSize];
}

- (void)raiseDidUpdateRemoteUARTMtuSize:(NSNumber *)mtuSize
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheral:didUpdateRemoteUARTMtuSize:)])
        [self.delegate tioPeripheral:self didUpdateRemoteUARTMtuSize:mtuSize];
}

- (void)raiseDidUpdateAdvertisement
{
    if ([self.delegate respondsToSelector:@selector(tioPeripheralDidUpdateAdvertisement:)])
        [self.delegate tioPeripheralDidUpdateAdvertisement:self];
}


#pragma mark - Internal interface towards TIOManager

+ (TIOPeripheral *)peripheralWithCBPeripheral:(CBPeripheral *)cbPeripheral
{
    return [[TIOPeripheral alloc] initWithCBPeripheral:cbPeripheral andAdvertisement:nil];
}


+ (TIOPeripheral *)peripheralWithCBPeripheral:(CBPeripheral *)cbPeripheral andAdvertisement:(TIOAdvertisement *)advertisement
{
    return [[TIOPeripheral alloc] initWithCBPeripheral:cbPeripheral andAdvertisement:advertisement];
}


- (void)didConnect
{
    //STTraceMethod(self, @"didConnect");
    
    [self processTIOConnection];
}


- (void)didFailToConnectWithError:(NSError *)error
{
    //STTraceMethod(self, @"didFailtoConnectWithError %@", error);
    
    self.isConnected = NO;
    self.isConnecting = NO;
    [self raiseDidFailToConnectWithError:error];
}


- (void)didDisconnectWithError:(NSError *)error
{
    //STTraceMethod(self, @"didDisconnectWithError %@", error);
    
    self.isConnected = NO;
    self.isConnecting = NO;
    
    self.localUARTCreditsCount = 0;
    @synchronized (self.writeLock)
    {
        self.remoteUARTCreditsCount = 0;
        self.uartDataToBeWritten = nil;
    }
    [self raiseDidUpdateLocalUARTCreditsCount:[NSNumber numberWithLong:self.localUARTCreditsCount]];
    [self raiseDidUpdateRemoteUARTCreditsCount:[NSNumber numberWithLong:self.remoteUARTCreditsCount]];
    
    self->_remoteUartMtuSize = TIO_MAX_UART_DATA_SIZE;
    self->_localUartMtuSize  = TIO_MAX_UART_DATA_SIZE;
    
    [self raiseDidUpdateRemoteUARTMtuSize:[NSNumber numberWithLong:self.remoteUartMtuSize]];
    [self raiseDidUpdateLocalUARTMtuSize:[NSNumber numberWithLong:self.localUartMtuSize]];
    
    [self raiseDidDisconnectWithError:error];
}


- (BOOL)updateWithAdvertisement:(TIOAdvertisement *)advertisement
{
    //STTraceMethod(self, @"updateWithAdvertisement %@", advertisement);
    
    BOOL result = NO;
    if (![self.advertisement isEqualToAdvertisement:advertisement])
    {
        self.advertisement = advertisement;
        result = YES;
        [self raiseDidUpdateAdvertisement];
    }
    
    return result;
}


@end


