//
//  TIO.h
//  TerminalIO
//
//  Created by Telit
//  Copyright (c) Telit Wireless Solutions GmbH, Germany
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


extern NSInteger const TIO_MAX_UART_DATA_SIZE;
extern NSInteger const TIO_MAX_UART_CREDITS_COUNT;


/**
 *  TerminalIO peripheral operation mode constants.
 */
typedef NS_ENUM(NSInteger, TIOPeripheralOperationMode)
{
	/**
	 *  The peripheral is (temporarily) in bonding operation mode. A central shall perform the specified bonding procedure when connecting.
	 */
	TIOPeripheralOpModeBondingOnly = 0x0,
	/**
	 *  The peripheral is in functional operation mode. A central may connect in order to transmit and receive UART data (or GPIO states, if supported).
	 */
	TIOPeripheralOpModeFunctional = 0x1,
	/**
	 *  The peripheral is in bondable and functional mode. A central may connect and perform the specified bonding procedure or transmit and receive UART data (or GPIO states, if supported).
	 */
	TIOPeripheralOpModeBondableFunctional = 0x10,
};

/**
 *  TerminalIO error constants.
 */
typedef NS_ENUM(NSInteger, TIOErrorCode)
{
	/**
	 *  The operation terminated successfully.
	 */
	TIOSuccess = 0x0,
	/**
	 *  An error occurred during the specified TerminalIO connection establishment.
	 */
	TIOConnectionError = 0x1,
};


/**
 *  The TIO class is purely static and provides TerminalIO specific UUID instances and utility functions.
 */
@interface TIO : NSObject

///@{
/// @name Using TerminalIO specific UUID instances

/**
 *  Returns the TerminalIO service UUID.
 *  @return A CBUUID instance containing the TerminalIO service UUID.
 */
+ (CBUUID *)SERVICE_UUID;

/**
 *  Returns the TerminalIO UART_RX characteristic UUID.
 *
 *  This characteristic is used by the central to transmit UART data to the peripheral.
 *  @return A CBUUID instance containing the TerminalIO UART_RX characteristic UUID.
 */
+ (CBUUID *)UART_RX_UUID;

/**
 *  Returns the TerminalIO UART_TX characteristic UUID.
 *
 *  This characteristic is used by the peripheral to transmit UART data to the central.
 *  @return A CBUUID instance containing the TerminalIO UART_TX characteristic UUID.
 */
+ (CBUUID *)UART_TX_UUID;

/**
 *  Returns the TerminalIO UART_RX_CREDITS characteristic UUID.
 *
 *  This characteristic is used by the central to grant UART credits to the peripheral.
 *  @return A CBUUID instance containing the TerminalIO UART_RX_CREDITS characteristic UUID.
 */
+ (CBUUID *)UART_RX_CREDITS_UUID;

/**
 *  Returns the TerminalIO UART_TX_CREDITS characteristic UUID.
 *
 *  This characteristic is used by the peripheral to grant UART credits to the central.
 *  @return A CBUUID instance containing the TerminalIO UART_TX_CREDITS characteristic UUID.
 */
+ (CBUUID *)UART_TX_CREDITS_UUID;

/**
 *  Returns the TerminalIO UART_RX_MTU_UUID characteristic UUID.
 *
 *  This characteristic is used by the central to MTU size negotitation for UART data.
 *  @return A CBUUID instance containing the TerminalIO UART_RX_MTU_UUID characteristic UUID.
 */
+ (CBUUID *)UART_RX_MTU_UUID;

/**
 *  Returns the TerminalIO UART_TX_MTU_UUID characteristic UUID.
 *
 *  This characteristic is used by the central to MTU size negotitation for UART data.
 *  @return A CBUUID instance containing the TerminalIO UART_TX_MTU_UUID characteristic UUID.
 */
+ (CBUUID *)UART_TX_MTU_UUID;

///@}


///@{
/// @name Utility Functions

/**
 *  Returns an error object containing the specified TIOErrorCode and a text message.
 *
 *  This utlitity creates TerminalIO specific NSError instances that can be used in combination with or alternatively to NSError instances returned by CoreBluetooth functions.
 *  @param code TIOErrorCode to include in the resulting error object.
 *  @param message Error message to include in the resulting error object.
 *  @return An NSError instance containing the specified parameters.
 */
+ (NSError *)errorWithCode:(TIOErrorCode)code andMessage:(NSString *)message;

/**
 *  Returns a full path for persistent storage of application specific data with the specified file name.
 *
 *  This utility function can be used to create a full path for persistent object serialization.
 *  @param fileName File name to use with the created path.
 *  @return An NSString instance containing the created path.
 */
+ (NSString *)pathWithFileName:(NSString *)fileName;

///@}


///@{
/// @name Creating String Representations of Various Constants

/**
 *  Provides a text representation of the specified Boolean value.
 *  @param value Boolean value to transform into a text representation.
 *  @return "YES" if value is YES, "NO" otherwise.
 */
+ (NSString *)boolToString:(BOOL)value;

/**
 *  Provides a text representation of the specified TIOPeripheralOperationMode constant.
 *  @param operationMode TIOPeripheralOperationMode to transform into a text representation.
 *  @return An NSString instance containing the requested text representation.
 */
+ (NSString *)operationModeToString:(TIOPeripheralOperationMode)operationMode;

/**
 *  Provides a text representation of the specified TIOErrorCode constant.
 *  @param errorCode TIOErrorCode to transform into a text representation.
 *  @return An NSString instance containing the requested text representation.
 */
+ (NSString *)errorCodeToString:(TIOErrorCode)errorCode;

/**
 *  Provides a text representation of the specified CBCharacteristicProperties flags.
 *  @param properties CBCharacteristicProperties flags to transform into a text representation.
 *  @return An NSString instance containing the requested text representation.
 */
+ (NSString *)characteristicsPropertiesToString:(CBCharacteristicProperties)properties;

///@}

@end
