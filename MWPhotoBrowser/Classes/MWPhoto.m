//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "SDWebImageDecoder.h"
#import "SDWebImageManager.h"
#import "SDWebImageDownloaderOperation.h"

// Private
@interface MWPhoto () {

    // Image Sources
    NSString *_photoPath;
    NSURL *_photoURL;

    // Image
    UIImage *_underlyingImage;

    // Other
    NSString *_caption;
    BOOL _loadingInProgress;
    
    SDWebImageDownloaderOperation* _dlOperation;
}

// Properties
@property (nonatomic, retain) UIImage *underlyingImage;

// Methods
- (void)imageDidFinishLoadingSoDecompress;
- (void)imageLoadingComplete;

- (void)cancelLoadOperation;

@end

// MWPhoto
@implementation MWPhoto

// Properties
@synthesize underlyingImage = _underlyingImage, 
caption = _caption;

#pragma mark Class Methods

+ (MWPhoto *)photoWithImage:(UIImage *)image {
	return [[[MWPhoto alloc] initWithImage:image] autorelease];
}

+ (MWPhoto *)photoWithFilePath:(NSString *)path {
	return [[[MWPhoto alloc] initWithFilePath:path] autorelease];
}

+ (MWPhoto *)photoWithURL:(NSURL *)url {
	return [[[MWPhoto alloc] initWithURL:url] autorelease];
}

#pragma mark NSObject

- (id)initWithImage:(UIImage *)image {
	if ((self = [super init])) {
		self.underlyingImage = image;
	}
	return self;
}

- (id)initWithFilePath:(NSString *)path {
	if ((self = [super init])) {
		_photoPath = [path copy];
	}
	return self;
}

- (id)initWithURL:(NSURL *)url {
	if ((self = [super init])) {
		_photoURL = [url copy];
	}
	return self;
}


- (void)dealloc {
    [_caption release];
    [_dlOperation cancel];  /// release cancels all running operations
//    [[SDWebImageManager sharedManager] cancelForDelegate:self];
	[_photoPath release];
	[_photoURL release];
	[_underlyingImage release];
	[super dealloc];
}

#pragma mark MWPhoto Protocol Methods

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    _loadingInProgress = YES;
    if (self.underlyingImage) {
        // Image already loaded
        [self imageLoadingComplete];
    } else {
        if (_photoPath) {
            // Load async from file
            [self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
        } else if (_photoURL) {
            // Load async from web (using SDWebImage)
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            _dlOperation = [[manager downloadWithURL:_photoURL
                                             options:0
                                            progress:nil
                                           completed:^(UIImage* image, NSError* error, SDImageCacheType cacheType, BOOL finished) {
                                               if (image) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       /// decompress
                                                       self.underlyingImage = image;
                                                       [self imageLoadingComplete];
                                                   });
                                               }
                                               else {
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       self.underlyingImage = nil;
                                                       MWLog(@"SDWebImage failed to download image: %@", error);
                                                       [self imageLoadingComplete];
                                                   });
                                               }
                                               if (finished) {
                                                   [self cancelLoadOperation];
                                               }
                                           }] retain];
        } else {
            // Failed - no source
            self.underlyingImage = nil;
            [self imageLoadingComplete];
        }
    }
}


// Release if we can get it again from path or url
- (void)unloadUnderlyingImage {
    _loadingInProgress = NO;
    [self cancelLoadOperation];
	if (self.underlyingImage && (_photoPath || _photoURL)) {
		self.underlyingImage = nil;
	}
}

#pragma mark - Async Loading

// Called in background
// Load image in background from local file
- (void)loadImageFromFileAsync {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfFile:_photoPath options:NSDataReadingUncached error:&error];
        if (!error) {
            self.underlyingImage = [[[UIImage alloc] initWithData:data] autorelease];
        } else {
            self.underlyingImage = nil;
            MWLog(@"Photo from file error: %@", error);
        }
    } @catch (NSException *exception) {
    } @finally {
        [self performSelectorOnMainThread:@selector(imageDidFinishLoadingSoDecompress) withObject:nil waitUntilDone:NO];
        [pool drain];
    }
}


- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    // Complete so notify
    _loadingInProgress = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:MWPHOTO_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (void)cancelLoadOperation {
    [_dlOperation cancel];
    [_dlOperation release];
    _dlOperation  = nil;
}

@end
