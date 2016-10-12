Pod::Spec.new do |s|
  s.name         = 'RBBomReaderEngine'
  s.version      = '1.0.3'
  s.summary      = 'BOM parser engine for iOS platform'
  s.homepage     = 'https://github.com/ridibooks/bomengine-ios'
  s.authors      = { 'Ridibooks Viewer Team' => 'viewer.team@ridi.com' }
  s.license      = 'Apache-2.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => 'https://github.com/ridibooks/bomengine-ios.git', :tag => s.version }
  s.source_files = 'RBBomReaderEngine', 'RBBomReaderEngine/*.{h,m,mm}'
  s.frameworks   = 'Foundation', 'CoreGraphics'
  s.module_map   = 'RBBomReaderEngine.modulemap'
  s.requires_arc = true
end
