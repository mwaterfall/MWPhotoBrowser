//
//  PSTCollectionViewData.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewData.h"
#import "PSTCollectionView.h"

@interface PSTCollectionViewData () {
    CGRect _validLayoutRect;

    NSInteger _numItems;
    NSInteger _numSections;
    NSInteger *_sectionItemCounts;
//    id __strong* _globalItems; ///< _globalItems appears to be cached layoutAttributes. But adding that work in opens a can of worms, so deferring until later.

/*
 // At this point, I've no idea how _screenPageDict is structured. Looks like some optimization for layoutAttributesForElementsInRect.
 And why UICGPointKey? Isn't that doable with NSValue?

 "<UICGPointKey: 0x11432d40>" = "<NSMutableIndexSet: 0x11432c60>[number of indexes: 9 (in 1 ranges), indexes: (0-8)]";
 "<UICGPointKey: 0xb94bf60>" = "<NSMutableIndexSet: 0x18dea7e0>[number of indexes: 11 (in 2 ranges), indexes: (6-15 17)]";

 (lldb) p (CGPoint)[[[[[collectionView valueForKey:@"_collectionViewData"] valueForKey:@"_screenPageDict"] allKeys] objectAtIndex:0] point]
 (CGPoint) $11 = (x=15, y=159)
 (lldb) p (CGPoint)[[[[[collectionView valueForKey:@"_collectionViewData"] valueForKey:@"_screenPageDict"] allKeys] objectAtIndex:1] point]
 (CGPoint) $12 = (x=15, y=1128)

 // https://github.com/steipete/iOS6-Runtime-Headers/blob/master/UICGPointKey.h

 NSMutableDictionary *_screenPageDict;
 */

    // @steipete

    CGSize _contentSize;
    struct {
        unsigned int contentSizeIsValid:1;
        unsigned int itemCountsAreValid:1;
        unsigned int layoutIsPrepared:1;
    }_collectionViewDataFlags;
}
@property (nonatomic, unsafe_unretained) PSTCollectionView *collectionView;
@property (nonatomic, unsafe_unretained) PSTCollectionViewLayout *layout;
@property (nonatomic, strong) NSArray *cachedLayoutAttributes;

@end

@implementation PSTCollectionViewData

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithCollectionView:(PSTCollectionView *)collectionView layout:(PSTCollectionViewLayout *)layout {
    if ((self = [super init])) {
        _collectionView = collectionView;
        _layout = layout;
    }
    return self;
}

- (void)dealloc {
    free(_sectionItemCounts);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p numItems:%ld numSections:%ld>", NSStringFromClass(self.class), self, (long)self.numberOfItems, (long)self.numberOfSections];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)invalidate {
    _collectionViewDataFlags.itemCountsAreValid = NO;
    _collectionViewDataFlags.layoutIsPrepared = NO;
    _validLayoutRect = CGRectNull;  // don't set CGRectZero in case of _contentSize=CGSizeZero
}

- (CGRect)collectionViewContentRect {
    return (CGRect){.size=_contentSize};
}

- (void)validateLayoutInRect:(CGRect)rect {
    [self validateItemCounts];
    [self prepareToLoadData];

    // TODO: check if we need to fetch data from layout
    if (!CGRectEqualToRect(_validLayoutRect, rect)) {
        _validLayoutRect = rect;
        // we only want cell layoutAttributes & supplementaryView layoutAttributes
        self.cachedLayoutAttributes = [[self.layout layoutAttributesForElementsInRect:rect] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PSTCollectionViewLayoutAttributes *evaluatedObject, NSDictionary *bindings) {
            return ([evaluatedObject isKindOfClass:PSTCollectionViewLayoutAttributes.class] &&
                    ([evaluatedObject isCell] ||
                            [evaluatedObject isSupplementaryView] ||
                            [evaluatedObject isDecorationView]));
        }]];
    }
}

- (NSInteger)numberOfItems {
    [self validateItemCounts];
    return _numItems;
}

- (NSInteger)numberOfItemsBeforeSection:(NSInteger)section {
    [self validateItemCounts];

    NSAssert(section < _numSections, @"request for number of items in section %ld when there are only %ld sections in the collection view", (long)section, (long)_numSections);

    NSInteger returnCount = 0;
    for (int i = 0; i < section; i++) {
        returnCount += _sectionItemCounts[i];
    }

    return returnCount;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    [self validateItemCounts];
    if (section >= _numSections || section < 0) {
        // In case of inconsistency returns the 'less harmful' amount of items. Throwing an exception here potentially
        // causes exceptions when data is consistent. Deleting sections is one of the parts sensitive to this.
        // All checks via assertions are done on CollectionView animation methods, specially 'endAnimations'.
        return 0;
        //@throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Section %d out of range: 0...%d", section, _numSections] userInfo:nil];
    }

    NSInteger numberOfItemsInSection = 0;
    if (_sectionItemCounts) {
        numberOfItemsInSection = _sectionItemCounts[section];
    }
    return numberOfItemsInSection;
}

- (NSInteger)numberOfSections {
    [self validateItemCounts];
    return _numSections;
}

- (CGRect)rectForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectZero;
}

- (NSIndexPath *)indexPathForItemAtGlobalIndex:(NSInteger)index {
    [self validateItemCounts];

    NSAssert(index < _numItems, @"request for index path for global index %ld when there are only %ld items in the collection view", (long)index, (long)_numItems);

    NSInteger section = 0;
    NSInteger countItems = 0;
    for (section = 0; section < _numSections; section++) {
        NSInteger countIncludingThisSection = countItems + _sectionItemCounts[section];
        if (countIncludingThisSection > index) break;
        countItems = countIncludingThisSection;
    }

    NSInteger item = index - countItems;

    return [NSIndexPath indexPathForItem:item inSection:section];
}

- (NSUInteger)globalIndexForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger offset = [self numberOfItemsBeforeSection:indexPath.section] + indexPath.item;
    return (NSUInteger)offset;
}

- (BOOL)layoutIsPrepared {
    return _collectionViewDataFlags.layoutIsPrepared;
}

- (void)setLayoutIsPrepared:(BOOL)layoutIsPrepared {
    _collectionViewDataFlags.layoutIsPrepared = layoutIsPrepared;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetch Layout Attributes

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    [self validateLayoutInRect:rect];
    return self.cachedLayoutAttributes;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private

// ensure item count is valid and loaded
- (void)validateItemCounts {
    if (!_collectionViewDataFlags.itemCountsAreValid) {
        [self updateItemCounts];
    }
}

// query dataSource for new data
- (void)updateItemCounts {
    // query how many sections there will be
    _numSections = 1;
    if ([self.collectionView.dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        _numSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
    if (_numSections <= 0) { // early bail-out
        _numItems = 0;
        free(_sectionItemCounts);
        _sectionItemCounts = 0;
        _collectionViewDataFlags.itemCountsAreValid = YES;
        return;
    }
    // allocate space
    if (!_sectionItemCounts) {
        _sectionItemCounts = malloc(_numSections * sizeof(NSInteger));
    }else {
        _sectionItemCounts = realloc(_sectionItemCounts, _numSections * sizeof(NSInteger));
    }

    // query cells per section
    _numItems = 0;
    for (NSInteger i = 0; i < _numSections; i++) {
        NSInteger cellCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:i];
        _sectionItemCounts[i] = cellCount;
        _numItems += cellCount;
    }

    _collectionViewDataFlags.itemCountsAreValid = YES;
}

- (void)prepareToLoadData {
    if (!self.layoutIsPrepared) {
        [self.layout prepareLayout];
        _contentSize = self.layout.collectionViewContentSize;
        self.layoutIsPrepared = YES;
    }
}

@end
