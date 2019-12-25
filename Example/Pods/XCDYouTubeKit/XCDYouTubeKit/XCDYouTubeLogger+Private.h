//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XCDYouTubeLogger.h"

@interface XCDYouTubeLogger ()

+ (void) logMessage:(NSString * (^)(void))message level:(XCDLogLevel)level file:(const char *)file function:(const char *)function line:(NSUInteger)line;

@end

#define XCDYouTubeLog(_level, _message) [XCDYouTubeLogger logMessage:(_message) level:(_level) file:__FILE__ function:__PRETTY_FUNCTION__ line:__LINE__]

#define XCDYouTubeLogError(format, ...)   XCDYouTubeLog(XCDLogLevelError,   (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
#define XCDYouTubeLogWarning(format, ...) XCDYouTubeLog(XCDLogLevelWarning, (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
#define XCDYouTubeLogInfo(format, ...)    XCDYouTubeLog(XCDLogLevelInfo,    (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
#define XCDYouTubeLogDebug(format, ...)   XCDYouTubeLog(XCDLogLevelDebug,   (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
#define XCDYouTubeLogVerbose(format, ...) XCDYouTubeLog(XCDLogLevelVerbose, (^{ return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }))
