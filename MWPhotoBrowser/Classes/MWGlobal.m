//
//  MWGlobal.m
//  Pods
//
//  Created by Marius Landwehr on 05.06.15.
//
//

#import "MWGlobal.h"

NSBundle *mwBundle(void) {
    static NSBundle *bundle = nil;
    if(!bundle) {
        NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MWPhotoBrowser.bundle"];
        bundle = [NSBundle bundleWithPath:path];
    }
    
    return bundle;
}

NSString *MWLocalize(NSString *stringToken) {
    if(mwBundle()) {
        return NSLocalizedStringFromTableInBundle(stringToken, @"mwstrings", mwBundle(), @"");
    } else {
        return stringToken;
    }
}