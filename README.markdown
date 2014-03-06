# MWPhotoBrowser

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=mwaterfall&url=https://github.com/mwaterfall/MWPhotoBrowser&title=MWPhotoBrowser&language=&tags=github&category=software)

## A simple iOS photo browser with optional grid view, captions and selections.

MWPhotoBrowser can display one or more images by providing either `UIImage` objects, or URLs to files, web images or library assets. The photo browser handles the downloading and caching of photos from the web seamlessly. Photos can be zoomed and panned, and optional (customisable) captions can be displayed. 

The browser can also be used to allow the user to select one or more photos using either the grid or main image view.

[![Alt][screenshot1_thumb]][screenshot1]    [![Alt][screenshot2_thumb]][screenshot2]    [![Alt][screenshot3_thumb]][screenshot3]    [![Alt][screenshot4_thumb]][screenshot4]    [![Alt][screenshot5_thumb]][screenshot5]    [![Alt][screenshot6_thumb]][screenshot6]

[screenshot1_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser1t.png
[screenshot1]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser1.png
[screenshot2_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser2t.png
[screenshot2]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser2.png
[screenshot3_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser3t.png
[screenshot3]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser3.png
[screenshot4_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser4t.png
[screenshot4]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser4.png
[screenshot5_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser5t.png
[screenshot5]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser5.png
[screenshot6_thumb]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser6t.png
[screenshot6]: https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Preview/MWPhotoBrowser6.png

Works on iOS 5.1.1+. All strings are localisable so they can be used in apps that support multiple languages.

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


## Adding to your project

### Method 1: Use CocoaPods

[CocoaPods](http://cocoapods.org) is great. If you are using CocoaPods ([and here's how to get started](http://guides.cocoapods.org/using/using-cocoapods.html)), simply add `pod 'MWPhotoBrowser'` to your podfile and run `pod install`. You're good to go! Here's an example podfile:

```
platform :ios, '7'
    pod 'MWPhotoBrowser'
```


### Method 2: Static Library

1. Get the latest source from GitHub by either [downloading as a zip file](https://github.com/mwaterfall/MWPhotoBrowser/zipball/master) or by cloning the repository at `git://github.com/mwaterfall/MWPhotoBrowser.git` and store the code wherever you wish.
2. Right-click on the your project in the navigator, click "Add Files to 'Your Project'", and browse to and select "MWPhotoBrowser.xcodeproj"
3. In your project's target settings, go to "Build Phases" -> "Link Binary With Libraries" and add `libMWPhotoBrowser.a`.
4. Still in "Build Phases", drop down "Copy Bundle Resources" and drag the file `MWPhotoBrowser.bundle` from the MWPhotoBrowser project into that list. This ensures your project will include the required graphics for the photo browser to work correctly.
5. In the target, select the "Build Settings" tab and ensure "Always Search User Paths" is set to YES, and "User Header Search Paths" is set to the recursive absolute or relative path that points to a directory under which the MWPhotoBrowser code is stored. In the file layout of the MWPhotoBrowser project, a simple ../** works as the demo project folder and MWPhotoBrowser project folder are adjacent to one another. Please let me know if you encounter any issue with this.
6. Under "Build Phases / Link Binary With Libraries" add `MessageUI.framework`, `QuartzCore.framework`, `AssetsLibrary.framework` and `ImageIO.framework` to "Linked Frameworks and Libraries".

You should now be able to include `MWPhotoBrowser.h` into your project and start using it.

Setting these things up in Xcode can be a bit tricky so if you run into any problems you may wish to read through a few bits of information:

- [Developing a Static Library and Incorporating It in Your Application](http://developer.apple.com/library/ios/#documentation/Xcode/Conceptual/ios_development_workflow/910-A-Developing_a_Static_Library_and_Incorporating_It_in_Your_Application/archiving_an_application_that_uses_a_static_library.html)
- [Using Open Source Static Libraries in Xcode 4](http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4/#using_a_static_library)
- [How to embed static library into Xcode 4 project](https://docs.google.com/document/pub?id=14XR5zcZb2Kz2s6A4AbzB00NLkrW9bWxMMprVsUao-hY)

### Method 3: Including Source Directly Into Your Project

Another method is to simply add the files to your Xcode project, copying them to your project's directory if required. Ensure that all the code within `MWPhotoBrowser/Classes`, `MWPhotoBrowser/Libraries` and the `MWPhotoBrowser.bundle` is included in your project.


## Notes and Accreditation

MWPhotoBrowser very gratefully makes use of these other fantastic open source projects:

- [SDWebImage](https://github.com/rs/SDWebImage) by Olivier Poitrey — Used to handle downloading and decompressing of photos from the web.
- [MBProgressHUD](https://github.com/jdg/MBProgressHUD) by Jonathan George — Used to display activity notifications.
- [DACircularProgress](https://github.com/danielamitay/DACircularProgress) by Daniel Amitay — Used to display image download progress.

Demo photos kindly provided by Oliver Waters (<http://twitter.com/oliverwaters>).


## Licence

Copyright (c) 2010-2013 Michael Waterfall

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.