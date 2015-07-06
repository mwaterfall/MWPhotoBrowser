//
//  NSIndexPath+PSTCollectionViewAdditions.h
//  PSTCollectionView
//
//  Copyright (c) 2013 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000

@interface NSIndexPath (PSTCollectionViewAdditions)

+ (NSIndexPath *)indexPathForItem:(NSInteger)item inSection:(NSInteger)section;

- (NSInteger)item;

@end

#endif
