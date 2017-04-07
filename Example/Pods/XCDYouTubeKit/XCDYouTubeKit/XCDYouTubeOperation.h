//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  The `XCDYouTubeOperation` protocol is adopted by opaque objects returned by the `<-[XCDYouTubeClient getVideoWithIdentifier:completionHandler:]>` method.
 */
@protocol XCDYouTubeOperation <NSObject>

/**
 *  ---------------
 *  @name Canceling
 *  ---------------
 */

/**
 *  Cancels the operation. If the operation is already finished, does nothing.
 */
- (void) cancel;

@end
