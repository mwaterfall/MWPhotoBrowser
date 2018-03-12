//
//  ExpectaObject+FBSnapshotTest.h
//  Expecta+Snapshots
//
//  Created by John Boiles on 8/3/15.
//  Copyright (c) 2015 Expecta+Snapshots All rights reserved.
//

#import <Expecta/ExpectaObject.h>

@interface Expecta (FBSnapshotTest)

+ (void)setUsesDrawViewHierarchyInRect:(BOOL)usesDrawViewHierarchyInRect;

+ (BOOL)usesDrawViewHierarchyInRect;

+ (void)setDeviceAgnostic:(BOOL)deviceAgnostic;

+ (BOOL)isDeviceAgnostic;

@end
