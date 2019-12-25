//
//  Copyright (c) 2013-2016 Cédric Luthi. All rights reserved.
//

#if !__has_feature(nullability)
#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define nullable
#define __nullable
#endif

#import <Foundation/Foundation.h>

#import <XCDYouTubeKit/XCDYouTubeOperation.h>
#import <XCDYouTubeKit/XCDYouTubeVideo.h>
#import <XCDYouTubeKit/XCDYouTubeError.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  The `XCDYouTubeClient` class is responsible for interacting with the YouTube API. Given a YouTube video identifier, you will get video information with the `<-getVideoWithIdentifier:completionHandler:>` method.
 *
 *  On iOS, you probably don’t want to use `XCDYouTubeClient` directly but the higher level class `<XCDYouTubeVideoPlayerViewController>`.
 */
@interface XCDYouTubeClient : NSObject

/**
 *  ------------------
 *  @name Initializing
 *  ------------------
 */

/**
 *  Returns the shared client with the default language, i.e. the preferred language of the main bundle.
 *
 *  @return The default client.
 */
+ (instancetype) defaultClient;

/**
 *  Initializes a client with the specified language identifier.
 *
 *  @param languageIdentifier An [ISO 639-1 two-letter language code](http://www.loc.gov/standards/iso639-2/php/code_list.php) used for error localization. If you pass a nil language identifier, the preferred language of the main bundle will be used.
 *
 *  @return A client with the specified language identifier.
 */
- (instancetype) initWithLanguageIdentifier:(nullable NSString *)languageIdentifier;

/**
 *  ---------------------------------
 *  @name Accessing client properties
 *  ---------------------------------
 */

/**
 *  The language identifier of the client, used for error localization.
 *
 *  @see -initWithLanguageIdentifier:
 */
@property (nonatomic, readonly) NSString *languageIdentifier;

/**
 *  --------------------------------------
 *  @name Interacting with the YouTube API
 *  --------------------------------------
 */

/**
 *  Starts an asynchronous operation for the specified video identifier, and calls a handler upon completion.
 *
 *  @param videoIdentifier   A 11 characters YouTube video identifier. If the video identifier is invalid (including nil) the completion handler will be called with an error with `XCDYouTubeVideoErrorDomain` domain and `XCDYouTubeErrorInvalidVideoIdentifier` code.
 *  @param completionHandler A block to execute when the client finishes the operation. The completion handler is executed on the main thread. If the completion handler is nil, this method throws an exception.
 *
 *  @discussion If the operation completes successfully, the video parameter of the handler block contains a `<XCDYouTubeVideo>` object, and the error parameter is nil. If the operation fails, the video parameter is nil and the error parameter contains information about the failure. The error's domain is always `XCDYouTubeVideoErrorDomain`.
 *
 *  @see XCDYouTubeErrorCode
 *
 *  @return An opaque object conforming to the `<XCDYouTubeOperation>` protocol for canceling the asynchronous video information operation. If you call the `cancel` method before the operation is finished, the completion handler will not be called. It is recommended that you store this opaque object as a weak property.
 */
- (id<XCDYouTubeOperation>) getVideoWithIdentifier:(nullable NSString *)videoIdentifier completionHandler:(void (^)(XCDYouTubeVideo * __nullable video, NSError * __nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
