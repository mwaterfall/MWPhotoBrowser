Pod::Spec.new do |s|

  s.name = 'MWPhotoBrowser'
  s.version = '2.1.2'
  s.license = 'MIT'
  s.summary = 'A simple iOS photo and video browser with optional grid view, captions and selections.'
  s.description = <<-DESCRIPTION
                  MWPhotoBrowser can display one or more images or videos by providing either UIImage
                  objects, PHAsset objects, or URLs to library assets, web images/videos or local files.
                  The photo browser handles the downloading and caching of photos from the web seamlessly.
                  Photos can be zoomed and panned, and optional (customisable) captions can be displayed.
                  DESCRIPTION
  s.screenshots = [
    'https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser1.png',
    'https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser2.png',
    'https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser3.png',
    'https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser4.png',
    'https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser5.png',
    'https://raw.github.com/mwaterfall/MWPhotoBrowser/master/Screenshots/MWPhotoBrowser6.png'
  ]

  s.homepage = 'https://github.com/mwaterfall/MWPhotoBrowser'
  s.author = { 'Michael Waterfall' => 'michaelwaterfall@gmail.com' }
  s.social_media_url = 'https://twitter.com/mwaterfall'

  s.source = {
    :git => 'https://github.com/mwaterfall/MWPhotoBrowser.git',
    :tag => '2.1.2'
  }

  s.platform = :ios, '7.0'
  s.subspec 'core' do |core|
    core.source_files = 'Pod/Classes/**/*'
    core.exclude_files = 'Pod/Classes/MWPhoto.{h,m}'

    core.resource_bundles = {
      'MWPhotoBrowser' => ['Pod/Assets/*.png']
    }
    core.requires_arc = true

    core.frameworks = 'ImageIO', 'QuartzCore', 'AssetsLibrary', 'MediaPlayer'
    core.weak_frameworks = 'Photos'

    core.dependency 'MBProgressHUD'
    core.dependency 'DACircularProgress', '~> 2.3'
  end

  s.subspec 'SDWebImage' do |sdweb|
    sdweb.source_files = 'Pod/Classes/MWPhoto.{h,m}'
    sdweb.dependency 'MWPhotoBrowser/core'
    # SDWebImage
    # 3.7.2 contains bugs downloading local files
    # https://github.com/rs/SDWebImage/issues/1109
    sdweb.dependency 'SDWebImage', '~> 3.7', '!= 3.7.2'
  end

  s.default_subspec = 'SDWebImage'

end
