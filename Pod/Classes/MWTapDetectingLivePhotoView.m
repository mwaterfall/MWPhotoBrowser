//
//  MWTapDetectingLivePhotoView.m
//  Pods
//
//  Created by Luciano Sugiura on 27/01/16.
//
//

#import "MWTapDetectingLivePhotoView.h"

@implementation MWTapDetectingLivePhotoView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    switch (tapCount) {
        case 1:
            [self handleSingleTap:touch];
            break;
        case 2:
            [self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(livePhotoView:singleTapDetected:)])
        [_tapDelegate livePhotoView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(livePhotoView:doubleTapDetected:)])
        [_tapDelegate livePhotoView:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(livePhotoView:tripleTapDetected:)])
        [_tapDelegate livePhotoView:self tripleTapDetected:touch];
}

@end
