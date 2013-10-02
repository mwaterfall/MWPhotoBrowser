//
//  Menu.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 21/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface Menu : UITableViewController <MWPhotoBrowserDelegate> {
    UISegmentedControl *_segmentedControl;
}

@property (nonatomic, strong) NSMutableArray *photos;

@end
