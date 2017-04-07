//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import "XCDYouTubeLogger.h"

#import <objc/runtime.h>

const NSInteger XCDYouTubeKitLumberjackContext = (NSInteger)0xced70676;

@protocol XCDYouTubeLogger_DDLog
// Copied from CocoaLumberjack's DDLog interface
+ (void) log:(BOOL)asynchronous message:(NSString *)message level:(NSUInteger)level flag:(NSUInteger)flag context:(NSInteger)context file:(const char *)file function:(const char *)function line:(NSUInteger)line tag:(id)tag;
@end

static Class DDLogClass = Nil;

static void (^const CocoaLumberjackLogHandler)(NSString * (^)(void), XCDLogLevel, const char *, const char *, NSUInteger) = ^(NSString *(^message)(void), XCDLogLevel level, const char *file, const char *function, NSUInteger line)
{
	// The `XCDLogLevel` enum was carefully crafted to match the `DDLogFlag` options from DDLog.h
	[DDLogClass log:YES message:message() level:NSUIntegerMax flag:(1 << level) context:XCDYouTubeKitLumberjackContext file:file function:function line:line tag:nil];
};

static void (^LogHandler)(NSString * (^)(void), XCDLogLevel, const char *, const char *, NSUInteger) = ^(NSString *(^message)(void), XCDLogLevel level, const char *file, const char *function, NSUInteger line)
{
	char *logLevelString = getenv("XCDYouTubeKitLogLevel");
	NSUInteger logLevelMask = logLevelString ? strtoul(logLevelString, NULL, 0) : (1 << XCDLogLevelError) | (1 << XCDLogLevelWarning);
	if ((1 << level) & logLevelMask)
		NSLog(@"[XCDYouTubeKit] %@", message());
};

@implementation XCDYouTubeLogger

+ (void) initialize
{
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		DDLogClass = objc_lookUpClass("DDLog");
		if (DDLogClass)
		{
			const SEL logSeletor = @selector(log:message:level:flag:context:file:function:line:tag:);
			const char *typeEncoding = method_getTypeEncoding(class_getClassMethod(DDLogClass, logSeletor));
			const char *expectedTypeEncoding = protocol_getMethodDescription(@protocol(XCDYouTubeLogger_DDLog), logSeletor, /* isRequiredMethod: */ YES, /* isInstanceMethod: */ NO).types;
			if (typeEncoding && expectedTypeEncoding && strcmp(typeEncoding, expectedTypeEncoding) == 0)
				LogHandler = CocoaLumberjackLogHandler;
			else
				NSLog(@"[XCDYouTubeKit] Incompatible CocoaLumberjack version. Expected \"%@\", got \"%@\".", expectedTypeEncoding ? @(expectedTypeEncoding) : @"", typeEncoding ? @(typeEncoding) : @"");
		}
	});
}

+ (void) setLogHandler:(void (^)(NSString * (^message)(void), XCDLogLevel level, const char *file, const char *function, NSUInteger line))logHandler
{
	LogHandler = logHandler;
}

+ (void) logMessage:(NSString * (^)(void))message level:(XCDLogLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line
{
	if (LogHandler)
		LogHandler(message, level, file, function, line);
}

@end
