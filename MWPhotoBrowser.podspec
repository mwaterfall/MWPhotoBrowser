Pod::Spec.new do |s|
  s.name     = 'MWPhotoBrowser'
  s.version  = '1.0.1'
  s.license  = 'MIT'
  s.summary  = 'A simple iOS photo browser.'
  s.homepage = 'https://github.com/mwaterfall/MWPhotoBrowser'
  s.author   = { 'Michael Waterfall' => 'mw@d3i.com' }
  s.source   = { :git => 'https://github.com/mwaterfall/MWPhotoBrowser.git', :tag => '1.0.1' }
  s.platform = :ios
  
  s.source_files = 'MWPhotoBrowser/Classes'
  s.resources = "MWPhotoBrowser/MWPhotoBrowser.bundle"

  s.frameworks = 'MessageUI', 'ImageIO'

  s.dependency 'SDWebImage'
  s.dependency 'MBProgressHUD'
end
