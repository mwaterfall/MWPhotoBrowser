//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The [context][1] used when logging with CocoaLumberjack.
 *  
 *  [1]: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomContext.md
 */
extern const NSInteger XCDYouTubeKitLumberjackContext;

/**
 *  The log levels, closely mirroring the log levels of CocoaLumberjack.
 */
typedef NS_ENUM(NSUInteger, XCDLogLevel) {
	/**
	 *  Used when an error is produced, e.g. when a `<XCDYouTubeVideoOperation>` finishes with an error.
	 */
	XCDLogLevelError   = 0,
	
	/**
	 *  Used on unusual conditions that may eventually lead to an error.
	 */
	XCDLogLevelWarning = 1,
	
	/**
	 *  Used when logging normal operational information, e.g. when a `<XCDYouTubeVideoOperation>` starts, is cancelled or finishes.
	 */
	XCDLogLevelInfo    = 2,
	
	/**
	 *  Used throughout a `<XCDYouTubeVideoOperation>` for debugging purpose, e.g. for HTTP requests.
	 */
	XCDLogLevelDebug   = 3,
	
	/**
	 *  Used to report large amount of information, e.g. full HTTP responses.
	 */
	XCDLogLevelVerbose = 4,
};

/**
 *  You can use the `XCDYouTubeLogger` class to configure how the XCDYouTubeKit framework emits logs.
 *  
 *  By default, logs are emitted through CocoaLumberjack if it is available, i.e. if the `DDLog` class is found at runtime.
 *  The [context][1] used for CocoaLumberjack is the `XCDYouTubeKitLumberjackContext` constant whose value is `(NSInteger)0xced70676`.
 *  
 *  If CocoaLumberjack is not available, logs are emitted with `NSLog`, prefixed with the `[XCDYouTubeKit]` string.
 *  
 *  ## Controlling log levels
 *  
 *  If you are using CocoaLumberjack, you are responsible for controlling the log levels with the CocoaLumberjack APIs.
 *  
 *  If you are not using CocoaLumberjack, you can control the log levels with the `XCDYouTubeKitLogLevel` environment variable. See also the `<XCDLogLevel>` enum.
 *  
 *  Level   | Value | Mask
 *  --------|-------|------
 *  Error   |   0   | 0x01
 *  Warning |   1   | 0x02
 *  Info    |   2   | 0x04
 *  Debug   |   3   | 0x08
 *  Verbose |   4   | 0x10
 *  
 *  Use the corresponding bitmask to combine levels. For example, if you want to log *error*, *warning* and *info* levels, set the `XCDYouTubeKitLogLevel` environment variable to `0x7` (0x01 | 0x02 | 0x04).
 *  
 *  If you do not set the `XCDYouTubeKitLogLevel` environment variable, only warning and error levels are logged.
 *  
 *  [1]: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Documentation/CustomContext.md
 */
@interface XCDYouTubeLogger : NSObject

/**
 *  -------------------
 *  @name Custom Logger
 *  -------------------
 */

/**
 *  If you prefer not to use CocoaLumberjack and want something more advanced than the default `NSLog` implementation, you can use this method to write your own logger.
 *  
 *  @param logHandler The block called when a log is emitted by the XCDYouTubeKit framework. If you set the log handler to nil, logging will be completely disabled.
 *  
 *  @discussion Here is a description of the log handler parameters.
 *  
 *  - The `message` parameter is a block returning a string that you must call to evaluate the log message.
 *  - The `level` parameter is the log level of the message, see `<XCDLogLevel>`.
 *  - The `file` parameter is the full path of the file, captured with the `__FILE__` macro where the log is emitted.
 *  - The `function` parameter is the function name, captured with the `__PRETTY_FUNCTION__` macro where the log is emitted.
 *  - The `line` parameter is the line number, captured with the `__LINE__` macro where the log is emitted.
 *  
 *  Here is how you could implement a custom log handler with [NSLogger](https://github.com/fpillet/NSLogger):
 *  
 *  ```
 *  [XCDYouTubeLogger setLogHandler:^(NSString * (^message)(void), XCDLogLevel level, const char *file, const char *function, NSUInteger line) {
 *  	LogMessageRawF(file, (int)line, function, @"XCDYouTubeKit", (int)level, message());
 *  }];
 *  ```
 */
+ (void) setLogHandler:(void (^)(NSString * (^message)(void), XCDLogLevel level, const char *file, const char *function, NSUInteger line))logHandler;

@end
