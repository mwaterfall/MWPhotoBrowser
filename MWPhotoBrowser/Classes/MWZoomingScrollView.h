//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"

@class MWPhotoBrowser, MWPhoto, MWCaptionView;

@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate> {
	
	MWPhotoBrowser *__weak _photoBrowser;
    id<MWPhoto> _photo;
	
    // This view references the related caption view for simplified
    // handling in photo browser
    MWCaptionView *_captionView;
    
	MWTapDetectingView *_tapView; // for background taps
	MWTapDetectingImageView *_photoImageView;
	UIActivityIndicatorView *_spinner;
	
}

@property (nonatomic, strong) MWCaptionView *captionView;
@property (nonatomic, strong) id<MWPhoto> photo;

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@end
