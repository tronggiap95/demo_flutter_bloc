//
//  TIOAdvertisement.m
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) 2013,2014 Telit Wireless Solutions GmbH
//

#import "TIOAdvertisement.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface TIOAdvertisement ()


@end


@implementation TIOAdvertisement

#pragma  mark - Intialization

- (TIOAdvertisement *)initWithData:(NSDictionary *)data
{
	self = [super init];
	if (self)
	{
		if (![self evaluateData:data])
			return nil;
	}
	return self;
}


#pragma  mark - Properties

- (void)setLocalName:(NSString *)localName
{
	self->_localName = localName;
}


- (void)setOperationMode:(TIOPeripheralOperationMode)operationMode
{
	self->_operationMode = operationMode;
}


- (void)setConnectionRequested:(BOOL)connectionRequested
{
	self->_connectionRequested = connectionRequested;
}


#pragma mark - Public methods

+ (TIOAdvertisement *)advertisementWithData:(NSDictionary *)data
{
	return [[TIOAdvertisement alloc] initWithData:data];
}


- (BOOL)isEqualToAdvertisement:(TIOAdvertisement *)advertisement
{
	if (![self.localName isEqualToString:advertisement.localName])
		return NO;
	if (self.connectionRequested != advertisement.connectionRequested)
		return NO;
	if (self.operationMode != advertisement.operationMode)
		return  NO;
	return YES;
}


- (NSString *)displayDescription
{
	NSString *description = [NSString stringWithFormat:@"%@  %@", self.localName, [TIO operationModeToString:self.operationMode]];
	if (self.connectionRequested)
		description = [NSString stringWithFormat:@"%@  connection requested", description];
	return description;
}


#pragma mark - Internal methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"<TIOAdvertisement: %p  localName = %@, connectionRequested = %@, operationMode = %@", self, self.localName, [TIO  boolToString:self.connectionRequested], [TIO operationModeToString:self.operationMode]];
}

- (BOOL)evaluateData:(NSDictionary *)data
{

	//STTraceMethod(self, @"evaluateData %@", data);
	
	BOOL result = FALSE;
	
	do
	{
		// Extract local name
		self.localName = [data objectForKey:CBAdvertisementDataLocalNameKey];
		// Extract manufacturer specific data.
		NSData *manufacturerData = [data objectForKey: CBAdvertisementDataManufacturerDataKey];
		// Check for valid length.
		if (manufacturerData.length < 7)
			break;
		// Cast data to byte array.
		Byte *bytes = (Byte*) manufacturerData.bytes;
		// Check for mandatory TerminalIO specific values.
		if (bytes[0] != 0x8f || bytes[1] != 0x0 || bytes[2] != 0x9 || bytes[3] != 0xb0)
			break;
		
		// Extract peripheral state information.
		self.connectionRequested = (bytes[6] == 1);
		self.operationMode = (TIOPeripheralOperationMode) bytes[5];
		
		result = TRUE;
		
	} while (FALSE);
	
	return result;
}

@end
