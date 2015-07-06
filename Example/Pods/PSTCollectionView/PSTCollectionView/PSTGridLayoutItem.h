//
//  PSTGridLayoutItem.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSTGridLayoutSection, PSTGridLayoutRow;

// Represents a single grid item; only created for non-uniform-sized grids.
@interface PSTGridLayoutItem : NSObject

@property (nonatomic, unsafe_unretained) PSTGridLayoutSection *section;
@property (nonatomic, unsafe_unretained) PSTGridLayoutRow *rowObject;
@property (nonatomic, assign) CGRect itemFrame;

@end
