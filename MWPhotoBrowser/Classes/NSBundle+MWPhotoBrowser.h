//
//  NSBundle+MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Mikkel Selsøe Sørensen on 20/03/14.
//
//

#import <Foundation/Foundation.h>

@interface NSBundle (MWPhotoBrowser)

+ (NSBundle *)MWPhotoBrowserBundle;
+ (NSString *)mw_localizedStringForKey:(NSString *)key;

@end
