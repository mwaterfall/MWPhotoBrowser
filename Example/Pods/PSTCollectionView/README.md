PSTCollectionView
=================

UPDATE: I'm no longer using PSTCollectionView in any project, but will still accept pull requests for improvements.

Open Source, 100% API compatible replacement of UICollectionView for iOS4.3+

**You want to use UICollectionView, but still need to support older versions of iOS? Then you're gonna love this project.**
Originally I wrote it for [PSPDFKit](http://PSPDFKit.com), my iOS PDF framework that supports text selection and annotations, but this project seemed way too useful for others to keep it for myself :)

**If you want to have PSTCollectionView on iOS4.3/5.x and UICollectionView on iOS6, use PSUICollectionView (basically add PS on any UICollectionView* class to get auto-support for older iOS versions)**
If you always want to use PSTCollectionView, use PSTCollectionView as class names. (replace the UI with PST)

## Current State

Most features work, including the flow layout with fixed or dynamic cell sizes and supplementary views. If you're not doing something fancy, it should just work.
PSTCollectionView is also internally designed very closely to UICollectionView and thus a great study if you're wondering how UICollectionView works. See [HowTo](HowTo.md) for helpful details.

## How can I help?

The best way is if you're already using UICollectionView somewhere. Add PSTCollectionView and try it on iOS4/5. Check if everything works, fix bugs until the result matches 1:1 with iOS6. You can also just pick an issue fron the Issue Tracker and start working there.

Or start playing around with one of the WWDC examples and try to make them work with PSTCollectionView. Most of them already do, but just not as perfect.

You could also write a Pinterest-style layout manager. Can't be that hard.

## Animations

Thanks to Sergey Gavrilyuk ([@octogavrix](https://twitter.com/octogavrix)), animations are supported. It's not perfect yet (see LineExample), but it's a great start.

## ARC

PSTCollectionView works with Xcode 4.5.2+ and ARC.

## Dependencies

PSTCollectionView needs the QuartzCore.framework.

## Interoperability

Another goal (at least super useful for debugging) is interoperability between UI/PST classes:

``` objective-c
UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
PSTCollectionView *collectionView = [[PSTCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:(PSTCollectionViewFlowLayout *)flowLayout];
```

(*) Note that for some methods we can't use the _ underscore variants or we risk to get a false-positive on private API use. I've added some runtime hacks to dynamcially add block forwarders for those cases (mainly for UI/PST interoperability)

## Creator

[Peter Steinberger](http://petersteinberger.com) ([@steipete](https://twitter.com/steipete))
and lots of others! See [Contributors](https://github.com/steipete/PSTCollectionView/graphs/contributors) for a graph. Thanks everyone!

## License

PSTCollectionView is available under the MIT license. See the LICENSE file for more info.
