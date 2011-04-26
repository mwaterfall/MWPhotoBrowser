//
//  MWPhoto.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>

// Protocol
@protocol MWPhoto;

// Delegate
@protocol MWPhotoDelegate <NSObject>
- (void)photoDidFinishLoading:(id<MWPhoto>)photo;
- (void)photoDidFailToLoad:(id<MWPhoto>)photo;
@end

@protocol MWPhoto <NSObject>
- (BOOL)isImageAvailable;
- (UIImage *)image;
- (void)obtainImageInBackgroundAndNotify:(id<MWPhotoDelegate>)notifyDelegate;
@optional
- (void)releasePhoto; // Advise model it is not onscreen
@end

// MWPhoto
@interface MWPhoto : NSObject <MWPhoto> {
	
	// Image
	NSString *photoPath;
	NSURL *photoURL;
	UIImage *photoImage;
	
	// Flags
	BOOL workingInBackground;
	
}

// Class
+ (MWPhoto *)photoWithImage:(UIImage *)image;
+ (MWPhoto *)photoWithFilePath:(NSString *)path;
+ (MWPhoto *)photoWithURL:(NSURL *)url;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

@end
