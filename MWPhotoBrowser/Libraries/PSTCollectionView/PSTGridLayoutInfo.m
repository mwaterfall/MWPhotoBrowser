//
//  PSTGridLayoutInfo.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTGridLayoutInfo.h"
#import "PSTGridLayoutSection.h"
#import "PSTGridLayoutItem.h"

@interface PSTGridLayoutInfo () {
    NSMutableArray *_sections;
    CGRect _visibleBounds;
    CGSize _layoutSize;
    BOOL _isValid;
}
@property (nonatomic, strong) NSMutableArray *sections;
@end

@implementation PSTGridLayoutInfo

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _sections = [NSMutableArray new];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p dimension:%.1f horizontal:%d contentSize:%@ sections:%@>", NSStringFromClass(self.class), self, self.dimension, self.horizontal, NSStringFromCGSize(self.contentSize), self.sections];
}

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (PSTGridLayoutInfo *)snapshot {
    PSTGridLayoutInfo *layoutInfo = [self.class new];
    layoutInfo.sections = self.sections;
    layoutInfo.rowAlignmentOptions = self.rowAlignmentOptions;
    layoutInfo.usesFloatingHeaderFooter = self.usesFloatingHeaderFooter;
    layoutInfo.dimension = self.dimension;
    layoutInfo.horizontal = self.horizontal;
    layoutInfo.leftToRight = self.leftToRight;
    layoutInfo.contentSize = self.contentSize;
    return layoutInfo;
}

- (CGRect)frameForItemAtIndexPath:(NSIndexPath *)indexPath {
    PSTGridLayoutSection *section = self.sections[indexPath.section];
    CGRect itemFrame;
    if (section.fixedItemSize) {
        itemFrame = (CGRect){.size=section.itemSize};
    }else {
        itemFrame = [section.items[indexPath.item] itemFrame];
    }
    return itemFrame;
}

- (id)addSection {
    PSTGridLayoutSection *section = [PSTGridLayoutSection new];
    section.rowAlignmentOptions = self.rowAlignmentOptions;
    section.layoutInfo = self;
    [_sections addObject:section];
    [self invalidate:NO];
    return section;
}

- (void)invalidate:(BOOL)arg {
    _isValid = NO;
}

@end
