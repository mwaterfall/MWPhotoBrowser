# MWPhotoBrowser — A simple iOS photo browser

MWPhotoBrowser is an implementation of a photo browser similar to the native Photos app in iOS. It can display one or more images by providing either `UIImage` objects, file paths to images on the device, or URLs images online. Photos can also be zoomed and panned.

***Photos kindly provided by Oliver Waters (<http://twitter.com/oliverwaters>)***


## Usage

MWPhotoBrowser is designed to be presented within a navigation controller. You pass the browser an array of `MWPhoto` objects to display. You can create an `MWPhoto` object by providing a `UIImage` object, a file path to a physical image file, or a URL to an image.

See the code snippet below for an example of how to implement the photo browser. There is also a simple demo project within the project.

    // Create array of `MWPhoto` objects
    NSMutableArray *photos = [NSMutableArray array];
    [photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo2l" ofType:@"jpg"]]];
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3629/3339128908_7aecabc34b.jpg"]]];
    [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:@"http://farm4.static.flickr.com/3590/3329114220_5fbc5bc92b.jpg"]]];

    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photos];
    [self.navigationController pushViewController:browser animated:YES];

If desired, you can choose which photo is displayed first:

    // Create & present browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:photos];
    [browser setInitialPageIndex:2]; // Show second page first
    [self.navigationController pushViewController:browser animated:YES];


## Adding to your project

1. Open `MWPhotoBrowser.xcodeproj`.
2. Drag the `MWPhotoBrowser`, `Subclasses` and `Categories` groups into your project, ensuring you check **"Copy items into destination group's folder"**.
3. Copy the 4 `UIBarButtonItemArrow*.png` images and add them as resources to your bundle.
4. Import `MWPhotoBrowser.h` into your source as required.


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


Contact
===============

Twitter: 	<http://twitter.com/mwaterfall>