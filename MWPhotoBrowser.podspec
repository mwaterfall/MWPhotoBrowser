Pod::Spec.new do |s|
    s.name = 'MWPhotoBrowser'
    s.version = '1.4.0'
    s.license = 'MIT'
    s.summary = 'A simple iOS photo browser with optional grid ' \
                'view, captions and selections.'
    s.description = 'MWPhotoBrowser can display one or more images by ' \
                    'providing either UIImage objects, or URLs to files, ' \
                    'web images or library assets. The photo browser ' \
                    'handles the downloading and caching of photos from ' \
                    'the web seamlessly. Photos can be zoomed and panned, ' \
                    'and optional (customisable) captions can be  ' \
                    'displayed. The browser can also be used to allow the ' \
                    'user to select one or more photos using either the ' \
                    'grid or main image view.'
    s.screenshots = ['https://raw.github.com/mwaterfall/MWPhotoBrowser/' \
                     'master/Preview/MWPhotoBrowser1.png',
                     'https://raw.github.com/mwaterfall/MWPhotoBrowser/' \
                     'master/Preview/MWPhotoBrowser2.png',
                     'https://raw.github.com/mwaterfall/MWPhotoBrowser/' \
                     'master/Preview/MWPhotoBrowser3.png',
                     'https://raw.github.com/mwaterfall/MWPhotoBrowser/' \
                     'master/Preview/MWPhotoBrowser4.png',
                     'https://raw.github.com/mwaterfall/MWPhotoBrowser/' \
                     'master/Preview/MWPhotoBrowser5.png',
                     'https://raw.github.com/mwaterfall/MWPhotoBrowser/' \
                     'master/Preview/MWPhotoBrowser6.png']
    s.homepage = 'https://github.com/mwaterfall/MWPhotoBrowser'
    s.author = { 'Michael Waterfall' => 'michaelwaterfall@gmail.com' }
    s.source = {
        :git => 'https://github.com/mwaterfall/MWPhotoBrowser.git',
        :tag => '1.4.0'
    }
    s.platform = :ios, '5.1.1'
    s.source_files = 'MWPhotoBrowser/Classes/*.{h,m}'
    s.resources = 'MWPhotoBrowser/MWPhotoBrowser.bundle'
    s.requires_arc = true
    s.frameworks = 'MessageUI', 'ImageIO', 'QuartzCore', 'AssetsLibrary', 'MapKit'
    s.dependency 'SDWebImage', '~> 3.5.4'
    s.dependency 'MBProgressHUD', '~> 0.8'
    s.dependency 'DACircularProgress'
    s.dependency 'PSTCollectionView', '~> 1.2'
end
