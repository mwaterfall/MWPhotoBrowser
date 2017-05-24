Pod::Spec.new do |s|

  s.name = 'MWPhotoBrowser'
  s.version = '2.1.2'
  s.license = 'MIT'
  s.summary = 'Fork From MWPhotoBrowser'

  s.homepage = 'https://github.com/looseyi/MWPhotoBrowser'
  s.author = { 'Edmond' => 'chun574271939@gmail.com' }

  s.source = {

  }
  s.platform = :ios, '8.0'
  s.source_files = 'MWPhotoBrowser/Classes/**/*'
  s.resource_bundles = {
    'MWPhotoBrowser' => ['Assets.bundle/*.png']
  }
  s.requires_arc = true

  s.frameworks = 'ImageIO', 'QuartzCore', 'AssetsLibrary', 'MediaPlayer'
  s.weak_frameworks = 'Photos'

  s.dependency 'MBProgressHUD'
  s.dependency 'SDWebImage'

end
