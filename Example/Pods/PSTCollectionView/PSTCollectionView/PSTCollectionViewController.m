//
//  PSTCollectionViewController.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTCollectionViewController.h"
#import "PSTCollectionView.h"

@interface PSTCollectionViewController () {
    PSTCollectionViewLayout *_layout;
    PSTCollectionView *_collectionView;
    struct {
        unsigned int clearsSelectionOnViewWillAppear : 1;
        unsigned int appearsFirstTime : 1; // PST extension!
    }_collectionViewControllerFlags;
    char filler[100]; // [HACK] Our class needs to be larger than Apple's class for the superclass change to work.
}
@property (nonatomic, strong) PSTCollectionViewLayout *layout;
@end

@implementation PSTCollectionViewController

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layout = [PSTCollectionViewFlowLayout new];
        self.clearsSelectionOnViewWillAppear = YES;
        _collectionViewControllerFlags.appearsFirstTime = YES;
    }
    return self;
}

- (id)initWithCollectionViewLayout:(PSTCollectionViewLayout *)layout {
    if ((self = [super init])) {
        self.layout = layout;
        self.clearsSelectionOnViewWillAppear = YES;
        _collectionViewControllerFlags.appearsFirstTime = YES;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

- (void)loadView {
    [super loadView];

    // if this is restored from IB, we don't have plain main view.
    if ([self.view isKindOfClass:PSTCollectionView.class]) {
        _collectionView = (PSTCollectionView *)self.view;
        self.view = [[UIView alloc] initWithFrame:self.view.bounds];
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }

    if (_collectionView.delegate == nil) _collectionView.delegate = self;
    if (_collectionView.dataSource == nil) _collectionView.dataSource = self;

    // only create the collection view if it is not already created (by IB)
    if (!_collectionView) {
        self.collectionView = [[PSTCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // This seems like a hack, but is needed for real compatibility
    // There can be implementations of loadView that don't call super and don't set the view, yet it works in UICollectionViewController.
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] initWithFrame:CGRectZero];
    }

    // Attach the view
    if (self.view != self.collectionView) {
        [self.view addSubview:self.collectionView];
        self.collectionView.frame = self.view.bounds;
        self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_collectionViewControllerFlags.appearsFirstTime) {
        [_collectionView reloadData];
        _collectionViewControllerFlags.appearsFirstTime = NO;
    }

    if (_collectionViewControllerFlags.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath *aIndexPath in [[_collectionView indexPathsForSelectedItems] copy]) {
            [_collectionView deselectItemAtIndexPath:aIndexPath animated:animated];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lazy load the collection view

- (PSTCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[PSTCollectionView alloc] initWithFrame:UIScreen.mainScreen.bounds collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;

        // If the collection view isn't the main view, add it.
        if (self.isViewLoaded && self.view != self.collectionView) {
            [self.view addSubview:self.collectionView];
            self.collectionView.frame = self.view.bounds;
            self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        }
    }
    return _collectionView;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Properties

- (void)setClearsSelectionOnViewWillAppear:(BOOL)clearsSelectionOnViewWillAppear {
    _collectionViewControllerFlags.clearsSelectionOnViewWillAppear = (unsigned int)clearsSelectionOnViewWillAppear;
}

- (BOOL)clearsSelectionOnViewWillAppear {
    return _collectionViewControllerFlags.clearsSelectionOnViewWillAppear;
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PSTCollectionViewDataSource

- (NSInteger)collectionView:(PSTCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 0;
}

- (PSTCollectionViewCell *)collectionView:(PSTCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
