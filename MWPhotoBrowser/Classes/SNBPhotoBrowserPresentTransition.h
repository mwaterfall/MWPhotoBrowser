//
//  SNBPhotoBrowserPresentTransition.h
//  snowball
//
//  Created by John on 17/2/16.
//  Copyright © 2017年 Snowball. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SNBPhotoBrowserPresentTransitionType) {
    SNBPhotoBrowserPresentTransitionTypePresent = 0,
    SNBPhotoBrowserPresentTransitionTypeDismiss
};

@interface SNBPhotoBrowserPresentTransition : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)transitionWithTransitionType:(SNBPhotoBrowserPresentTransitionType)type;

@end
