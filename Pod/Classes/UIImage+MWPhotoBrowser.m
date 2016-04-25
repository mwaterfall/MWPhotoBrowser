//
//  UIImage+MWPhotoBrowser.m
//  Pods
//
//  Created by Michael Waterfall on 05/07/2015.
//
//

#import "UIImage+MWPhotoBrowser.h"

@implementation UIImage (MWPhotoBrowser)

+ (UIImage *)imageForResourcePath:(NSString *)path ofType:(NSString *)type inBundle:(NSBundle *)bundle {
    #ifdef CARTHAGE
    return [UIImage imageNamed:path inBundle:bundle compatibleWithTraitCollection:nil];
    #else
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:path ofType:type]];
    #endif
}

+ (UIImage *)clearImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

@end
