//
//  NSBundle+MWPhotoBrowser.m
//  MWPhotoBrowser
//
//  Created by Mikkel Selsøe Sørensen on 20/03/14.
//
//

#import "NSBundle+MWPhotoBrowser.h"

@implementation NSBundle (MWPhotoBrowser)

+ (NSBundle *)MWPhotoBrowserBundle {
    static dispatch_once_t fetchBundleOnce;
    static NSBundle *bundle = nil;
    
    dispatch_once(&fetchBundleOnce, ^{
        NSString* path = [[NSBundle mainBundle] pathForResource:@"MWPhotoBrowser" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:path];
    });
    return bundle;
}

+ (NSString *)mw_localizedStringForKey:(NSString *)key
{
    return [[self MWPhotoBrowserBundle] localizedStringForKey:key
                                                        value:nil
                                                        table:nil];
}

@end
