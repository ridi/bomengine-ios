Pod::Spec.new do |s|
  s.name         = 'RBBomReaderEngine'
  s.version      = '1.0.6'
  s.summary      = 'BOM parser engine for iOS platform'
  s.homepage     = 'https://github.com/ridi/bomengine-ios'
  s.authors      = { 'Ridibooks Viewer Team' => 'viewer.team@ridi.com' }
  s.license      = 'MIT'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => 'https://github.com/ridi/bomengine-ios.git', :tag => s.version }
  s.source_files = 'Sources/RBBomReaderEngine/**/*.{h,m,mm}'
  s.private_header_files = 'Sources/RBBomReaderEngine/RBBomStringBuilder.h'
  s.frameworks   = 'Foundation', 'CoreGraphics'
  s.module_map   = 'Sources/RBBomReaderEngine/include/RBBomReaderEngine.modulemap'
  s.requires_arc = true
end
