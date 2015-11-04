//
//  MWBundlePath.m
//  MWPhotoBrowser
//
//  Created by RJ Garcia on 10/24/15.
//  Copyright © 2015 MWPhotoBrowser. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWBundlePath.h"

NSString * mwBundlePath(NSString * path) {
    return [mwBundlePathPrefix() stringByAppendingString:path];
}

NSString * mwBundlePathPrefix() {
    #ifdef CARTHAGE
    return @"";
    #else
    return @"MWPhotoBrowser.bundle/";
    #endif
}