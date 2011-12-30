//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageViewTap.h"
#import "UIViewTap.h"

@class MWPhotoBrowser, MWPhoto;

@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate> {
	
	MWPhotoBrowser *_photoBrowser;
    MWPhoto *_photo;
	
	UIViewTap *_tapView; // for background taps
	UIImageViewTap *_photoImageView;
	UIActivityIndicatorView *_spinner;
	
}

@property (nonatomic, retain) MWPhoto *photo;

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@end
