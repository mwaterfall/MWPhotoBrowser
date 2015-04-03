//
//  DACircularProgressView.m
//  DACircularProgress
//
//  Created by Daniel Amitay on 2/6/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "DACircularProgressView.h"

#import <QuartzCore/QuartzCore.h>

@interface DACircularProgressLayer : CALayer

@property(nonatomic, strong) UIColor *trackTintColor;
@property(nonatomic, strong) UIColor *progressTintColor;
@property(nonatomic) NSInteger roundedCorners;
@property(nonatomic) CGFloat thicknessRatio;
@property(nonatomic) CGFloat progress;

@end

@implementation DACircularProgressLayer

@dynamic trackTintColor;
@dynamic progressTintColor;
@dynamic roundedCorners;
@dynamic thicknessRatio;
@dynamic progress;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"progress"] ? YES : [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    CGPoint centerPoint = CGPointMake(rect.size.height / 2.0f, rect.size.width / 2.0f);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2.0f;
    
    CGFloat progress = MIN(self.progress, 1.0f - FLT_EPSILON);
    CGFloat radians = (progress * 2.0f * M_PI) - M_PI_2;
    
    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, 3.0f * M_PI_2, -M_PI_2, NO);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);
    
    if (progress > 0.0f)
    {
        CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
        CGMutablePathRef progressPath = CGPathCreateMutable();
        CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
        CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, 3.0f * M_PI_2, radians, NO);
        CGPathCloseSubpath(progressPath);
        CGContextAddPath(context, progressPath);
        CGContextFillPath(context);
        CGPathRelease(progressPath);
    }
    
    if (progress > 0.0f && self.roundedCorners)
    {
        CGFloat pathWidth = radius * self.thicknessRatio;
        CGFloat xOffset = radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * cosf(radians)));
        CGFloat yOffset = radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * sinf(radians)));
        CGPoint endPoint = CGPointMake(xOffset, yOffset);
        
        CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - pathWidth / 2.0f, 0.0f, pathWidth, pathWidth));
        CGContextFillPath(context);
        
        CGContextAddEllipseInRect(context, CGRectMake(endPoint.x - pathWidth / 2.0f, endPoint.y - pathWidth / 2.0f, pathWidth, pathWidth));
        CGContextFillPath(context);
    }
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat innerRadius = radius * (1.0f - self.thicknessRatio);
    CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);
    CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius * 2.0f, innerRadius * 2.0f));
    CGContextFillPath(context);
}

@end

@interface DACircularProgressView ()

@end

@implementation DACircularProgressView

+ (void) initialize
{
    if (self != [DACircularProgressView class])
        return;
    
    id appearance = [self appearance];
    [appearance setTrackTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3f]];
    [appearance setProgressTintColor:[UIColor whiteColor]];
    [appearance setBackgroundColor:[UIColor clearColor]];
    [appearance setThicknessRatio:0.3f];
    [appearance setRoundedCorners:NO];
    
    [appearance setIndeterminateDuration:2.0f];
    [appearance setIndeterminate:NO];
}

+ (Class)layerClass
{
    return [DACircularProgressLayer class];
}

- (DACircularProgressLayer *)circularProgressLayer
{
    return (DACircularProgressLayer *)self.layer;
}

- (id)init
{
    return [super initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
}

- (void)didMoveToWindow
{
    CGFloat windowContentsScale = self.window.screen.scale;
    self.circularProgressLayer.contentsScale = windowContentsScale;
}

#pragma mark - Progress

- (CGFloat)progress
{
    return self.circularProgressLayer.progress;
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self.layer removeAnimationForKey:@"indeterminateAnimation"];
    [self.circularProgressLayer removeAnimationForKey:@"progress"];
    
    CGFloat pinnedProgress = MIN(MAX(progress, 0.0f), 1.0f);
    if (animated)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
        animation.duration = fabs(self.progress - pinnedProgress); // Same duration as UIProgressView animation
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:self.progress];
        animation.toValue = [NSNumber numberWithFloat:pinnedProgress];
        [self.circularProgressLayer addAnimation:animation forKey:@"progress"];
    }
    else
    {
        [self.circularProgressLayer setNeedsDisplay];
    }
    self.circularProgressLayer.progress = pinnedProgress;
}

#pragma mark - UIAppearance methods

- (UIColor *)trackTintColor
{
    return self.circularProgressLayer.trackTintColor;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    self.circularProgressLayer.trackTintColor = trackTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (UIColor *)progressTintColor
{
    return self.circularProgressLayer.progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    self.circularProgressLayer.progressTintColor = progressTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)roundedCorners
{
    return self.roundedCorners;
}

- (void)setRoundedCorners:(NSInteger)roundedCorners
{
    self.circularProgressLayer.roundedCorners = roundedCorners;
    [self.circularProgressLayer setNeedsDisplay];
}

- (CGFloat)thicknessRatio
{
    return self.circularProgressLayer.thicknessRatio;
}

- (void)setThicknessRatio:(CGFloat)thicknessRatio
{
    self.circularProgressLayer.thicknessRatio = MIN(MAX(thicknessRatio, 0.f), 1.f);
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)indeterminate
{
    CAAnimation *spinAnimation = [self.layer animationForKey:@"indeterminateAnimation"];
    return (spinAnimation == nil ? 0 : 1);
}

- (void)setIndeterminate:(NSInteger)indeterminate
{
    if (indeterminate && !self.indeterminate)
    {
        CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        spinAnimation.byValue = [NSNumber numberWithFloat:indeterminate > 0 ? 2.0f*M_PI : -2.0f*M_PI];
        spinAnimation.duration = self.indeterminateDuration;
        spinAnimation.repeatCount = HUGE_VALF;
        [self.layer addAnimation:spinAnimation forKey:@"indeterminateAnimation"];
    }
    else
    {
        [self.layer removeAnimationForKey:@"indeterminateAnimation"];
    }
}

@end
