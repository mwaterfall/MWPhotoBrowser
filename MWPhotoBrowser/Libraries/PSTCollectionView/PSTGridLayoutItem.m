//
//  PSTGridLayoutItem.m
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//

#import "PSTGridLayoutItem.h"

@implementation PSTGridLayoutItem

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p itemFrame:%@>", NSStringFromClass(self.class), self, NSStringFromCGRect(self.itemFrame)];
}

@end
