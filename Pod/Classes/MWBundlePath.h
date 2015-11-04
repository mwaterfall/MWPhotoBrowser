//
//  MWBundlePath.h
//  MWPhotoBrowser
//
//  Created by RJ Garcia on 10/24/15.
//  Copyright © 2015 MWPhotoBrowser. All rights reserved.
//

#ifndef MWBundlePath_h
#define MWBundlePath_h

#import <Foundation/Foundation.h>

/**
    Returns the proper BundlePath for images depending on compiler PreProcessor flags
*/
NSString * mwBundlePath(NSString * path);
NSString * mwBundlePathPrefix();

#endif /* MWBundlePath_h */