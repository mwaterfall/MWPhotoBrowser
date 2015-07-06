//
//  PSTGridLayoutRow.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSTGridLayoutSection, PSTGridLayoutItem;

@interface PSTGridLayoutRow : NSObject

@property (nonatomic, unsafe_unretained) PSTGridLayoutSection *section;
@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, assign) CGSize rowSize;
@property (nonatomic, assign) CGRect rowFrame;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, assign) BOOL fixedItemSize;

// @steipete addition for row-fastPath
@property (nonatomic, assign) NSInteger itemCount;

//- (PSTGridLayoutRow *)copyFromSection:(PSTGridLayoutSection *)section; // ???

// Add new item to items array.
- (void)addItem:(PSTGridLayoutItem *)item;

// Layout current row (if invalid)
- (void)layoutRow;

// @steipete: Helper to save code in PSTCollectionViewFlowLayout.
// Returns the item rects when fixedItemSize is enabled.
- (NSArray *)itemRects;

//  Set current row frame invalid.
- (void)invalidate;

// Copy a snapshot of the current row data
- (PSTGridLayoutRow *)snapshot;

@end
