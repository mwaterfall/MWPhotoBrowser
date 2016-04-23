//
//  UIImageViewTap.m
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import "MWTapDetectingImageView.h"

@implementation MWTapDetectingImageView {
    NSTimer *_timer;
    BOOL _longPressDetected;
    UITouch *_touches;
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (id)initWithImage:(UIImage *)image {
	if ((self = [super initWithImage:image])) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
	if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
		self.userInteractionEnabled = YES;
	}
	return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _longPressDetected = NO;
    _touches = touches.anyObject;
    if ([_tapDelegate respondsToSelector:@selector(imageView:longPressDetected:)]) {
        [self startTimer];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_longPressDetected) {
        return;
    }
    [self endTimer];
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
	if ([_tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
		[_tapDelegate imageView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
	if ([_tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
		[_tapDelegate imageView:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
	if ([_tapDelegate respondsToSelector:@selector(imageView:tripleTapDetected:)])
		[_tapDelegate imageView:self tripleTapDetected:touch];
}

- (void)handleLongPress:(UITouch *)touch {
    if ([_tapDelegate respondsToSelector:@selector(imageView:longPressDetected:)])
        [_tapDelegate imageView:self longPressDetected:touch];
}

- (void)startTimer
{
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:0.4 target:self selector:@selector(timeFire) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)endTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)timeFire
{
    _longPressDetected = YES;
    [self endTimer];
    if ([_tapDelegate respondsToSelector:@selector(imageView:longPressDetected:)]) {
        [self handleLongPress:_touches];
    }
}

- (void)dealloc
{
    _timer = nil;
    _touches = nil;
}

@end
