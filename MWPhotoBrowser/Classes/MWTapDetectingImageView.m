//
//  UIImageViewTap.m
//  Momento
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import "MWTapDetectingImageView.h"

@implementation MWTapDetectingImageView

#pragma mark Init
- (instancetype)init
{
    if (self = [self initWithFrame:CGRectZero])
    {}
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
    {
        self.userInteractionEnabled = YES;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [self addGestureRecognizer:longPress];
	}
    
	return self;
}

- (instancetype)initWithImage:(UIImage *)image
{
	if (self = [self initWithFrame:CGRectZero])
    {
		self.image = image;
	}
    
	return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
	if (self = [self initWithFrame:CGRectZero])
    {
		self.image = image;
        self.highlightedImage = highlightedImage;
	}
    
	return self;
}

#pragma mark Touch events
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (_tapDelegate && [_tapDelegate respondsToSelector:@selector(longPressDetectedOnImageView:)])
    {
        [_tapDelegate longPressDetectedOnImageView:self];
    }
}


@end
