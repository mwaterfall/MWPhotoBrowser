# MWPhotoBrowser

<!--[![CI Status](http://img.shields.io/travis/Michael Waterfall/MWPhotoBrowser.svg?style=flat)](https://travis-ci.org/Michael Waterfall/MWPhotoBrowser)-->
[![Version](https://img.shields.io/cocoapods/v/MWPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/MWPhotoBrowser)
[![License](https://img.shields.io/cocoapods/l/MWPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/MWPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/MWPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/MWPhotoBrowser)

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=mwaterfall&url=https://github.com/mwaterfall/MWPhotoBrowser&title=MWPhotoBrowser&language=&tags=github&category=software)

## A simple iOS photo browser with optional grid view, captions and selections.

MWPhotoBrowser can display one or more images by providing either `UIImage` objects, or URLs to files, web images or library assets. The photo browser handles the downloading and caching of photos from the web seamlessly. Photos can be zoomed and panned, and optional (customisable) captions can be displayed. 

The browser can also be used to allow the user to select one or more photos using either the grid or main image view.

[![Alt][screenshot1_thumb]][screenshot1]    [![Alt][screenshot2_thumb]][screenshot2]    [![Alt][screenshot3_thumb]][screenshot3]    [![Alt][screenshot4_thumb]][screenshot4]    [![Alt][screenshot5_thumb]][screenshot5]    [![Alt][screenshot6_thumb]][screenshot6]

[screenshot1_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser1t.png
[screenshot1]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser1.png
[screenshot2_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser2t.png
[screenshot2]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser2.png
[screenshot3_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser3t.png
[screenshot3]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser3.png
[screenshot4_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser4t.png
[screenshot4]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser4.png
[screenshot5_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser5t.png
[screenshot5]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser5.png
[screenshot6_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser6t.png
[screenshot6]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser6.png

Works on iOS 7+. All strings are localisable so they can be used in apps that support multiple languages.

## Usage

MWPhotoBrowser is designed to be presented within a navigation controller. Simply set the delegate (which must conform to `MWPhotoBrowserDelegate`) and implement the 2 required delegate methods to provide the photo browser with the data in the form of `MWPhoto` objects. You can create an `MWPhoto` object by providing a `UIImage` object, or a URL containing the path to a file, an image online or an asset from the asset library.

`MWPhoto` objects handle caching, file management, downloading of web images, and various optimisations for you. If however you would like to use your own data model to represent photos you can simply ensure your model conforms to the `MWPhoto` protocol. You can then handle the management of caching, downloads, etc, yourself. More information on this can be found in `MWPhotoProtocol.h`.

See the code snippet below for an example of how to implement the photo browser. There is also a simple demo app within the project.

```obj-c
// Create array of MWPhoto objects
self.photos = [NSMutableArray array];
[photos addObject:[MWPhoto photoWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]]]];
[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b.jpg"]]];
[photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b.jpg"]]];

// Create browser (must be done each time photo browser is
// displayed. Photo browser objects cannot be re-used)
MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];

// Set options
browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
browser.wantsFullScreenLayout = YES; // iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)

// Optionally set the current visible photo before displaying
[browser setCurrentPhotoIndex:1];

// Present
[self.navigationController pushViewController:browser animated:YES];

// Manipulate
[browser showNextPhotoAnimated:YES];
[browser showPreviousPhotoAnimated:YES];
[browser setCurrentPhotoIndex:10];
```

Then respond to the required delegate methods:

```obj-c
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
return self.photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
if (index < self.photos.count)
return [self.photos objectAtIndex:index];
return nil;
}
```

You can present the browser modally simply by wrapping it in a new navigation controller and presenting that. The demo app allows you to toggle between the two presentation types.

If using iOS 5 or 6 and you don't want to view the photo browser full screen (for example if you are using view controller containment) then set the photo browser's `wantsFullScreenLayout` property to `NO`. This will mean the status bar will not be affected by the photo browser.


### Grid

In order to properly show the grid of thumbnails, you must ensure the property `enableGrid` is set to `YES`, and implement the following delegate method:

```obj-c
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
```

The photo browser can also start on the grid by enabling the `startOnGrid` property.


### Actions

By default, if the action button is visible then the image (and caption if it exists) are sent to a UIActivityViewController. On iOS 5, a custom action sheet appears allowing them to copy or email the photo.

You can provide a custom action by implementing the following delegate method:

```obj-c
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
// Do your thing!
}
```


### Photo Captions

Photo captions can be displayed simply by setting the `caption` property on specific photos:

```obj-c
MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b.jpg"]];
photo.caption = @"Campervan";
```

No caption will be displayed if the caption property is not set.


#### Custom Captions

By default, the caption is a simple black transparent view with a label displaying the photo's caption in white. If you want to implement your own caption view, follow these steps:

1. Optionally use a subclass of `MWPhoto` for your photos so you can store more data than a simple caption string.
2. Subclass `MWCaptionView` and override `-setupCaption` and `-sizeThatFits:` (and any other UIView methods you see fit) to layout your own view and set it's size. More information on this can be found in `MWCaptionView.h`
3. Implement the `-photoBrowser:captionViewForPhotoAtIndex:` MWPhotoBrowser delegate method (shown below).

Example delegate method for custom caption view:

```obj-c
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
MWPhoto *photo = [self.photos objectAtIndex:index];
MyMWCaptionViewSubclass *captionView = [[MyMWCaptionViewSubclass alloc] initWithPhoto:photo];
return captionView;
}
```


#### Selections

The photo browser can display check boxes allowing the user to select one or more of the photos. To use this feature, simply enable the `displaySelectionButtons` property, and implement the following delegate methods:

```obj-c
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
return [[_selections objectAtIndex:index] boolValue];
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
[_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
}
```


## Installation

MWPhotoBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MWPhotoBrowser"
```


## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Then import the photo browser into your source files (or into your bridging header if you're using with Swift and not using frameworks with Cocoapods):

```obj-c
#import "MWPhotoBrowser.h"
```

If you are using Swift and frameworks, then you can just import the browser into your Swift source file:

```swift
import MWPhotoBrowser
```


## Author

Michael Waterfall, michael@d3i.com


## License

MWPhotoBrowser is available under the MIT license. See the LICENSE file for more info.


## Notes

Demo photos kindly provided by Oliver Waters (<http://twitter.com/oliverwaters>).