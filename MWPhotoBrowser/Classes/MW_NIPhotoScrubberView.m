//
// Copyright 2011-2014 NimbusKit
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "MW_NIPhotoScrubberView.h"

#import <QuartzCore/QuartzCore.h>

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "Nimbus requires ARC support."
#endif

static const NSInteger NIPhotoScrubberViewUnknownTag = -1;

@interface MW_NIPhotoScrubberView()

/**
 * @internal
 *
 * A method to encapsulate initilization logic that can be shared by different init methods.
 */
- (void)initializeScrubber;

/**
 * @internal
 *
 * A lightweight method for updating all of the visible thumbnails in the scrubber.
 *
 * This method will force the scrubber to lay itself out, calculate how many thumbnails might
 * be visible, and then lay out the thumbnails and fetch any thumbnail images it can find.
 *
 * This method should never take much time to run, so it can safely be used in layoutSubviews.
 */
- (void)updateVisiblePhotos;

/**
 * @internal
 *
 * Returns a new, autoreleased image view in the style of this photo scrubber.
 *
 * This implementation returns an image with a 1px solid white border and a black background.
 */
- (UIImageView *)photoView;

@end


@implementation MW_NIPhotoScrubberView {
  NSMutableArray* _visiblePhotoViews;
  NSMutableSet* _recycledPhotoViews;

  UIView* _containerView;
  UIImageView* _selectionView;

  // State
  NSInteger _selectedPhotoIndex;

  // Cached data source values
  NSInteger _numberOfPhotos;

  // Cached display values
  NSInteger _numberOfVisiblePhotos;
}

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
      [self initializeScrubber];
  }

  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self initializeScrubber];
    }
    
    return self;
}

- (void)initializeScrubber {
    // Only one finger should be allowed to interact with the scrubber at a time.
    self.multipleTouchEnabled = NO;
    
    _containerView = [[UIView alloc] init];
    _containerView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.1f].CGColor;
    _containerView.layer.borderWidth = 1;
    _containerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3f];
    _containerView.userInteractionEnabled = NO;
    [self addSubview:_containerView];
    
    _selectionView = [self photoView];
    [self addSubview:_selectionView];
    
    _selectedPhotoIndex = -1;
}

#pragma mark - View Creation


- (UIImageView *)photoView {
  UIImageView* imageView = [[UIImageView alloc] init];
  
  imageView.layer.borderColor = [UIColor whiteColor].CGColor;
  imageView.layer.borderWidth = 1;
  imageView.backgroundColor = [UIColor blackColor];
  imageView.clipsToBounds = YES;
  
  imageView.userInteractionEnabled = NO;
  
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  
  imageView.tag = NIPhotoScrubberViewUnknownTag;
  
  return imageView;
}

#pragma mark - Layout


- (CGSize)photoSize {
  CGSize boundsSize = self.bounds.size;

  // These numbers are roughly estimated from the Photos.app's scrubber.
  CGFloat photoWidth  = floorf(boundsSize.height / 2.4f);
  CGFloat photoHeight = floorf(photoWidth * 0.75f);
  
  return CGSizeMake(photoWidth, photoHeight);
}

- (CGSize)selectionSize {
  CGSize boundsSize = self.bounds.size;
  
  // These numbers are roughly estimated from the Photos.app's scrubber.
  CGFloat selectionWidth  = floorf(boundsSize.height / 1.2f);
  CGFloat selectionHeight = floorf(selectionWidth * 0.75f);
  
  return CGSizeMake(selectionWidth, selectionHeight);
}

// The amount of space on either side of the scrubber's left and right edges.
- (CGFloat)horizontalMargins {
  CGSize photoSize = [self photoSize];
  return floorf(photoSize.width / 2);
}

- (CGFloat)spaceBetweenPhotos {
  return 1;
}

// The maximum number of pixels that the scrubber can utilize. The scrubber layer's border
// is contained within this width and must be considered when laying out the thumbnails.
- (CGFloat)maxContentWidth {
  CGSize boundsSize = self.bounds.size;
  CGFloat horizontalMargins = [self horizontalMargins];
  
  CGFloat maxContentWidth = (boundsSize.width
                             - horizontalMargins * 2);
  return maxContentWidth;
}

- (NSInteger)numberOfVisiblePhotos {
  CGSize photoSize = [self photoSize];
  CGFloat spaceBetweenPhotos = [self spaceBetweenPhotos];
  
  // Here's where we take into account the container layer's border because we don't want to
  // display thumbnails on top of the border.
  CGFloat maxContentWidth = ([self maxContentWidth]
                             - _containerView.layer.borderWidth * 2);

  NSInteger numberOfPhotosThatFit = (NSInteger)floor((maxContentWidth + spaceBetweenPhotos)
                                                     / (photoSize.width + spaceBetweenPhotos));
  return MIN(_numberOfPhotos, numberOfPhotosThatFit);
}

- (CGRect)frameForSelectionAtIndex:(NSInteger)photoIndex {
  CGSize photoSize = [self photoSize];
  CGSize selectionSize = [self selectionSize];

  CGFloat containerWidth = _containerView.bounds.size.width;
  // TODO (jverkoey July 21, 2011): I need to figure out why this is necessary.
  // Basically, when there are a lot of photos it seems like the selection frame
  // slowly gets offset from the thumbnail frame it's supposed to be representing until by the end
  // it's off the right edge by a noticeable amount. Trimming off some fat from the right
  // edge seems to fix this.
  if (_numberOfVisiblePhotos < _numberOfPhotos) {
    containerWidth -= photoSize.width / 2;
  }

  // Calculate the offset into the container view based on index/numberOfPhotos.
  CGFloat relativeOffset = floorf((((CGFloat)photoIndex * containerWidth)
                                   / (CGFloat)MAX(1, _numberOfPhotos)));
  
  return CGRectMake(floorf(_containerView.frame.origin.x
                           + relativeOffset
                           + photoSize.width / 2 - selectionSize.width / 2),
                    floorf(_containerView.center.y - selectionSize.height / 2),
                    selectionSize.width, selectionSize.height);
}

- (CGRect)frameForThumbAtIndex:(NSInteger)thumbIndex {
  CGSize photoSize = [self photoSize];
  CGFloat spaceBetweenPhotos = [self spaceBetweenPhotos];
  return CGRectMake(_containerView.layer.borderWidth
                    + (photoSize.width + spaceBetweenPhotos) * thumbIndex,
                    _containerView.layer.borderWidth,
                    photoSize.width, photoSize.height);
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGSize boundsSize = self.bounds.size;
  
  CGSize photoSize = [self photoSize];
  CGFloat spaceBetweenPhotos = [self spaceBetweenPhotos];
  CGFloat maxContentWidth = [self maxContentWidth];

  // Update the total number of visible photos.
  _numberOfVisiblePhotos = [self numberOfVisiblePhotos];

  // Hide views if there isn't any interesting information to show.
  _containerView.hidden = (0 == _numberOfVisiblePhotos);
  _selectionView.hidden = (_selectedPhotoIndex < 0 || _containerView.hidden);

  // Calculate the container width using the number of visible photos.
  CGFloat containerWidth = ((_numberOfVisiblePhotos * photoSize.width)
                            + (MAX(0, _numberOfVisiblePhotos - 1) * spaceBetweenPhotos)
                            + _containerView.layer.borderWidth * 2);

  // Then we center the container in the content area.
  CGFloat containerMargins = MAX(0, floorf((maxContentWidth - containerWidth) / 2));
  CGFloat horizontalMargins = [self horizontalMargins];
  CGFloat containerHeight = photoSize.height + _containerView.layer.borderWidth * 2;

  CGFloat containerLeftMargin = horizontalMargins + containerMargins;
  CGFloat containerTopMargin = floorf((boundsSize.height - containerHeight) / 2);

  _containerView.frame = CGRectMake(containerLeftMargin,
                                    containerTopMargin,
                                    containerWidth,
                                    containerHeight);

  // Don't bother updating the selected photo index if there isn't a selection; the
  // selection view will be hidden anyway.
  if (_selectedPhotoIndex >= 0) {
    _selectionView.frame = [self frameForSelectionAtIndex:_selectedPhotoIndex];
  }

  // Update the frames for all of the thumbnails.
  [self updateVisiblePhotos];
}

// Transforms an index into the number of visible photos into an index into the total
// number of photos.
- (NSInteger)photoIndexAtScrubberIndex:(NSInteger)scrubberIndex {
  return (NSInteger)(ceilf((CGFloat)(scrubberIndex * _numberOfPhotos)
                           / (CGFloat)_numberOfVisiblePhotos)
                     + 0.5f);
}

- (void)updateVisiblePhotos {
  if (nil == self.dataSource) {
    return;
  }

  // This will update the number of visible photos if the layout did indeed change.
  [self layoutIfNeeded];

  // Recycle any views that we no longer need.
  while ([_visiblePhotoViews count] > (NSUInteger)_numberOfVisiblePhotos) {
    UIView* photoView = [_visiblePhotoViews lastObject];
    [photoView removeFromSuperview];

    [_recycledPhotoViews addObject:photoView];

    [_visiblePhotoViews removeLastObject];
  }

  // Lay out the visible photos.
  for (NSUInteger ix = 0; ix < (NSUInteger)_numberOfVisiblePhotos; ++ix) {
    UIImageView* photoView = nil;

    // We must first get the photo view at this index.

    // If there aren't enough visible photo views then try to recycle another view.
    if (ix >= [_visiblePhotoViews count]) {
      photoView = [_recycledPhotoViews anyObject];
      if (nil == photoView) {
        // Couldn't recycle the view, so create a new one.
        photoView = [self photoView];

      } else {
        [_recycledPhotoViews removeObject:photoView];
      }
      [_containerView addSubview:photoView];
      [_visiblePhotoViews addObject:photoView];

    } else {
      photoView = [_visiblePhotoViews objectAtIndex:ix];
    }

    NSInteger photoIndex = [self photoIndexAtScrubberIndex:ix];

    // Only request the thumbnail if this thumbnail's photo index has changed. Otherwise
    // we assume that this photo either already has the thumbnail or it's still loading.
    if (photoView.tag != photoIndex) {
      photoView.tag = photoIndex;

      UIImage* image = [self.dataSource photoScrubberView:self thumbnailAtIndex:photoIndex];
      photoView.image = image;

      if (_selectedPhotoIndex == photoIndex) {
        _selectionView.image = image;
      }
    }

    photoView.frame = [self frameForThumbAtIndex:ix];
  }
}

#pragma mark - Changing Selection


- (NSInteger)photoIndexAtPoint:(CGPoint)point {
  NSInteger photoIndex;
  
  if (point.x <= 0) {
    // Beyond the left edge
    photoIndex = 0;
    
  } else if (point.x >= _containerView.bounds.size.width) {
    // Beyond the right edge
    photoIndex = (_numberOfPhotos - 1);
    
  } else {
    // Somewhere in between
    photoIndex = (NSInteger)(floorf((point.x / _containerView.bounds.size.width) * _numberOfPhotos)
                             + 0.5f);
  }
  
  return photoIndex;
}

- (void)updateSelectionWithPoint:(CGPoint)point {
  NSInteger photoIndex = [self photoIndexAtPoint:point];
  
  if (photoIndex != _selectedPhotoIndex) {
    [self setSelectedPhotoIndex:photoIndex];
    
    if ([self.delegate respondsToSelector:@selector(photoScrubberViewDidChangeSelection:)]) {
      [self.delegate photoScrubberViewDidChangeSelection:self];
    }
  }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  
  UITouch* touch = [touches anyObject];
  CGPoint touchPoint = [touch locationInView:_containerView];

  [self updateSelectionWithPoint:touchPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  
  UITouch* touch = [touches anyObject];
  CGPoint touchPoint = [touch locationInView:_containerView];
  
  [self updateSelectionWithPoint:touchPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:_containerView];
    
    [self updateSelectionWithPoint:touchPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    UITouch* touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:_containerView];
    
    [self updateSelectionWithPoint:touchPoint];
}

#pragma mark - Public


- (void)didLoadThumbnail: (UIImage *)image
                 atIndex: (NSInteger)photoIndex {
  for (UIImageView* thumbView in _visiblePhotoViews) {
    if (thumbView.tag == photoIndex) {
      thumbView.image = image;
      break;
    }
  }

  // Update the selected thumbnail if it's the one that just received a photo.
  if (_selectedPhotoIndex == photoIndex) {
    _selectionView.image = image;
  }
}

- (void)reloadData {
  NSAssert(nil != _dataSource, NSLocalizedString(@"Datasource must not be nil.", nil));

  // Remove any visible photos from the view before we release the sets.
  for (UIView* photoView in _visiblePhotoViews) {
    [photoView removeFromSuperview];
  }

  // If there is no data source then we can't do anything particularly interesting.
  if (nil == _dataSource) {
    return;
  }

  _visiblePhotoViews = [[NSMutableArray alloc] init];
  _recycledPhotoViews = [[NSMutableSet alloc] init];

  // Cache the number of photos.
  _numberOfPhotos = [_dataSource numberOfPhotosInScrubberView:self];

  [self setNeedsLayout];

  // This will call layoutIfNeeded and layoutSubviews will then be called because we
  // set the needsLayout flag.
  [self updateVisiblePhotos];
}

- (void)setSelectedPhotoIndex:(NSInteger)photoIndex animated:(BOOL)animated {
  if (_selectedPhotoIndex != photoIndex) {
    // Don't animate the selection if it was previously invalid.
    animated = animated && (_selectedPhotoIndex >= 0);

    _selectedPhotoIndex = photoIndex;
    
    if (animated) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:0.2];
      [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
      [UIView setAnimationBeginsFromCurrentState:YES];
    }

    _selectionView.frame = [self frameForSelectionAtIndex:_selectedPhotoIndex];
    
    if (animated) {
      [UIView commitAnimations];
    }

    _selectionView.image = [self.dataSource photoScrubberView: self
                                             thumbnailAtIndex: _selectedPhotoIndex];
  }
}

- (void)setSelectedPhotoIndex:(NSInteger)photoIndex {
  [self setSelectedPhotoIndex:photoIndex animated:NO];
}

@end
