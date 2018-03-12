#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Specta.h"
#import "SpectaDSL.h"
#import "SpectaTypes.h"
#import "SpectaUtility.h"
#import "SPTCallSite.h"
#import "SPTCompiledExample.h"
#import "SPTExample.h"
#import "SPTExampleGroup.h"
#import "SPTExcludeGlobalBeforeAfterEach.h"
#import "SPTGlobalBeforeAfterEach.h"
#import "SPTSharedExampleGroups.h"
#import "SPTSpec.h"
#import "SPTTestSuite.h"
#import "XCTest+Private.h"
#import "XCTestCase+Specta.h"

FOUNDATION_EXPORT double SpectaVersionNumber;
FOUNDATION_EXPORT const unsigned char SpectaVersionString[];

