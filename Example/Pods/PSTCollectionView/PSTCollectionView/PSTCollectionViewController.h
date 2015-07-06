//
//  PSTCollectionViewController.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewCommon.h"

@class PSTCollectionViewLayout, PSTCollectionViewController;

// Simple controller-wrapper around PSTCollectionView.
@interface PSTCollectionViewController : UIViewController <PSTCollectionViewDelegate, PSTCollectionViewDataSource>

// Designated initializer.
- (id)initWithCollectionViewLayout:(PSTCollectionViewLayout *)layout;

// Internally used collection view. If not set, created during loadView.
@property (nonatomic, strong) PSTCollectionView *collectionView;

// Defaults to YES, and if YES, any selection is cleared in viewWillAppear:
@property (nonatomic, assign) BOOL clearsSelectionOnViewWillAppear;

@end
