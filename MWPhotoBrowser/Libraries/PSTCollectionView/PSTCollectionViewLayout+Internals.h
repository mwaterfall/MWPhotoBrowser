//
//  PSTCollectionViewLayout+Internals.h
//  FMPSTCollectionView
//
//  Created by Scott Talbot on 27/02/13.
//  Copyright (c) 2013 Scott Talbot. All rights reserved.
//

#import "PSTCollectionViewLayout.h"


@interface PSTCollectionViewLayout (Internals)

@property (nonatomic, copy, readonly) NSDictionary *decorationViewClassDict;
@property (nonatomic, copy, readonly) NSDictionary *decorationViewNibDict;
@property (nonatomic, copy, readonly) NSDictionary *decorationViewExternalObjectsTables;

@end
