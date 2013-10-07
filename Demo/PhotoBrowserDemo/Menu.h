//
//  Menu.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 21/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface Menu : UITableViewController <MWPhotoBrowserDelegate> {
    UISegmentedControl *_segmentedControl;

}

@property (nonatomic, strong) NSMutableArray *photos;

@property (atomic, strong) ALAssetsLibrary *assetLibrary;
@property (atomic, strong) NSMutableArray *assets;

- (void)loadAssets;

@end
