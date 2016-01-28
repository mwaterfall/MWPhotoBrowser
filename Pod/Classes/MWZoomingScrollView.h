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
#import "MWTapDetectingLivePhotoView.h"

@class MWPhotoBrowser, MWPhoto, MWCaptionView;

@interface MWZoomingScrollView : UIScrollView <
    UIScrollViewDelegate,
    MWTapDetectingImageViewDelegate,
    MWTapDetectingViewDelegate,
    MWTapDetectingLivePhotoView>

@property () NSUInteger index;
@property (nonatomic) id <MWPhoto> photo;
@property (nonatomic, weak) MWCaptionView *captionView;
@property (nonatomic, weak) UIButton *selectedButton;
@property (nonatomic, weak) UIButton *playButton;
@property (nonatomic) BOOL previewLivePhotos;
@property (nonatomic) BOOL showLivePhotoIcon;

- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayLivePhoto;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (BOOL)displayingVideo;
- (void)setImageHidden:(BOOL)hidden;

@end
