//
//  MWPhoto.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "MWPhoto.h"
#import "MWPhotoBrowser.h"

// Private
@interface MWPhoto ()
@property (retain) UIImage *underlyingImage;
- (void)imageDidFinishLoading;
@end

// MWPhoto
@implementation MWPhoto

// Properties
@synthesize underlyingImage = _underlyingImage, 
photoLoadingDelegate = _photoLoadingDelegate,
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
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
	[_photoPath release];
	[_photoURL release];
	[_underlyingImage release];
    [_photoLoadingDelegate release];
	[super dealloc];
}

#pragma mark Photo

// Release if we can get it again from path or url
- (void)releasePhoto {
    self.photoLoadingDelegate = nil;
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
	if (self.underlyingImage && (_photoPath || _photoURL)) {
		self.underlyingImage = nil;
	}
}

// Return whether the image available
// It is available if the UIImage has been loaded and
// loading from file or URL is not required
- (BOOL)isImageAvailable {
	return (self.underlyingImage != nil);
}

- (UIImage *)image {
	return self.underlyingImage;
}

// Called on main
- (void)loadImageAndNotify:(id<MWPhotoDelegate>)delegate {
    if (_photoLoadingDelegate) return;
    if (self.underlyingImage) {
        // Done
        [delegate photoDidFinishLoading:self];
    } else {
        if (_photoPath) {
            // Load async from file
            self.photoLoadingDelegate = delegate;
            [self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
        } else if (_photoURL) {
            self.photoLoadingDelegate = delegate;
            // Load async from web (using SDWebImage)
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            UIImage *cachedImage = [manager imageWithURL:_photoURL];
            if (cachedImage) {
                // Use the cached image immediatly
                self.underlyingImage = cachedImage;
                [self imageDidFinishLoading];
            } else {
                // Start an async download
                [manager downloadWithURL:_photoURL delegate:self];
            }
        } else {
            // Failed
            [delegate photoDidFailToLoad:self];
        }
    }
}

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
        [self performSelectorOnMainThread:@selector(imageDidFinishLoading) withObject:nil waitUntilDone:NO];
    } @catch (NSException *exception) {
    } @finally {
        [pool drain];
    }
}

// Called on main
- (void)imageDidFinishLoading {
    if (self.underlyingImage) {
        // Decode image to avoid lagging when UIKit lazy loads
        // Happens async
        [[SDWebImageDecoder sharedImageDecoder] decodeImage:self.underlyingImage withDelegate:self userInfo:nil];
    } else {
        // Failed
        [_photoLoadingDelegate photoDidFailToLoad:self];
        self.photoLoadingDelegate = nil;
    }
}

#pragma mark - SDWebImage Delegate

// Called on main
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image {
    self.underlyingImage = image;
    [self imageDidFinishLoading];
}

// Called on main
- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error {
    self.underlyingImage = nil;
    MWLog(@"SDWebImage failed to download image: %@", error);
    [self imageDidFinishLoading];
}

// Called on main
- (void)imageDecoder:(SDWebImageDecoder *)decoder didFinishDecodingImage:(UIImage *)image userInfo:(NSDictionary *)userInfo {
    if (image) {
        // Complete
        self.underlyingImage = image;
        [_photoLoadingDelegate photoDidFinishLoading:self];
    } else {
        // Fail
        self.underlyingImage = nil;
        [_photoLoadingDelegate photoDidFailToLoad:self];
    }
    self.photoLoadingDelegate = nil;
}

@end
