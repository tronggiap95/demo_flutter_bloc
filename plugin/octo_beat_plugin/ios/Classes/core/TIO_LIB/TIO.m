//
//  TIO.m
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) Telit Wireless Solutions GmbH, Germany
//

#import "TIO.h"


NSString *const TIO_SERVICE_UUID = @"FEFB";
NSString *const TIO_UART_RX_UUID = @"00000001-0000-1000-8000-008025000000";
NSString *const TIO_UART_TX_UUID = @"00000002-0000-1000-8000-008025000000";
NSString *const TIO_UART_RX_CREDITS_UUID = @"00000003-0000-1000-8000-008025000000";
NSString *const TIO_UART_TX_CREDITS_UUID = @"00000004-0000-1000-8000-008025000000";
NSString *const TIO_UART_RX_MTU_UUID = @"00000009-0000-1000-8000-008025000000";
NSString *const TIO_UART_TX_MTU_UUID = @"0000000A-0000-1000-8000-008025000000";

NSInteger const TIO_MAX_UART_DATA_SIZE = 20;
NSInteger const TIO_MAX_UART_CREDITS_COUNT = 255;

NSString *const TIO_ERROR_DOMAIN = @"TIOErrorDomain";


@interface TIO ()


@end



@implementation TIO

#pragma  mark - UUID objects

+ (CBUUID *)SERVICE_UUID
{
	static __strong CBUUID *_serviceUUID = nil;
	if (!_serviceUUID)
		_serviceUUID = [CBUUID UUIDWithString:TIO_SERVICE_UUID];
	return _serviceUUID;
}


+ (CBUUID *)UART_RX_UUID
{
	static __strong CBUUID *_uartRxUUID = nil;
	if (!_uartRxUUID)
		_uartRxUUID = [CBUUID UUIDWithString:TIO_UART_RX_UUID];
	return _uartRxUUID;
}


+ (CBUUID *)UART_TX_UUID
{
	static __strong CBUUID *_uartTxUUID = nil;
	if (!_uartTxUUID)
		_uartTxUUID = [CBUUID UUIDWithString:TIO_UART_TX_UUID];
	return _uartTxUUID;
}


+ (CBUUID *)UART_RX_CREDITS_UUID
{
	static __strong CBUUID *_uartRxCreditsUUID = nil;
	if (!_uartRxCreditsUUID)
		_uartRxCreditsUUID = [CBUUID UUIDWithString:TIO_UART_RX_CREDITS_UUID];
	return _uartRxCreditsUUID;
}


+ (CBUUID *)UART_TX_CREDITS_UUID
{
	static __strong CBUUID *_uartTxCreditsUUID = nil;
	if (!_uartTxCreditsUUID)
		_uartTxCreditsUUID = [CBUUID UUIDWithString:TIO_UART_TX_CREDITS_UUID];
	return _uartTxCreditsUUID;
}


+ (CBUUID *)UART_RX_MTU_UUID
{
    static __strong CBUUID *_uartRxMtuUUID = nil;
    if (!_uartRxMtuUUID)
        _uartRxMtuUUID = [CBUUID UUIDWithString:TIO_UART_RX_MTU_UUID];
    return _uartRxMtuUUID;
}


+ (CBUUID *)UART_TX_MTU_UUID
{
    static __strong CBUUID *_uartTxMtuUUID = nil;
    if (!_uartTxMtuUUID)
        _uartTxMtuUUID = [CBUUID UUIDWithString:TIO_UART_TX_MTU_UUID];
    return _uartTxMtuUUID;
}

#pragma mark - Utility methods

+ (NSError *)errorWithCode:(TIOErrorCode)code andMessage:(NSString *)message
{
	return [NSError errorWithDomain:TIO_ERROR_DOMAIN code:code userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
}


+ (NSString *)pathWithFileName:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return ([documentsDirectory stringByAppendingPathComponent:fileName]);
}


+ (NSString *)boolToString:(BOOL)value
{
	return (value ? @"YES" : @"NO");
}


+ (NSString *)operationModeToString:(TIOPeripheralOperationMode)operationMode
{
	switch (operationMode)
	{
		case 	TIOPeripheralOpModeBondingOnly:
			return @"BondingOnly";
		
		case TIOPeripheralOpModeFunctional:
			return @"Functional";
			
		case TIOPeripheralOpModeBondableFunctional:
			return @"BondableFunctional";
	}
	return @"Unknown";
}


+ (NSString *)errorCodeToString:(TIOErrorCode)errorCode
{
	switch (errorCode)
	{
		case TIOSuccess:
			return @"Success";

		case TIOConnectionError:
			return @"Connection error";
	}
	return @"Unknown";
}


+ (NSString *)characteristicsPropertiesToString:(CBCharacteristicProperties)properties
{
	NSString *result = @"";
	
	if (properties & CBCharacteristicPropertyBroadcast)
		result = [NSString stringWithFormat:@"%@, Broadcast", result];
	if (properties &CBCharacteristicPropertyRead)
		result = [NSString stringWithFormat:@"%@, Read", result];
	if (properties & CBCharacteristicPropertyWriteWithoutResponse)
		result = [NSString stringWithFormat:@"%@, WriteWithoutResponse", result];
	if (properties & CBCharacteristicPropertyWrite)
		result = [NSString stringWithFormat:@"%@, Write", result];
	if (properties & CBCharacteristicPropertyNotify)
		result = [NSString stringWithFormat:@"%@, Notify", result];
	if (properties & CBCharacteristicPropertyIndicate)
		result = [NSString stringWithFormat:@"%@, Indicate", result];
	if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites)
		result = [NSString stringWithFormat:@"%@, AuthenticatedSignedWrites", result];
	if (properties & CBCharacteristicPropertyExtendedProperties)
		result = [NSString stringWithFormat:@"%@, ExtendedProperties", result];
	if (properties & CBCharacteristicPropertyNotifyEncryptionRequired)
		result = [NSString stringWithFormat:@"%@, NotifyEncryptionRequired", result];
	if (properties & CBCharacteristicPropertyIndicateEncryptionRequired)
		result = [NSString stringWithFormat:@"%@, IndicateEncryptionRequired", result];
	
	if (result.length > 1)
		result = [result substringFromIndex:2];
	
	return result;
}

@end
