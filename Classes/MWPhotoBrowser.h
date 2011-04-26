//
//  MWPhotoBrowser.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhoto.h"

@class ZoomingScrollView;

@interface MWPhotoBrowser : UIViewController <UIScrollViewDelegate, MWPhotoDelegate> {
	
	// Photos
	NSArray *photos;
	
	// Views
	UIScrollView *pagingScrollView;
	
	// Paging
	NSMutableSet *visiblePages, *recycledPages;
	int currentPageIndex;
	int pageIndexBeforeRotation;
	
	// Navigation & controls
	UIToolbar *toolbar;
	NSTimer *controlVisibilityTimer;
	UIBarButtonItem *previousButton, *nextButton;

	UIColor *previousNavigationBarTintColor;
	UIBarStyle previousNavigationBarStyle;
	UIStatusBarStyle previousStatusBarStyle;
	BOOL previousStatusBarHidden;

	BOOL performingLayout;
	BOOL rotating;
	
}

// Init
- (id)initWithPhotos:(NSArray *)photosArray;

// Photos
- (UIImage *)imageAtIndex:(int)index;

// Layout
- (void)performLayout;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(int)index;
- (ZoomingScrollView *)pageDisplayedAtIndex:(int)index;
- (ZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(ZoomingScrollView *)page forIndex:(int)index;
- (void)didStartViewingPageAtIndex:(int)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(int)index;
- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;

// Navigation
- (void)updateNavigation;
- (void)jumpToPageAtIndex:(int)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden;
- (void)toggleControls;

// Properties
- (void)setInitialPageIndex:(int)index;

@end

