## DACircularProgress

`DACircularProgress` is a `UIView` subclass with circular `UIProgressView` properties.

It was originally built to be an imitation of Facebook's photo progress indicator.

View the included example project for a demonstration.

![Screenshot](https://github.com/danielamitay/DACircularProgress/raw/master/screenshot.png)

## Installation

To use `DACircularProgress`:

- Copy over the `DACircularProgress` folder to your project folder.
- Make sure that your project includes `<QuartzCore.framework>`.
- `#import "DACircularProgressView.h"`

### Example Code

```objective-c

self.progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(140.0f, 30.0f, 40.0f, 40.0f)];
self.progressView.roundedCorners = YES;
self.progressView.trackTintColor = [UIColor clearColor];
[self.view addSubview:self.progressView];
```

- You can also use Interface Builder by adding a `UIView` element and setting its class to `DACircularProgress`

## Notes

### Compatibility

iOS5.0+

### Automatic Reference Counting (ARC) support

`DACircularProgress` was made with ARC enabled by default.

## Contact

- [Personal website](http://danielamitay.com)
- [GitHub](http://github.com/danielamitay)
- [Twitter](http://twitter.com/danielamitay)
- [LinkedIn](http://www.linkedin.com/in/danielamitay)
- [Email](hello@danielamitay.com)

If you use/enjoy `DACircularProgress`, let me know!

## Credits

`DACircularProgress` is brought to you by [Daniel Amitay](http://www.amitay.us) and [contributors to the project](https://github.com/danielamitay/DACircularProgress/contributors). A special thanks to [Cédric Luthi](https://github.com/0xced) for a significant amount of changes. If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/danielamitay/DACircularProgress/issues/new).

## License

### MIT License

Copyright (c) 2013 Daniel Amitay (http://danielamitay.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
