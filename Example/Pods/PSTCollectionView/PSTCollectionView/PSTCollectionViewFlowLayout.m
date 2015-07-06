//
//  PSTCollectionViewFlowLayout.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewFlowLayout.h"
#import "PSTCollectionView.h"
#import "PSTGridLayoutItem.h"
#import "PSTGridLayoutInfo.h"
#import "PSTGridLayoutRow.h"
#import "PSTGridLayoutSection.h"
#import <objc/runtime.h>

NSString *const PSTCollectionElementKindSectionHeader = @"UICollectionElementKindSectionHeader";
NSString *const PSTCollectionElementKindSectionFooter = @"UICollectionElementKindSectionFooter";

// this is not exposed in UICollectionViewFlowLayout
NSString *const PSTFlowLayoutCommonRowHorizontalAlignmentKey = @"UIFlowLayoutCommonRowHorizontalAlignmentKey";
NSString *const PSTFlowLayoutLastRowHorizontalAlignmentKey = @"UIFlowLayoutLastRowHorizontalAlignmentKey";
NSString *const PSTFlowLayoutRowVerticalAlignmentKey = @"UIFlowLayoutRowVerticalAlignmentKey";

@implementation PSTCollectionViewFlowLayout {
    // class needs to have same iVar layout as UICollectionViewLayout
    struct {
        unsigned int delegateSizeForItem : 1;
        unsigned int delegateReferenceSizeForHeader : 1;
        unsigned int delegateReferenceSizeForFooter : 1;
        unsigned int delegateInsetForSection : 1;
        unsigned int delegateInteritemSpacingForSection : 1;
        unsigned int delegateLineSpacingForSection : 1;
        unsigned int delegateAlignmentOptions : 1;
        unsigned int keepDelegateInfoWhileInvalidating : 1;
        unsigned int keepAllDataWhileInvalidating : 1;
        unsigned int layoutDataIsValid : 1;
        unsigned int delegateInfoIsValid : 1;
    }_gridLayoutFlags;
    CGFloat _interitemSpacing;
    CGFloat _lineSpacing;
    CGSize _itemSize;
    CGSize _headerReferenceSize;
    CGSize _footerReferenceSize;
    UIEdgeInsets _sectionInset;
    PSTGridLayoutInfo *_data;
    CGSize _currentLayoutSize;
    NSMutableDictionary *_insertedItemsAttributesDict;
    NSMutableDictionary *_insertedSectionHeadersAttributesDict;
    NSMutableDictionary *_insertedSectionFootersAttributesDict;
    NSMutableDictionary *_deletedItemsAttributesDict;
    NSMutableDictionary *_deletedSectionHeadersAttributesDict;
    NSMutableDictionary *_deletedSectionFootersAttributesDict;
    PSTCollectionViewScrollDirection _scrollDirection;
    NSDictionary *_rowAlignmentsOptionsDictionary;
    CGRect _visibleBounds;
    char filler[200]; // [HACK] Our class needs to be larger than Apple's class for the superclass change to work.
}

@synthesize rowAlignmentOptions = _rowAlignmentsOptionsDictionary;
@synthesize minimumLineSpacing = _lineSpacing;
@synthesize minimumInteritemSpacing = _interitemSpacing;

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (void)commonInit {
    _itemSize = CGSizeMake(50.f, 50.f);
    _lineSpacing = 10.f;
    _interitemSpacing = 10.f;
    _sectionInset = UIEdgeInsetsZero;
    _scrollDirection = PSTCollectionViewScrollDirectionVertical;
    _headerReferenceSize = CGSizeZero;
    _footerReferenceSize = CGSizeZero;
}

- (id)init {
    if ((self = [super init])) {
        [self commonInit];

        // set default values for row alignment.
        _rowAlignmentsOptionsDictionary = @{
                PSTFlowLayoutCommonRowHorizontalAlignmentKey : @(PSTFlowLayoutHorizontalAlignmentJustify),
                PSTFlowLayoutLastRowHorizontalAlignmentKey : @(PSTFlowLayoutHorizontalAlignmentJustify),
                // TODO: those values are some enum. find out what that is.
                PSTFlowLayoutRowVerticalAlignmentKey : @(1),
        };
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        [self commonInit];

        // Some properties are not set if they're default (like minimumInteritemSpacing == 10)
        if ([decoder containsValueForKey:@"UIItemSize"])
            self.itemSize = [decoder decodeCGSizeForKey:@"UIItemSize"];
        if ([decoder containsValueForKey:@"UIInteritemSpacing"])
            self.minimumInteritemSpacing = [decoder decodeFloatForKey:@"UIInteritemSpacing"];
        if ([decoder containsValueForKey:@"UILineSpacing"])
            self.minimumLineSpacing = [decoder decodeFloatForKey:@"UILineSpacing"];
        if ([decoder containsValueForKey:@"UIFooterReferenceSize"])
            self.footerReferenceSize = [decoder decodeCGSizeForKey:@"UIFooterReferenceSize"];
        if ([decoder containsValueForKey:@"UIHeaderReferenceSize"])
            self.headerReferenceSize = [decoder decodeCGSizeForKey:@"UIHeaderReferenceSize"];
        if ([decoder containsValueForKey:@"UISectionInset"])
            self.sectionInset = [decoder decodeUIEdgeInsetsForKey:@"UISectionInset"];
        if ([decoder containsValueForKey:@"UIScrollDirection"])
            self.scrollDirection = [decoder decodeIntegerForKey:@"UIScrollDirection"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeCGSize:self.itemSize forKey:@"UIItemSize"];
    [coder encodeFloat:(float)self.minimumInteritemSpacing forKey:@"UIInteritemSpacing"];
    [coder encodeFloat:(float)self.minimumLineSpacing forKey:@"UILineSpacing"];
    [coder encodeCGSize:self.footerReferenceSize forKey:@"UIFooterReferenceSize"];
    [coder encodeCGSize:self.headerReferenceSize forKey:@"UIHeaderReferenceSize"];
    [coder encodeUIEdgeInsets:self.sectionInset forKey:@"UISectionInset"];
    [coder encodeInteger:self.scrollDirection forKey:@"UIScrollDirection"];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewLayout

static char kPSTCachedItemRectsKey;

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    // Apple calls _layoutAttributesForItemsInRect
    if (!_data) [self prepareLayout];

    NSMutableArray *layoutAttributesArray = [NSMutableArray array];
    for (PSTGridLayoutSection *section in _data.sections) {
        if (CGRectIntersectsRect(section.frame, rect)) {

            // if we have fixed size, calculate item frames only once.
            // this also uses the default PSTFlowLayoutCommonRowHorizontalAlignmentKey alignment
            // for the last row. (we want this effect!)
            NSMutableDictionary *rectCache = objc_getAssociatedObject(self, &kPSTCachedItemRectsKey);
            NSUInteger sectionIndex = [_data.sections indexOfObjectIdenticalTo:section];

            CGRect normalizedHeaderFrame = section.headerFrame;
            normalizedHeaderFrame.origin.x += section.frame.origin.x;
            normalizedHeaderFrame.origin.y += section.frame.origin.y;
            if (!CGRectIsEmpty(normalizedHeaderFrame) && CGRectIntersectsRect(normalizedHeaderFrame, rect)) {
                PSTCollectionViewLayoutAttributes *layoutAttributes = [[self.class layoutAttributesClass] layoutAttributesForSupplementaryViewOfKind:PSTCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:(NSInteger)sectionIndex]];
                layoutAttributes.frame = normalizedHeaderFrame;
                [layoutAttributesArray addObject:layoutAttributes];
            }

            NSArray *itemRects = rectCache[@(sectionIndex)];
            if (!itemRects && section.fixedItemSize && section.rows.count) {
                itemRects = [(section.rows)[0] itemRects];
                if (itemRects) rectCache[@(sectionIndex)] = itemRects;
            }
            
            for (PSTGridLayoutRow *row in section.rows) {
                CGRect normalizedRowFrame = row.rowFrame;
                
                normalizedRowFrame.origin.x += section.frame.origin.x;
                normalizedRowFrame.origin.y += section.frame.origin.y;
                
                if (CGRectIntersectsRect(normalizedRowFrame, rect)) {
                    // TODO be more fine-grained for items

                    for (NSInteger itemIndex = 0; itemIndex < row.itemCount; itemIndex++) {
                        PSTCollectionViewLayoutAttributes *layoutAttributes;
                        NSUInteger sectionItemIndex;
                        CGRect itemFrame;
                        if (row.fixedItemSize) {
                            itemFrame = [itemRects[(NSUInteger)itemIndex] CGRectValue];
                            sectionItemIndex = (NSUInteger)(row.index * section.itemsByRowCount + itemIndex);
                        }else {
                            PSTGridLayoutItem *item = row.items[(NSUInteger)itemIndex];
                            sectionItemIndex = [section.items indexOfObjectIdenticalTo:item];
                            itemFrame = item.itemFrame;
                        }

                        CGRect normalisedItemFrame = CGRectMake(normalizedRowFrame.origin.x + itemFrame.origin.x, normalizedRowFrame.origin.y + itemFrame.origin.y, itemFrame.size.width, itemFrame.size.height);
                        
                        if (CGRectIntersectsRect(normalisedItemFrame, rect)) {
                            layoutAttributes = [[self.class layoutAttributesClass] layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:(NSInteger)sectionItemIndex inSection:(NSInteger)sectionIndex]];
                            layoutAttributes.frame = normalisedItemFrame;
                            [layoutAttributesArray addObject:layoutAttributes];
                        }
                    }
                }
            }

            CGRect normalizedFooterFrame = section.footerFrame;
            normalizedFooterFrame.origin.x += section.frame.origin.x;
            normalizedFooterFrame.origin.y += section.frame.origin.y;
            if (!CGRectIsEmpty(normalizedFooterFrame) && CGRectIntersectsRect(normalizedFooterFrame, rect)) {
                PSTCollectionViewLayoutAttributes *layoutAttributes = [[self.class layoutAttributesClass] layoutAttributesForSupplementaryViewOfKind:PSTCollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:(NSInteger)sectionIndex]];
                layoutAttributes.frame = normalizedFooterFrame;
                [layoutAttributesArray addObject:layoutAttributes];
            }
        }
    }
    return layoutAttributesArray;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_data) [self prepareLayout];

    PSTGridLayoutSection *section = _data.sections[(NSUInteger)indexPath.section];
    PSTGridLayoutRow *row = nil;
    CGRect itemFrame = CGRectZero;

    if (section.fixedItemSize && section.itemsByRowCount > 0 && indexPath.item / section.itemsByRowCount < (NSInteger)section.rows.count) {
        row = section.rows[(NSUInteger)(indexPath.item / section.itemsByRowCount)];
        NSUInteger itemIndex = (NSUInteger)(indexPath.item % section.itemsByRowCount);
        NSArray *itemRects = [row itemRects];
        itemFrame = [itemRects[itemIndex] CGRectValue];
    }else if (indexPath.item < (NSInteger)section.items.count) {
        PSTGridLayoutItem *item = section.items[(NSUInteger)indexPath.item];
        row = item.rowObject;
        itemFrame = item.itemFrame;
    }

    PSTCollectionViewLayoutAttributes *layoutAttributes = [[self.class layoutAttributesClass] layoutAttributesForCellWithIndexPath:indexPath];

    // calculate item rect
    CGRect normalizedRowFrame = row.rowFrame;
    normalizedRowFrame.origin.x += section.frame.origin.x;
    normalizedRowFrame.origin.y += section.frame.origin.y;
    layoutAttributes.frame = CGRectMake(normalizedRowFrame.origin.x + itemFrame.origin.x, normalizedRowFrame.origin.y + itemFrame.origin.y, itemFrame.size.width, itemFrame.size.height);

    return layoutAttributes;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (!_data) [self prepareLayout];

    NSUInteger sectionIndex = (NSUInteger)indexPath.section;
    PSTCollectionViewLayoutAttributes *layoutAttributes = nil;

    if (sectionIndex < _data.sections.count) {
        PSTGridLayoutSection *section = _data.sections[sectionIndex];

        CGRect normalizedFrame = CGRectZero;
        if ([kind isEqualToString:PSTCollectionElementKindSectionHeader]) {
            normalizedFrame = section.headerFrame;
        }
        else if ([kind isEqualToString:PSTCollectionElementKindSectionFooter]) {
            normalizedFrame = section.footerFrame;
        }

        if (!CGRectIsEmpty(normalizedFrame)) {
            normalizedFrame.origin.x += section.frame.origin.x;
            normalizedFrame.origin.y += section.frame.origin.y;

            layoutAttributes = [[self.class layoutAttributesClass] layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:[NSIndexPath indexPathForItem:0 inSection:(NSInteger)sectionIndex]];
            layoutAttributes.frame = normalizedFrame;
        }
    }
    return layoutAttributes;
}

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForDecorationViewWithReuseIdentifier:(NSString *)identifier atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGSize)collectionViewContentSize {
    if (!_data) [self prepareLayout];

    return _data.contentSize;
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(sectionInset, _sectionInset)) {
        _sectionInset = sectionInset;
        [self invalidateLayout];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Invalidating the Layout

- (void)invalidateLayout {
    [super invalidateLayout];
    objc_setAssociatedObject(self, &kPSTCachedItemRectsKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    _data = nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // we need to recalculate on width changes
    if ((_visibleBounds.size.width != newBounds.size.width && self.scrollDirection == PSTCollectionViewScrollDirectionVertical) || (_visibleBounds.size.height != newBounds.size.height && self.scrollDirection == PSTCollectionViewScrollDirectionHorizontal)) {
        _visibleBounds = self.collectionView.bounds;
        return YES;
    }
    return NO;
}

// return a point at which to rest after scrolling - for layouts that want snap-to-point scrolling behavior
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    return proposedContentOffset;
}

- (void)prepareLayout {
    // custom ivars
    objc_setAssociatedObject(self, &kPSTCachedItemRectsKey, [NSMutableDictionary dictionary], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    _data = [PSTGridLayoutInfo new]; // clear old layout data
    _data.horizontal = self.scrollDirection == PSTCollectionViewScrollDirectionHorizontal;
    _visibleBounds = self.collectionView.bounds;
    CGSize collectionViewSize = _visibleBounds.size;
    _data.dimension = _data.horizontal ? collectionViewSize.height : collectionViewSize.width;
    _data.rowAlignmentOptions = _rowAlignmentsOptionsDictionary;
    [self fetchItemsInfo];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

- (void)fetchItemsInfo {
    [self getSizingInfos];
    [self updateItemsLayout];
}

// get size of all items (if delegate is implemented)
- (void)getSizingInfos {
    NSAssert(_data.sections.count == 0, @"Grid layout is already populated?");

    id<PSTCollectionViewDelegateFlowLayout> flowDataSource = (id<PSTCollectionViewDelegateFlowLayout>)self.collectionView.delegate;

    BOOL implementsSizeDelegate = [flowDataSource respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)];
    BOOL implementsHeaderReferenceDelegate = [flowDataSource respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)];
    BOOL implementsFooterReferenceDelegate = [flowDataSource respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)];

    NSInteger numberOfSections = [self.collectionView numberOfSections];
    for (NSInteger section = 0; section < numberOfSections; section++) {
        PSTGridLayoutSection *layoutSection = [_data addSection];
        layoutSection.verticalInterstice = _data.horizontal ? self.minimumInteritemSpacing : self.minimumLineSpacing;
        layoutSection.horizontalInterstice = !_data.horizontal ? self.minimumInteritemSpacing : self.minimumLineSpacing;

        if ([flowDataSource respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            layoutSection.sectionMargins = [flowDataSource collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }else {
            layoutSection.sectionMargins = self.sectionInset;
        }

        if ([flowDataSource respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            CGFloat minimumLineSpacing = [flowDataSource collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
            if (_data.horizontal) {
                layoutSection.horizontalInterstice = minimumLineSpacing;
            }else {
                layoutSection.verticalInterstice = minimumLineSpacing;
            }
        }

        if ([flowDataSource respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            CGFloat minimumInterimSpacing = [flowDataSource collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
            if (_data.horizontal) {
                layoutSection.verticalInterstice = minimumInterimSpacing;
            }else {
                layoutSection.horizontalInterstice = minimumInterimSpacing;
            }
        }

        CGSize headerReferenceSize;
        if (implementsHeaderReferenceDelegate) {
            headerReferenceSize = [flowDataSource collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
        }else {
            headerReferenceSize = self.headerReferenceSize;
        }
        layoutSection.headerDimension = _data.horizontal ? headerReferenceSize.width : headerReferenceSize.height;

        CGSize footerReferenceSize;
        if (implementsFooterReferenceDelegate) {
            footerReferenceSize = [flowDataSource collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
        }else {
            footerReferenceSize = self.footerReferenceSize;
        }
        layoutSection.footerDimension = _data.horizontal ? footerReferenceSize.width : footerReferenceSize.height;

        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:section];

        // if delegate implements size delegate, query it for all items
        if (implementsSizeDelegate) {
            for (NSInteger item = 0; item < numberOfItems; item++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:(NSInteger)section];
                CGSize itemSize = implementsSizeDelegate ? [flowDataSource collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath] : self.itemSize;

                PSTGridLayoutItem *layoutItem = [layoutSection addItem];
                layoutItem.itemFrame = (CGRect){.size=itemSize};
            }
            // if not, go the fast path
        }else {
            layoutSection.fixedItemSize = YES;
            layoutSection.itemSize = self.itemSize;
            layoutSection.itemsCount = numberOfItems;
        }
    }
}

- (void)updateItemsLayout {
    CGSize contentSize = CGSizeZero;
    for (PSTGridLayoutSection *section in _data.sections) {
        [section computeLayout];

        // update section offset to make frame absolute (section only calculates relative)
        CGRect sectionFrame = section.frame;
        if (_data.horizontal) {
            sectionFrame.origin.x += contentSize.width;
            contentSize.width += section.frame.size.width + section.frame.origin.x;
            contentSize.height = MAX(contentSize.height, sectionFrame.size.height + section.frame.origin.y + section.sectionMargins.top + section.sectionMargins.bottom);
        }else {
            sectionFrame.origin.y += contentSize.height;
            contentSize.height += sectionFrame.size.height + section.frame.origin.y;
            contentSize.width = MAX(contentSize.width, sectionFrame.size.width + section.frame.origin.x + section.sectionMargins.left + section.sectionMargins.right);
        }
        section.frame = sectionFrame;
    }
    _data.contentSize = contentSize;
}

@end
