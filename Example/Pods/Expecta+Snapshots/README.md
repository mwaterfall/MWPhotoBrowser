Expecta Matchers for FBSnapshotTestCase
=======================================

[Expecta](https://github.com/specta/expecta) matchers for [ios-snapshot-test-case](https://github.com/facebook/ios-snapshot-test-case).

[![Build Status](https://travis-ci.org/dblock/ios-snapshot-test-case-expecta.svg)](https://travis-ci.org/dblock/ios-snapshot-test-case-expecta)

### Usage

Add `Expecta+Snapshots` to your Podfile, the latest `FBSnapshotTestCase` will come in as a dependency.

``` ruby
pod 'Expecta+Snapshots'
```

### App setup

Use `expect(view).to.recordSnapshotNamed(@"unique snapshot name")` to record a snapshot and `expect(view).to.haveValidSnapshotNamed(@"unique snapshot name")` to check it.

If you project was compiled with Specta included, you have two extra methods that use the spec hierarchy to generate the snapshot name for you: `recordSnapshot()` and `haveValidSnapshot()`. You should only call these once per `it()` block.

If you need the `usesDrawViewHierarchyInRect` property in order to correctly render UIVisualEffect, UIAppearance and Size Classes, call `[Expecta setUsesDrawViewHierarchyInRect:NO];` inside `beforeAll`.

``` Objective-C
#define EXP_SHORTHAND
#include <Specta/Specta.h>
#include <Expecta/Expecta.h>
#include <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#include "FBExampleView.h"

SpecBegin(FBExampleView)

describe(@"manual matching", ^{

    it(@"matches view", ^{
        FBExampleView *view = [[FBExampleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        expect(view).to.recordSnapshotNamed(@"FBExampleView");
        expect(view).to.haveValidSnapshotNamed(@"FBExampleView");
    });

    it(@"doesn't match a view", ^{
        FBExampleView *view = [[FBExampleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        expect(view).toNot.haveValidSnapshotNamed(@"FBExampleViewDoesNotExist");
    });

});

describe(@"test name derived matching", ^{

    it(@"matches view", ^{
        FBExampleView *view = [[FBExampleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        expect(view).to.recordSnapshot();
        expect(view).to.haveValidSnapshot();
    });

    it(@"doesn't match a view", ^{
        FBExampleView *view = [[FBExampleView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        expect(view).toNot.haveValidSnapshot();
    });

});

SpecEnd
```

### Approximation support

If for some reason you want to specify a tolerance for your test, you can use either named or unnamed matchers, where the `tolerance` parameter is a `CGFloat` in the interval `[0, 1]` and it represents the minimum ratio of unmatched points by the total number of points in your snapshot. In the example below, a tolerance of `0.01` means our `view` could be up to `1%` different from the reference image.

``` Objective-C
expect(view).to.haveValidSnapshotWithTolerance(0.01);
expect(view).to.haveValidSnapshotNamedWithTolerance(@"unique snapshot name", 0.01);
```

### Sane defaults

`EXPMatchers+FBSnapshotTest` will automatically figure out the tests folder, and [add a reference image](https://github.com/dblock/ios-snapshot-test-case-expecta/blob/master/EXPMatchers%2BFBSnapshotTest.m#L84-L85) directory, if you'd like to override this, you should include a `beforeAll` block setting the `setGlobalReferenceImageDir` in each file containing tests.

```
beforeAll(^{
    setGlobalReferenceImageDir(FB_REFERENCE_IMAGE_DIR);
});
```


### Example

A complete project can be found in [FBSnapshotTestCaseDemo](FBSnapshotTestCaseDemo).

Notably, take a look at [FBSnapshotTestCaseDemoSpecs.m](FBSnapshotTestCaseDemo/FBSnapshotTestCaseDemoTests/FBSnapshotTestCaseDemoSpecs.m) for a complete example, which is an expanded Specta version version of [FBSnapshotTestCaseDemoTests.m](https://github.com/facebook/ios-snapshot-test-case/blob/master/FBSnapshotTestCaseDemo/FBSnapshotTestCaseDemoTests/FBSnapshotTestCaseDemoTests.m).

Finally you can consult the tests for [ARTiledImageView](https://github.com/dblock/ARTiledImageView/tree/master/IntegrationTests) or [NAMapKit](https://github.com/neilang/NAMapKit/tree/master/Demo/DemoTests).

### License

MIT, see [LICENSE](LICENSE.md)
