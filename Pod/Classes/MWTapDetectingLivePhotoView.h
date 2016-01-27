//
//  MWTapDetectingLivePhotoView.h
//  Pods
//
//  Created by Luciano Sugiura on 27/01/16.
//
//

#import <PhotosUI/PhotosUI.h>

@protocol MWTapDetectingLivePhotoView <NSObject>

@optional

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView singleTapDetected:(UITouch *)touch;
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView doubleTapDetected:(UITouch *)touch;
- (void)livePhotoView:(PHLivePhotoView *)livePhotoView tripleTapDetected:(UITouch *)touch;

@end

//--------------------------------------------------------------------------------------------------

@interface MWTapDetectingLivePhotoView : PHLivePhotoView

@property (nonatomic, weak) id<MWTapDetectingLivePhotoView> tapDelegate;

@end
