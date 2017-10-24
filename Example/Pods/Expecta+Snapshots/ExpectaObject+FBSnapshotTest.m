//
//  ExpectaObject+FBSnapshotTest.m
//  Expecta+Snapshots
//
//  Created by John Boiles on 8/3/15.
//  Copyright (c) 2015 Expecta+Snapshots All rights reserved.
//

#import "ExpectaObject+FBSnapshotTest.h"
#import <objc/runtime.h>

static NSString const *kUsesDrawViewHierarchyInRectKey = @"ExpectaObject+FBSnapshotTest.usesDrawViewHierarchyInRect";

@implementation Expecta (FBSnapshotTest)

+ (void)setUsesDrawViewHierarchyInRect:(BOOL)usesDrawViewHierarchyInRect {
    objc_setAssociatedObject(self, (__bridge const void *)(kUsesDrawViewHierarchyInRectKey), @(usesDrawViewHierarchyInRect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)usesDrawViewHierarchyInRect {
    NSNumber *usesDrawViewHierarchyInRect = objc_getAssociatedObject(self, (__bridge const void *)(kUsesDrawViewHierarchyInRectKey));
    return usesDrawViewHierarchyInRect.boolValue;
}

@end
