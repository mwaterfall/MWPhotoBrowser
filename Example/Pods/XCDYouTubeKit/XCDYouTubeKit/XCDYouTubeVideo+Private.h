//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#import <XCDYouTubeKit/XCDYouTubeVideo.h>

#import "XCDYouTubePlayerScript.h"

#define XCDYouTubeErrorUseCipherSignature -1000

extern NSString *const XCDYouTubeNoStreamVideoUserInfoKey;

extern NSDictionary *XCDDictionaryWithQueryString(NSString *string);
extern NSString *XCDQueryStringWithDictionary(NSDictionary *dictionary);

@interface XCDYouTubeVideo ()

- (instancetype) initWithIdentifier:(NSString *)identifier info:(NSDictionary *)info playerScript:(XCDYouTubePlayerScript *)playerScript response:(NSURLResponse *)response error:(NSError **)error;

- (void) mergeVideo:(XCDYouTubeVideo *)video;

@end
