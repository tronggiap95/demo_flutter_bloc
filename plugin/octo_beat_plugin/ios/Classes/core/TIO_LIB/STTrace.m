//
//  Trace.m
//  General
//
//  Created by Telit
//  Copyright (c) Telit Wireless Solutions GmbH
//

#import <asl.h>
#import "STTrace.h"


@interface STLogger()

@end


#if defined (DEBUG)
static void AddStderrOnce()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
				  ^{
					  //asl_add_log_file(NULL, STDERR_FILENO);
				  });
}
#endif


@implementation STLogger

+ (STLogger*) sharedInstance
{
	static __strong STLogger *_sharedInstance = nil;
	if (!_sharedInstance)
	{
		_sharedInstance = [[STLogger alloc] init];
		_sharedInstance->_filterFlags = NSUIntegerMax;
	}
	return _sharedInstance;
}

@synthesize delegate = _delegate;
@synthesize filterFlags = _filterFlags;

- (void)logLine:(NSString*)line withFilter:(NSUInteger)filterFlags
{
#if defined (DEBUG)
	if (filterFlags & self.filterFlags)
	{
		AddStderrOnce();
		asl_log(NULL, NULL, ASL_LEVEL_DEBUG, "%s", [line UTF8String]);
		[self.delegate loggerPrintedLine:line];
	}
#endif
}

@end




void STTraceLine(NSString *message, ...)
{
#if defined (DEBUG)
	va_list args;
	va_start(args, message);
	NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
	va_end(args);
	
	[[STLogger sharedInstance] logLine:[NSString stringWithFormat:@"%@", formattedMessage]withFilter:STTraceFlagsAll];
#endif
}


void STTraceMethod(NSObject *caller, NSString *functionName, ...)
{
#if defined (DEBUG)
	va_list args;
	va_start(args, functionName);
	NSString *formattedMessage = [[NSString alloc] initWithFormat:functionName arguments:args];
	va_end(args);
	
	[[STLogger sharedInstance] logLine:[NSString stringWithFormat:@"%@::%@", caller.class, formattedMessage]withFilter:STTraceFlagsAll];
#endif
}


void STTraceError(NSString *message, ...)
{
#if defined (DEBUG)
	va_list args;
	va_start(args, message);
	NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
	va_end(args);
	
	[[STLogger sharedInstance] logLine:[NSString stringWithFormat:@"! %@", formattedMessage]withFilter:STTraceFlagsAll];
#endif
}


void STTraceLineWithFilter(NSUInteger filterFlags, NSString *message, ...)
{
#if defined (DEBUG)
	va_list args;
	va_start(args, message);
	NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
	va_end(args);
	
	[[STLogger sharedInstance] logLine:[NSString stringWithFormat:@"%@", formattedMessage]withFilter:filterFlags];
#endif
}


void STTraceMethodWithFilter(NSUInteger filterFlags, NSObject *caller, NSString *functionName, ...)
{
#if defined (DEBUG)
	va_list args;
	va_start(args, functionName);
	NSString *formattedMessage = [[NSString alloc] initWithFormat:functionName arguments:args];
	va_end(args);
	
	[[STLogger sharedInstance] logLine:[NSString stringWithFormat:@"%@::%@", caller.class, formattedMessage]withFilter:filterFlags];
#endif
}


void STTraceErrorWithFilter(NSUInteger filterFlags, NSString *message, ...)
{
#if defined (DEBUG)
	va_list args;
	va_start(args, message);
	NSString *formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
	va_end(args);
	
	[[STLogger sharedInstance] logLine:[NSString stringWithFormat:@"! %@", formattedMessage]withFilter:filterFlags];
#endif
}










