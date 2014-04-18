//
//  MWCaptionView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MWCommon.h"
#import "MWCaptionView.h"
#import "MWPhoto.h"

static const CGFloat labelPadding = 10;

// Private
@interface MWCaptionView () {
    id <MWPhoto> _photo;
    UIToolbar *_contentView;
    UILabel *_label;    
}
@end

@implementation MWCaptionView

- (id)initWithPhoto:(id<MWPhoto>)photo {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        _photo = photo;
        self.userInteractionEnabled = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self setupCaption];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat maxHeight = 9999;
    if (_label.numberOfLines > 0) maxHeight = _label.font.leading*_label.numberOfLines;
    CGSize textSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textSize = [_label.text boundingRectWithSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:_label.font}
                                             context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [_label.text sizeWithFont:_label.font
                           constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                               lineBreakMode:_label.lineBreakMode];
#pragma clang diagnostic pop
    }
    return CGSizeMake(size.width, textSize.height + labelPadding * 2);
}

- (void)setupCaption {
    _contentView = [[UIToolbar alloc] initWithFrame:self.bounds];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7")) {
        // Use iOS 7 blurry goodness
        _contentView.barStyle = UIBarStyleBlackTranslucent;
        _contentView.tintColor = nil;
        _contentView.barTintColor = nil;
        _contentView.barStyle = UIBarStyleBlackTranslucent;
        [_contentView setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        self.layer.allowsGroupOpacity = NO;
    } else {
        // Transparent black with no gloss
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:0 alpha:0.6] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_contentView setBackgroundImage:image forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    [self addSubview:_contentView];
    
    _label = [[UILabel alloc] initWithFrame:CGRectIntegral(CGRectMake(labelPadding, 0,
                                                       self.bounds.size.width-labelPadding*2,
                                                       self.bounds.size.height))];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _label.opaque = NO;
    _label.backgroundColor = [UIColor clearColor];
    if (SYSTEM_VERSION_LESS_THAN(@"6")) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _label.textAlignment = UITextAlignmentCenter;
        _label.lineBreakMode = UILineBreakModeWordWrap;
#pragma clang diagnostic pop
    } else {
        _label.textAlignment = NSTextAlignmentCenter;
        _label.lineBreakMode = NSLineBreakByWordWrapping;
    }

    _label.numberOfLines = 0;
    _label.textColor = [UIColor whiteColor];
    if (SYSTEM_VERSION_LESS_THAN(@"7")) {
        // Shadow on 6 and below
        _label.shadowColor = [UIColor blackColor];
        _label.shadowOffset = CGSizeMake(1, 1);
    }
    _label.font = [UIFont systemFontOfSize:17];
    if ([_photo respondsToSelector:@selector(caption)]) {
        _label.text = [_photo caption] ? [_photo caption] : @" ";
    }
    [_contentView addSubview:_label];
}


@end
