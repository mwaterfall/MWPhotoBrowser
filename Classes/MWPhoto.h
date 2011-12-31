//
//  MWPhoto.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageDecoder.h"
#import "SDWebImageManager.h"

@class MWPhoto;

@protocol MWPhotoDelegate <NSObject>
- (void)photoDidFinishLoading:(MWPhoto *)photo;
- (void)photoDidFailToLoad:(MWPhoto *)photo;
@end

@interface MWPhoto : NSObject <SDWebImageManagerDelegate, SDWebImageDecoderDelegate> {
	
	// Image Sources
	NSString *_photoPath;
	NSURL *_photoURL;
    
    // Image
    UIImage *_underlyingImage;
    
    // Other
    NSString *_caption;
    
    // Delegate
    id <MWPhotoDelegate> _photoLoadingDelegate;
	
}

// Properties
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, retain) id <MWPhotoDelegate> photoLoadingDelegate;

// Class
+ (MWPhoto *)photoWithImage:(UIImage *)image;
+ (MWPhoto *)photoWithFilePath:(NSString *)path;
+ (MWPhoto *)photoWithURL:(NSURL *)url;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

// Public methods
- (BOOL)isImageAvailable; // Checks if underlying image is available 
- (UIImage *)image; // Access underlying image 
- (void)loadImageAndNotify:(id<MWPhotoDelegate>)delegate; // Load image from source (file or web and notifies delegate
- (void)releasePhoto; // Release underlying (large decompressed) image

@end
