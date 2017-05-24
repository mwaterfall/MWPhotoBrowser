//
//  SNBPhotoBrowserPresentTransition
//  snowball
//
//  Created by John on 17/2/16.
//  Copyright © 2017年 Snowball. All rights reserved.
//

#import "SNBPhotoBrowserPresentTransition.h"
#import "MWPhotoBrowser.h"

@interface SNBPhotoBrowserPresentTransition ()

@property (nonatomic, assign) SNBPhotoBrowserPresentTransitionType type;

@end

@implementation SNBPhotoBrowserPresentTransition

+ (instancetype)transitionWithTransitionType:(SNBPhotoBrowserPresentTransitionType)type
{
    return [[self alloc] initWithTransitionType:type];
}

- (instancetype)initWithTransitionType:(SNBPhotoBrowserPresentTransitionType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _type == SNBPhotoBrowserPresentTransitionTypePresent ? 0.5 : 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //为了将两种动画的逻辑分开，变得更加清晰，分开书写逻辑，
    switch (_type) {
        case SNBPhotoBrowserPresentTransitionTypePresent:
            [self presentAnimation:transitionContext];
            break;
            
        case SNBPhotoBrowserPresentTransitionTypeDismiss:
            [self dismissAnimation:transitionContext];
            break;
    }
}

/**
 *  实现present动画
 */
- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (![toVC isKindOfClass:[MWPhotoBrowser class]]) {
        return;
    }
    UIView *containerView = [transitionContext containerView];
    toVC.view.alpha = 0;
    fromVC.view.frame = containerView.bounds;
    toVC.view.frame = containerView.bounds;
    containerView.backgroundColor = [UIColor blackColor];
    [containerView addSubview:toVC.view];
    [UIView animateWithDuration:0.3 animations:^{
        [fromVC.view removeFromSuperview];
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

/**
 *  实现dimiss动画
 */
- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    toVC.view.frame = containerView.bounds;
    [containerView addSubview:toVC.view];
    [containerView bringSubviewToFront:fromVC.view];
    [UIView animateWithDuration:0.3 animations:^{
        fromVC.view.alpha = 0;
    } completion:^(BOOL finished) {
        [fromVC.view removeFromSuperview];
        if ([transitionContext transitionWasCancelled]) {
            [transitionContext completeTransition:NO];
        }else{
            [transitionContext completeTransition:YES];
        }
    }];
}

@end
