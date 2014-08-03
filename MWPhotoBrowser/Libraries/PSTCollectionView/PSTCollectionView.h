//
//  PSTCollectionView.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewLayout.h"
#import "PSTCollectionViewFlowLayout.h"
#import "PSTCollectionViewCell.h"
#import "PSTCollectionViewController.h"
#import "PSTCollectionViewUpdateItem.h"

@class PSTCollectionViewController;

typedef NS_OPTIONS(NSUInteger, PSTCollectionViewScrollPosition) {
    PSTCollectionViewScrollPositionNone                 = 0,

    // The vertical positions are mutually exclusive to each other, but are bitwise or-able with the horizontal scroll positions.
    // Combining positions from the same grouping (horizontal or vertical) will result in an NSInvalidArgumentException.
    PSTCollectionViewScrollPositionTop                  = 1 << 0,
    PSTCollectionViewScrollPositionCenteredVertically   = 1 << 1,
    PSTCollectionViewScrollPositionBottom               = 1 << 2,

    // Likewise, the horizontal positions are mutually exclusive to each other.
    PSTCollectionViewScrollPositionLeft                 = 1 << 3,
    PSTCollectionViewScrollPositionCenteredHorizontally = 1 << 4,
    PSTCollectionViewScrollPositionRight                = 1 << 5
};

typedef NS_ENUM(NSUInteger, PSTCollectionElementCategory) {
    PSTCollectionElementCategoryCell,
    PSTCollectionElementCategorySupplementaryView,
    PSTCollectionElementCategoryDecorationView
};

// Define the `PSTCollectionViewDisableForwardToUICollectionViewSentinel` to disable the automatic forwarding to UICollectionView on iOS 6+. (Copy below line into your AppDelegate.m)
//@interface PSTCollectionViewDisableForwardToUICollectionViewSentinel : NSObject @end @implementation PSTCollectionViewDisableForwardToUICollectionViewSentinel @end

// API-compatible replacement for UICollectionView.
// Works on iOS 4.3 upwards (including iOS 6).
@interface PSTCollectionView : UIScrollView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(PSTCollectionViewLayout *)layout; // the designated initializer

@property (nonatomic, strong) PSTCollectionViewLayout *collectionViewLayout;
@property (nonatomic, assign) IBOutlet id<PSTCollectionViewDelegate> delegate;
@property (nonatomic, assign) IBOutlet id<PSTCollectionViewDataSource> dataSource;
@property (nonatomic, strong) UIView *backgroundView; // will be automatically resized to track the size of the collection view and placed behind all cells and supplementary views.

// For each reuse identifier that the collection view will use, register either a class or a nib from which to instantiate a cell.
// If a nib is registered, it must contain exactly 1 top level object which is a PSTCollectionViewCell.
// If a class is registered, it will be instantiated via alloc/initWithFrame:
- (void)registerClass:(Class)cellClass forCellWithReuseIdentifier:(NSString *)identifier;

- (void)registerClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier;

- (void)registerNib:(UINib *)nib forCellWithReuseIdentifier:(NSString *)identifier;

// TODO: implement!
- (void)registerNib:(UINib *)nib forSupplementaryViewOfKind:(NSString *)kind withReuseIdentifier:(NSString *)identifier;

- (id)dequeueReusableCellWithReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

- (id)dequeueReusableSupplementaryViewOfKind:(NSString *)elementKind withReuseIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;

// These properties control whether items can be selected, and if so, whether multiple items can be simultaneously selected.
@property (nonatomic) BOOL allowsSelection; // default is YES
@property (nonatomic) BOOL allowsMultipleSelection; // default is NO

- (NSArray *)indexPathsForSelectedItems; // returns nil or an array of selected index paths
- (void)selectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(PSTCollectionViewScrollPosition)scrollPosition;

- (void)deselectItemAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)reloadData; // discard the dataSource and delegate data and requery as necessary

- (void)setCollectionViewLayout:(PSTCollectionViewLayout *)layout animated:(BOOL)animated; // transition from one layout to another

// Information about the current state of the collection view.

- (NSInteger)numberOfSections;

- (NSInteger)numberOfItemsInSection:(NSInteger)section;

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;

- (PSTCollectionViewLayoutAttributes *)layoutAttributesForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForItemAtPoint:(CGPoint)point;

- (NSIndexPath *)indexPathForCell:(PSTCollectionViewCell *)cell;

- (PSTCollectionViewCell *)cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSArray *)visibleCells;

- (NSArray *)indexPathsForVisibleItems;

// Interacting with the collection view.

- (void)scrollToItemAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(PSTCollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;

// These methods allow dynamic modification of the current set of items in the collection view
- (void)insertSections:(NSIndexSet *)sections;
- (void)deleteSections:(NSIndexSet *)sections;
- (void)reloadSections:(NSIndexSet *)sections;
- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection;
- (void)insertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)deleteItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)reloadItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;
- (void)performBatchUpdates:(void (^)(void))updates completion:(void (^)(BOOL finished))completion; // allows multiple insert/delete/reload/move calls to be animated simultaneously. Nestable.

@end

// To dynamically switch between PSTCollectionView and UICollectionView, use the PSUICollectionView* classes.
#define PSUICollectionView PSUICollectionView_
#define PSUICollectionViewCell PSUICollectionViewCell_
#define PSUICollectionReusableView PSUICollectionReusableView_
#define PSUICollectionViewDelegate PSTCollectionViewDelegate
#define PSUICollectionViewDataSource PSTCollectionViewDataSource
#define PSUICollectionViewLayout PSUICollectionViewLayout_
#define PSUICollectionViewFlowLayout PSUICollectionViewFlowLayout_
#define PSUICollectionViewDelegateFlowLayout PSTCollectionViewDelegateFlowLayout
#define PSUICollectionViewLayoutAttributes PSUICollectionViewLayoutAttributes_
#define PSUICollectionViewController PSUICollectionViewController_

@interface PSUICollectionView_ : PSTCollectionView @end
@interface PSUICollectionViewCell_ : PSTCollectionViewCell @end
@interface PSUICollectionReusableView_ : PSTCollectionReusableView @end
@interface PSUICollectionViewLayout_ : PSTCollectionViewLayout @end
@interface PSUICollectionViewFlowLayout_ : PSTCollectionViewFlowLayout @end
@protocol PSUICollectionViewDelegateFlowLayout_ <PSTCollectionViewDelegateFlowLayout> @end
@interface PSUICollectionViewLayoutAttributes_ : PSTCollectionViewLayoutAttributes @end
@interface PSUICollectionViewController_ : PSTCollectionViewController <PSUICollectionViewDelegate, PSUICollectionViewDataSource> @end
