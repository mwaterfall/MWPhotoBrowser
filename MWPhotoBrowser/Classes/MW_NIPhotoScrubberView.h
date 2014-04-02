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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol NIPhotoScrubberViewDataSource;
@protocol NIPhotoScrubberViewDelegate;

/**
 * A control built for quickly skimming through a collection of images.
 *
 * @ingroup NimbusPhotos
 *
 * The user interacts with the scrubber by "scrubbing" their finger along the control,
 * or more simply, touching the control and moving their finger along a single axis.
 * Scrubbers can be seen in the Photos.app on the iPad.
 *
 * The thumbnails displayed in a scrubber will be a subset of the overall set of photos.
 * The wider the scrubber, the more thumbnails will be shown. The displayed thumbnails will
 * be chosen at constant intervals in the album, with a larger "selected" thumbnail image
 * that will show whatever image is currently selected. This larger thumbnail will be
 * positioned relatively within the scrubber to show the user what the current selection
 * is in a physically intuitive way.
 *
 * This view is a completely independent view from the photo scroll view so you can choose
 * to use this in your already built photo viewer.
 *
 * @image html scrubber1.png "Screenshot of NIPhotoScrubberView on the iPad."
 *
 * @see NIPhotoScrubberViewDataSource
 * @see NIPhotoScrubberViewDelegate
 */
@interface MW_NIPhotoScrubberView : UIView

#pragma mark Data Source /** @name Data Source */

/**
 * The data source for this scrubber view.
 */
@property (nonatomic, weak) id<NIPhotoScrubberViewDataSource> dataSource;

/**
 * Forces the scrubber view to reload all of its data.
 *
 * This must be called at least once after dataSource has been set in order for the view
 * to gather any presentable information.
 *
 * This method is expensive. It will reset the state of the view and remove all existing
 * thumbnails before requesting the new information from the data source.
 */
- (void)reloadData;

/**
 * Notify the scrubber view that a thumbnail has been loaded at a given index.
 *
 * This method is cheap, so do not be afraid to call it whenever a thumbnail loads.
 * It will only modify visible thumbnails.
 */
- (void)didLoadThumbnail: (UIImage *)image
                 atIndex: (NSInteger)photoIndex;

#pragma mark Delegate /** @name Delegate */

/**
 * The delegate for this scrubber view.
 */
@property (nonatomic, weak) id<NIPhotoScrubberViewDelegate> delegate;

#pragma mark Accessing Selection /** @name Accessing Selection */

/**
 * The selected photo index.
 */
@property (nonatomic, assign) NSInteger selectedPhotoIndex;

/**
 * Set the selected photo with animation.
 */
- (void)setSelectedPhotoIndex:(NSInteger)photoIndex animated:(BOOL)animated;

@end

/**
 * The data source for the photo scrubber.
 *
 * @ingroup NimbusPhotos
 *
 * <h2>Performance Considerations</h2>
 *
 * A scrubber view's purpose is for instantly flipping through an album of photos. As such,
 * it's crucial that your implementation of the data source performs blazingly fast. When
 * the scrubber requests a thumbnail from you you should *not* be hitting the disk or blocking
 * on a network call. If you don't have the thumbnail available at that exact moment, fire
 * off an asynchronous load request (using NIReadFileFromDiskOperation or NIHTTPRequest)
 * and return nil. Once the thumbnail is loaded, call didLoadThumbnail:atIndex: to notify
 * the scrubber that it can display the thumbnail now.
 *
 * It is not recommended to use high-res images for your scrubber thumbnails. This is because
 * the scrubber will keep a large set of images in memory and if you're giving it
 * high-resolution images then you'll find that your app quickly burns through memory.
 * If you don't have access to thumbnails from whatever API you're using then you should consider
 * not using a scrubber.
 *
 * @see NIPhotoScrubberView
 */
@protocol NIPhotoScrubberViewDataSource <NSObject>

@required

#pragma mark Fetching Required Information /** @name Fetching Required Information */

/**
 * Fetches the total number of photos in the scroll view.
 *
 * The value returned in this method will be cached by the scroll view until reloadData
 * is called again.
 */
- (NSInteger)numberOfPhotosInScrubberView:(MW_NIPhotoScrubberView *)photoScrubberView;

/**
 * Fetch the thumbnail image for the given photo index.
 *
 * Please read and understand the performance considerations for this data source.
 */
- (UIImage *)photoScrubberView: (MW_NIPhotoScrubberView *)photoScrubberView
              thumbnailAtIndex: (NSInteger)thumbnailIndex;

@end

/**
 * The delegate for the photo scrubber.
 *
 * @ingroup NimbusPhotos
 *
 * Sends notifications of state changes.
 *
 * @see NIPhotoScrubberView
 */
@protocol NIPhotoScrubberViewDelegate <NSObject>

@optional

#pragma mark Selection Changes /** @name Selection Changes */

/**
 * The photo scrubber changed its selection.
 *
 * Use photoScrubberView.selectedPhotoIndex to access the current selection.
 */
- (void)photoScrubberViewDidChangeSelection:(MW_NIPhotoScrubberView *)photoScrubberView;

@end
