//
//  PSTGridLayoutSection.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTGridLayoutSection.h"
#import "PSTGridLayoutItem.h"
#import "PSTGridLayoutRow.h"
#import "PSTGridLayoutInfo.h"

@interface PSTGridLayoutSection () {
    NSMutableArray *_items;
    NSMutableArray *_rows;
    BOOL _isValid;
}
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, assign) CGFloat otherMargin;
@property (nonatomic, assign) CGFloat beginMargin;
@property (nonatomic, assign) CGFloat endMargin;
@property (nonatomic, assign) CGFloat actualGap;
@property (nonatomic, assign) CGFloat lastRowBeginMargin;
@property (nonatomic, assign) CGFloat lastRowEndMargin;
@property (nonatomic, assign) CGFloat lastRowActualGap;
@property (nonatomic, assign) BOOL lastRowIncomplete;
@property (nonatomic, assign) NSInteger itemsByRowCount;
@property (nonatomic, assign) NSInteger indexOfImcompleteRow;
@end

@implementation PSTGridLayoutSection

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _items = [NSMutableArray new];
        _rows = [NSMutableArray new];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p itemCount:%ld frame:%@ rows:%@>", NSStringFromClass(self.class), self, (long)self.itemsCount, NSStringFromCGRect(self.frame), self.rows];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)invalidate {
    _isValid = NO;
    self.rows = [NSMutableArray array];
}

- (void)computeLayout {
    if (!_isValid) {
        NSAssert(self.rows.count == 0, @"No rows shall be at this point.");

        // iterate over all items, turning them into rows.
        CGSize sectionSize = CGSizeZero;
        NSInteger rowIndex = 0;
        NSInteger itemIndex = 0;
        NSInteger itemsByRowCount = 0;
        CGFloat dimensionLeft = 0;
        PSTGridLayoutRow *row = nil;
        // get dimension and compensate for section margin
        CGFloat headerFooterDimension = self.layoutInfo.dimension;
        CGFloat dimension = headerFooterDimension;

        if (self.layoutInfo.horizontal) {
            dimension -= self.sectionMargins.top + self.sectionMargins.bottom;
            self.headerFrame = CGRectMake(sectionSize.width, 0, self.headerDimension, headerFooterDimension);
            sectionSize.width += self.headerDimension + self.sectionMargins.left;
        }else {
            dimension -= self.sectionMargins.left + self.sectionMargins.right;
            self.headerFrame = CGRectMake(0, sectionSize.height, headerFooterDimension, self.headerDimension);
            sectionSize.height += self.headerDimension + self.sectionMargins.top;
        }

        CGFloat spacing = self.layoutInfo.horizontal ? self.verticalInterstice : self.horizontalInterstice;

        do {
            BOOL finishCycle = itemIndex >= self.itemsCount;
            // TODO: fast path could even remove row creation and just calculate on the fly
            PSTGridLayoutItem *item = nil;
            if (!finishCycle) item = self.fixedItemSize ? nil : self.items[(NSUInteger)itemIndex];

            CGSize itemSize = self.fixedItemSize ? self.itemSize : item.itemFrame.size;
            CGFloat itemDimension = self.layoutInfo.horizontal ? itemSize.height : itemSize.width;
            // first item of each row does not add spacing
            if (itemsByRowCount > 0) itemDimension += spacing;
            if (dimensionLeft < itemDimension || finishCycle) {
                // finish current row
                if (row) {
                    // compensate last row
                    self.itemsByRowCount = fmax(itemsByRowCount, self.itemsByRowCount);
                    row.itemCount = itemsByRowCount;

                    // if current row is done but there are still items left, increase the incomplete row counter
                    if (!finishCycle) self.indexOfImcompleteRow = rowIndex;

                    [row layoutRow];

                    if (self.layoutInfo.horizontal) {
                        row.rowFrame = CGRectMake(sectionSize.width, self.sectionMargins.top, row.rowSize.width, row.rowSize.height);
                        sectionSize.height = MAX(row.rowSize.height, sectionSize.height);
                        sectionSize.width += row.rowSize.width + (finishCycle ? 0 : self.horizontalInterstice);
                    }else {
                        row.rowFrame = CGRectMake(self.sectionMargins.left, sectionSize.height, row.rowSize.width, row.rowSize.height);
                        sectionSize.height += row.rowSize.height + (finishCycle ? 0 : self.verticalInterstice);
                        sectionSize.width = MAX(row.rowSize.width, sectionSize.width);
                    }
                }
                // add new rows until the section is fully laid out
                if (!finishCycle) {
                    // create new row
                    row.complete = YES; // finish up current row
                    row = [self addRow];
                    row.fixedItemSize = self.fixedItemSize;
                    row.index = rowIndex;
                    self.indexOfImcompleteRow = rowIndex;
                    rowIndex++;
                    // convert an item from previous row to current, remove spacing for first item
                    if (itemsByRowCount > 0) itemDimension -= spacing;
                    dimensionLeft = dimension - itemDimension;
                    itemsByRowCount = 0;
                }
            }else {
                dimensionLeft -= itemDimension;
            }

            // add item on slow path
            if (item) [row addItem:item];

            itemIndex++;
            itemsByRowCount++;
        } while (itemIndex <= self.itemsCount); // cycle once more to finish last row

        if (self.layoutInfo.horizontal) {
            sectionSize.width += self.sectionMargins.right;
            self.footerFrame = CGRectMake(sectionSize.width, 0, self.footerDimension, headerFooterDimension);
            sectionSize.width += self.footerDimension;
        }else {
            sectionSize.height += self.sectionMargins.bottom;
            self.footerFrame = CGRectMake(0, sectionSize.height, headerFooterDimension, self.footerDimension);
            sectionSize.height += self.footerDimension;
        }

        _frame = CGRectMake(0, 0, sectionSize.width, sectionSize.height);
        _isValid = YES;
    }
}

- (void)recomputeFromIndex:(NSInteger)index {
    // TODO: use index.
    [self invalidate];
    [self computeLayout];
}

- (PSTGridLayoutItem *)addItem {
    PSTGridLayoutItem *item = [PSTGridLayoutItem new];
    item.section = self;
    [_items addObject:item];
    return item;
}

- (PSTGridLayoutRow *)addRow {
    PSTGridLayoutRow *row = [PSTGridLayoutRow new];
    row.section = self;
    [_rows addObject:row];
    return row;
}

- (PSTGridLayoutSection *)snapshot {
    PSTGridLayoutSection *snapshotSection = [PSTGridLayoutSection new];
    snapshotSection.items = [self.items copy];
    snapshotSection.rows = [self.items copy];
    snapshotSection.verticalInterstice = self.verticalInterstice;
    snapshotSection.horizontalInterstice = self.horizontalInterstice;
    snapshotSection.sectionMargins = self.sectionMargins;
    snapshotSection.frame = self.frame;
    snapshotSection.headerFrame = self.headerFrame;
    snapshotSection.footerFrame = self.footerFrame;
    snapshotSection.headerDimension = self.headerDimension;
    snapshotSection.footerDimension = self.footerDimension;
    snapshotSection.layoutInfo = self.layoutInfo;
    snapshotSection.rowAlignmentOptions = self.rowAlignmentOptions;
    snapshotSection.fixedItemSize = self.fixedItemSize;
    snapshotSection.itemSize = self.itemSize;
    snapshotSection.itemsCount = self.itemsCount;
    snapshotSection.otherMargin = self.otherMargin;
    snapshotSection.beginMargin = self.beginMargin;
    snapshotSection.endMargin = self.endMargin;
    snapshotSection.actualGap = self.actualGap;
    snapshotSection.lastRowBeginMargin = self.lastRowBeginMargin;
    snapshotSection.lastRowEndMargin = self.lastRowEndMargin;
    snapshotSection.lastRowActualGap = self.lastRowActualGap;
    snapshotSection.lastRowIncomplete = self.lastRowIncomplete;
    snapshotSection.itemsByRowCount = self.itemsByRowCount;
    snapshotSection.indexOfImcompleteRow = self.indexOfImcompleteRow;
    return snapshotSection;
}

- (NSInteger)itemsCount {
    return self.fixedItemSize ? _itemsCount : (NSInteger)self.items.count;
}

@end
