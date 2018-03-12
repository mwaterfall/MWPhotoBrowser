#import "EXPMatchers+FBSnapshotTest.h"
#import <Expecta/EXPMatcherHelpers.h>
#import <FBSnapshotTestCase/FBSnapshotTestController.h>

@interface EXPExpectFBSnapshotTest()
@property (nonatomic, strong) NSString *referenceImagesDirectory;
@end

@implementation EXPExpectFBSnapshotTest

+ (id)instance
{
    static EXPExpectFBSnapshotTest *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (BOOL)compareSnapshotOfViewOrLayer:(id)viewOrLayer snapshot:(NSString *)snapshot testCase:(id)testCase record:(BOOL)record referenceDirectory:(NSString *)referenceDirectory tolerance:(CGFloat)tolerance error:(NSError **)error

{
    FBSnapshotTestController *snapshotController = [[FBSnapshotTestController alloc] initWithTestClass:[testCase class]];
    snapshotController.recordMode = record;
    snapshotController.referenceImagesDirectory = referenceDirectory;
    snapshotController.usesDrawViewHierarchyInRect = [Expecta usesDrawViewHierarchyInRect];
    snapshotController.deviceAgnostic = [Expecta isDeviceAgnostic];
  
    if (! snapshotController.referenceImagesDirectory) {
        [NSException raise:@"Missing value for referenceImagesDirectory" format:@"Call [[EXPExpectFBSnapshotTest instance] setReferenceImagesDirectory"];
    }

    return [snapshotController compareSnapshotOfViewOrLayer:viewOrLayer
                                                   selector:NSSelectorFromString(snapshot)
                                                 identifier:nil
                                                  tolerance:tolerance
                                                      error:error];
}

+ (NSString *)combinedError:(NSString *)message test:(NSString *)test error:(NSError *)error
{
    NSAssert(message, @"missing message");
    NSAssert(test, @"missing test name");

    NSMutableArray *ary = [NSMutableArray array];

    [ary addObject:[NSString stringWithFormat:@"%@ %@", message, test]];

    for(NSString *key in error.userInfo.keyEnumerator) {
        [ary addObject:[NSString stringWithFormat:@" %@: %@", key, [error.userInfo valueForKey:key]]];
    }

    return [ary componentsJoinedByString:@"\n"];
}

@end

void setGlobalReferenceImageDir(char *reference) {
    NSString *referenceImagesDirectory = [NSString stringWithFormat:@"%s", reference];
    [[EXPExpectFBSnapshotTest instance] setReferenceImagesDirectory:referenceImagesDirectory];
};

@interface EXPExpect(ReferenceDirExtension)
- (NSString *)_getDefaultReferenceDirectory;
@end

@implementation EXPExpect(ReferenceDirExtension)

- (NSString *)_getDefaultReferenceDirectory
{
    NSString *globalReference = [[EXPExpectFBSnapshotTest instance] referenceImagesDirectory];
    if (globalReference) {
        return globalReference;
    }

    // Search the test file's path to find the first folder with the substring "tests"
    // then append "/ReferenceImages" and use that

    NSString *testFileName = [NSString stringWithCString:self.fileName encoding:NSUTF8StringEncoding];
    NSArray *pathComponents = [testFileName pathComponents];

    NSString *firstFolderFound = nil;

    for (NSString *folder in pathComponents.reverseObjectEnumerator) {
        if ([folder.lowercaseString rangeOfString:@"tests"].location != NSNotFound) {
            NSArray *folderPathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents indexOfObject:folder] + 1)];
            NSString *referenceImagesPath = [NSString stringWithFormat:@"%@/ReferenceImages", [folderPathComponents componentsJoinedByString:@"/"]];

            if (!firstFolderFound) {
                firstFolderFound = referenceImagesPath;
            }

            BOOL isDirectory = NO;
            BOOL referenceDirExists = [[NSFileManager defaultManager] fileExistsAtPath:referenceImagesPath isDirectory:&isDirectory];

            // if the folder exists, this is the reference dir for sure
            if (referenceDirExists && isDirectory) {
                return referenceImagesPath;
            }
        }
    }

    // if a reference folder wasn't found, we should create one
    if (firstFolderFound) {
        return firstFolderFound;
    }

    [NSException raise:@"Could not infer reference image folder" format:@"You should provide a reference dir using setGlobalReferenceImageDir(FB_REFERENCE_IMAGE_DIR);"];
    return nil;
}

@end


#import <Specta/Specta.h>
#import <Specta/SpectaUtility.h>
#import <Specta/SPTExample.h>

NSString *sanitizedTestPath();

NSString *sanitizedTestPath(){
    id compiledExample = [[NSThread currentThread] threadDictionary][@"SPTCurrentSpec"]; // SPTSpec
    NSString *name;
    if ([compiledExample respondsToSelector:@selector(name)]) {
        // Specta 0.3 syntax
        name = [compiledExample performSelector:@selector(name)];
    } else if ([compiledExample respondsToSelector:@selector(fileName)]) {
        // Specta 0.2 syntax
        name = [compiledExample performSelector:@selector(fileName)];
    }
    name = [[[[name componentsSeparatedByString:@" test_"] lastObject] stringByReplacingOccurrencesOfString:@"__" withString:@"_"] stringByReplacingOccurrencesOfString:@"]" withString:@""];
    return name;
}

EXPMatcherImplementationBegin(haveValidSnapshotWithTolerance, (CGFloat tolerance)){
    __block NSError *error = nil;

    prerequisite(^BOOL{
        return actual != nil;
    });


    match(^BOOL{
        NSString *referenceImageDir = [self _getDefaultReferenceDirectory];
        NSString *name = sanitizedTestPath();
        if ([actual isKindOfClass:UIViewController.class]) {
            [actual beginAppearanceTransition:YES animated:NO];
            [actual endAppearanceTransition];
            
            actual = [actual view];
        }

        return [EXPExpectFBSnapshotTest compareSnapshotOfViewOrLayer:actual snapshot:name testCase:[self testCase] record:NO referenceDirectory:referenceImageDir tolerance:tolerance error:&error];
    });

    failureMessageForTo(^NSString *{
        if (!actual) {
            return [EXPExpectFBSnapshotTest combinedError:@"Nil was passed into haveValidSnapshot." test:sanitizedTestPath() error:nil];
        }

        return [EXPExpectFBSnapshotTest combinedError:@"expected a matching snapshot in" test:sanitizedTestPath() error:error];
    });

    failureMessageForNotTo(^NSString *{
        return [EXPExpectFBSnapshotTest combinedError:@"expected to not have a matching snapshot in" test:sanitizedTestPath() error:error];
    });
}
EXPMatcherImplementationEnd

EXPMatcherImplementationBegin(haveValidSnapshot, (void)) {
    return self.haveValidSnapshotWithTolerance(0);
}
EXPMatcherImplementationEnd

EXPMatcherImplementationBegin(recordSnapshot, (void)) {
    __block NSError *error = nil;

    BOOL actualIsViewLayerOrViewController = ([actual isKindOfClass:UIView.class] || [actual isKindOfClass:CALayer.class] || [actual isKindOfClass:UIViewController.class]);

    prerequisite(^BOOL{
        return actual != nil && actualIsViewLayerOrViewController;
    });

    match(^BOOL{
        NSString *referenceImageDir = [self _getDefaultReferenceDirectory];
        // For view controllers do the viewWill/viewDid dance, then pass view through
        if ([actual isKindOfClass:UIViewController.class]) {

            [actual beginAppearanceTransition:YES animated:NO];
            [actual endAppearanceTransition];
            actual = [actual view];
        }

        [EXPExpectFBSnapshotTest compareSnapshotOfViewOrLayer:actual snapshot:sanitizedTestPath() testCase:[self testCase] record:YES referenceDirectory:referenceImageDir tolerance:0 error:&error];
        return NO;
    });

    failureMessageForTo(^NSString *{
        if (!actual) {
            return [EXPExpectFBSnapshotTest combinedError:@"Nil was passed into recordSnapshot." test:sanitizedTestPath() error:nil];
        }

        if (!actualIsViewLayerOrViewController) {
            return [EXPExpectFBSnapshotTest combinedError:@"Expected a View, Layer or View Controller." test:sanitizedTestPath() error:nil];
        }
        if (error) {
            return [EXPExpectFBSnapshotTest combinedError:@"expected to record a snapshot in" test:sanitizedTestPath() error:error];
        } else {
            return [NSString stringWithFormat:@"snapshot %@ successfully recorded, replace recordSnapshot with a check", sanitizedTestPath()];
        }
    });

    failureMessageForNotTo(^NSString *{
        if (error) {
            return [EXPExpectFBSnapshotTest combinedError:@"expected to record a snapshot in" test:sanitizedTestPath() error:error];
        } else {
            return [NSString stringWithFormat:@"snapshot %@ successfully recorded, replace recordSnapshot with a check", sanitizedTestPath()];
        }
    });
}
EXPMatcherImplementationEnd

EXPMatcherImplementationBegin(haveValidSnapshotNamedWithTolerance, (NSString *snapshot, CGFloat tolerance)) {
    BOOL snapshotIsNil = (snapshot == nil);
    __block NSError *error = nil;

    prerequisite(^BOOL{
        return actual != nil && !(snapshotIsNil);
    });

    match(^BOOL{
        NSString *referenceImageDir = [self _getDefaultReferenceDirectory];
        if ([actual isKindOfClass:UIViewController.class]) {
            [actual beginAppearanceTransition:YES animated:NO];
            [actual endAppearanceTransition];

            actual = [actual view];
        }
        return [EXPExpectFBSnapshotTest compareSnapshotOfViewOrLayer:actual snapshot:snapshot testCase:[self testCase] record:NO referenceDirectory:referenceImageDir tolerance:tolerance error:&error];
    });

    failureMessageForTo(^NSString *{
        if (!actual) {
            return [EXPExpectFBSnapshotTest combinedError:@"Nil was passed into haveValidSnapshotNamed." test:sanitizedTestPath() error:nil];
        }

        return [EXPExpectFBSnapshotTest combinedError:@"expected a matching snapshot named" test:snapshot error:error];

    });

    failureMessageForNotTo(^NSString *{
        return [EXPExpectFBSnapshotTest combinedError:@"expected not to have a matching snapshot named" test:snapshot error:error];
    });
}
EXPMatcherImplementationEnd

EXPMatcherImplementationBegin(haveValidSnapshotNamed, (NSString *snapshot)) {
    return self.haveValidSnapshotNamedWithTolerance(snapshot, 0);
}
EXPMatcherImplementationEnd

EXPMatcherImplementationBegin(recordSnapshotNamed, (NSString *snapshot)) {
    BOOL snapshotExists = (snapshot != nil);
    BOOL actualIsViewLayerOrViewController = ([actual isKindOfClass:UIView.class] || [actual isKindOfClass:CALayer.class] || [actual isKindOfClass:UIViewController.class]);
    __block NSError *error = nil;
    id actualRef = actual;

    prerequisite(^BOOL{
        return actualRef != nil && snapshotExists && actualIsViewLayerOrViewController;
    });

    match(^BOOL{
        NSString *referenceImageDir = [self _getDefaultReferenceDirectory];
        // For view controllers do the viewWill/viewDid dance, then pass view through
        if ([actual isKindOfClass:UIViewController.class]) {
            [actual beginAppearanceTransition:YES animated:NO];
            [actual endAppearanceTransition];
            actual = [actual view];
        }

        [EXPExpectFBSnapshotTest compareSnapshotOfViewOrLayer:actual snapshot:snapshot testCase:[self testCase] record:YES referenceDirectory:referenceImageDir tolerance:0 error:&error];
        return NO;
    });

    failureMessageForTo(^NSString *{
        if (!actual) {
            return [EXPExpectFBSnapshotTest combinedError:@"Nil was passed into recordSnapshotNamed." test:sanitizedTestPath() error:nil];
        }
        if (!actualIsViewLayerOrViewController) {
            return [EXPExpectFBSnapshotTest combinedError:@"Expected a View, Layer or View Controller." test:snapshot error:nil];
        }
        if (error) {
            return [EXPExpectFBSnapshotTest combinedError:@"expected to record a matching snapshot named" test:snapshot error:error];
        } else {
            return [NSString stringWithFormat:@"snapshot %@ successfully recorded, replace recordSnapshot with a check", snapshot];
        }
    });

    failureMessageForNotTo(^NSString *{
        if (!actualIsViewLayerOrViewController) {
            return [EXPExpectFBSnapshotTest combinedError:@"Expected a View, Layer or View Controller." test:snapshot error:nil];
        }
        if (error) {
            return [EXPExpectFBSnapshotTest combinedError:@"expected to record a matching snapshot named" test:snapshot error:error];
        } else {
            return [NSString stringWithFormat:@"snapshot %@ successfully recorded, replace recordSnapshot with a check", snapshot];
        }
    });
}
EXPMatcherImplementationEnd
