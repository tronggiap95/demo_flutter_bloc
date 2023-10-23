//
//  Trace.h
//  General
//
//  Created by Telit
//  Copyright (c) Telit Wireless Solutions GmbH, Germany
//

#import <Foundation/Foundation.h>


enum
{
	STTraceFlagsNone = 0,
	STTraceFlagsAll = NSUIntegerMax,
};


@protocol LogDelegate <NSObject>
- (void)loggerPrintedLine:(NSString *)line;
@end


@interface STLogger : NSObject

+ (STLogger*)sharedInstance;

@property (weak, nonatomic) NSObject<LogDelegate>* delegate;
@property (nonatomic) NSUInteger filterFlags;

@end


void STTraceLine(NSString *message, ...);
void STTraceMethod(NSObject *caller, NSString *functionName, ...);
void STTraceError(NSString *message, ...);

void STTraceLineWithFilter(NSUInteger filterFlags, NSString *message, ...);
void STTraceMethodWithFilter(NSUInteger filterFlags, NSObject *caller, NSString* functionName, ...);
void STTraceErrorWithFilter(NSUInteger filterFlags, NSString *message, ...);
