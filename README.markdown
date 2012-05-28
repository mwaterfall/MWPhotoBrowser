# MWPhotoBrowser — A simple iOS photo browser

MWPhotoBrowser is an implementation of a photo browser similar to the native Photos app in iOS. It can display one or more images by providing either `UIImage` objects, file paths to images on the device, or URLs to images online. The photo browser handles the downloading and caching of photos from the web seamlessly. Photos can be zoomed and panned, and optional (customisable) captions can be displayed. Works on iOS 3.2+. All strings are localisable so they can be used in apps that support multiple languages.

[![Alt][screenshot1_thumb]][screenshot1]    [![Alt][screenshot2_thumb]][screenshot2]    [![Alt][screenshot3_thumb]][screenshot3]    [![Alt][screenshot4_thumb]][screenshot4]
[screenshot1_thumb]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser1_thumb.png
[screenshot1]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser1.png
[screenshot2_thumb]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser2_thumb.png
[screenshot2]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser2.png
[screenshot3_thumb]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser3_thumb.png
[screenshot3]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser3.png
[screenshot4_thumb]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser4_thumb.png
[screenshot4]: http://dl.dropbox.com/u/2111839/Permanent/MWPhotoBrowser/mwphotobrowser4.png


## Usage

MWPhotoBrowser is designed to be presented within a navigation controller. Simply set the delegate (which must conform to `MWPhotoBrowserDelegate`) and implement the 2 required delegate methods to provide the photo browser with the data in the form of `MWPhoto` objects. You can create an `MWPhoto` object by providing a `UIImage` object, a file path to a physical image file, or a URL to an image online.

`MWPhoto` objects handle caching, file management, downloading of web images, and various optimisations for you. If however you would like to use your own data model to represent photos you can simply ensure your model conforms to the `MWPhoto` protocol. You can then handle the management of caching, downloads, etc, yourself. More information on this can be found in `MWPhotoProtocol.h`. 

See the code snippet below for an example of how to implement the photo browser. There is also a simple demo app within the project.

    // Create array of `MWPhoto` objects
    self.photos = [NSMutableArray array];
    [photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]]];
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b.jpg"]]];
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b.jpg"]]];

    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Set options
    browser.wantsFullScreenLayout = YES; // Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
    browser.displayActionButton = YES; // Show action button to save, copy or email photos (defaults to NO)
    [browser setInitialPageIndex:1]; // Example: allows second image to be presented first
    // Present
    [self.navigationController pushViewController:browser animated:YES];

Then respond to the required delegate methods:

    - (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
        return self.photos.count;
    }

    - (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
        if (index < self.photos.count)
            return [self.photos objectAtIndex:index];
        return nil;
    }

You can present the browser modally simply by wrapping it in a new navigation controller and presenting that. The demo app allows you to toggle between the two presentation types.

If you don't want to view the photo browser full screen (for example if you are using view controller containment in iOS 5) then set the photo browser's `wantsFullScreenLayout` property to `NO`. This will mean the status bar will not be affected by the photo browser.


### Photo Captions

Photo captions can be displayed simply by setting the `caption` property on specific photos:

    MWPhoto *photo = [MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]];
    photo.caption = @"Campervan";

No caption will be displayed if the caption property is not set.


#### Custom Captions

By default, the caption is a simple black transparent view with a label displaying the photo's caption in white. If you want to implement your own caption view, follow these steps:

1. Optionally use a subclass of `MWPhoto` for your photos so you can store more data than a simple caption string.
2. Subclass `MWCaptionView` and override `-setupCaption` and `-sizeThatFits:` (and any other UIView methods you see fit) to layout your own view and set it's size. More information on this can be found in `MWCaptionView.h`
3. Implement the `-photoBrowser:captionViewForPhotoAtIndex:` MWPhotoBrowser delegate method (shown below).

Example delegate method for custom caption view:

    - (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
        MWPhoto *photo = [self.photos objectAtIndex:index];
        MyMWCaptionViewSubclass *captionView = [[MyMWCaptionViewSubclass alloc] initWithPhoto:photo];
        return [captionView autorelease];
    }


## Adding to your project (Xcode 4)

### Method 1: Static Library

1. Get the latest source from GitHub by either [downloading as a zip file](https://github.com/mwaterfall/MWPhotoBrowser/zipball/master) or by cloning the repository at `git://github.com/mwaterfall/MWPhotoBrowser.git` and store the code wherever you wish.
2. Right-click on the your project in the navigator, click "Add Files to 'Your Project'", and browse to and select "MWPhotoBrowser.xcodeproj"
3. In your project's target settings, go to "Build Phases" -> "Link Binary With Libraries" and add `libMWPhotoBrowser.a`.
4. Still in "Build Phases", drop down "Copy Bundle Resources" and drag the file `MWPhotoBrowser.bundle` from the MWPhotoBrowser project into that list. This ensures your project will include the required graphics for the photo browser to work correctly.
5. In the target, select the "Build Settings" tab and ensure "Always Search User Paths" is set to YES, and "User Header Search Paths" is set to the recursive absolute or relative path that points to a directory under which the MWPhotoBrowser code is stored. In the file layout of the MWPhotoBrowser project, a simple ../** works as the demo project folder and MWPhotoBrowser project folder are adjacent to one another. Please let me know if you encounter any issue with this.
6. In "Summary" add `MessageUI.framework` and `ImageIO.framework` to "Linked Frameworks and Libraries".

You should now be able to include `MWPhotoBrowser.h` into your project and start using it.

Setting these things up in Xcode 4 can be a bit tricky so if you run into any problems you may wish to read through a few bits of information:

- [Developing a Static Library and Incorporating It in Your Application](http://developer.apple.com/library/ios/#documentation/Xcode/Conceptual/ios_development_workflow/910-A-Developing_a_Static_Library_and_Incorporating_It_in_Your_Application/archiving_an_application_that_uses_a_static_library.html)
- [Using Open Source Static Libraries in Xcode 4](http://blog.carbonfive.com/2011/04/04/using-open-source-static-libraries-in-xcode-4/#using_a_static_library)
- [How to embed static library into Xcode 4 project](https://docs.google.com/document/pub?id=14XR5zcZb2Kz2s6A4AbzB00NLkrW9bWxMMprVsUao-hY)

### Method 2: Including Source Directly Into Your Project

Another method is to simply add the files to your Xcode project, copying them to your project's directory if required. Ensure that all the code within `MWPhotoBrowser/Classes`, `MWPhotoBrowser/Libraries` and the `MWPhotoBrowser.bundle` is included in your project. 

If your project uses ARC then you will have to disable ARC for each of the files in MWPhotoBrowser. Here's how you do it: http://stackoverflow.com/a/6658549/106244


## Outstanding issues and improvements

*Nothing outstanding*


## Notes and Accreditation

MWPhotoBrowser very gratefully makes use of 2 other fantastic open source projects:

- [SDWebImage](https://github.com/rs/SDWebImage) by Olivier Poitrey — Used to handle downloading and decompressing of photos from the web.
- [MBProgressHUD](https://github.com/jdg/MBProgressHUD) by Jonathan George — Used to display notifications of photo saving and copying progress/completion.

Demo photos kindly provided by Oliver Waters (<http://twitter.com/oliverwaters>).


## Licence

Copyright (c) 2010 Michael Waterfall

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