
Pod::Spec.new do |s|
  s.name             = 'AdjustAdobeExtension'
  s.version          = '0.1.0'
  s.summary          = 'Adjust SDK extension for Adobe Experience Platform.'
  s.description      = <<-DESC
Adjust SDK extension for Adobe Experience Platform.
                       DESC

  s.homepage         = 'https://github.com/adjust/AdjustAdobeExtension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rabc' => 'ricardo.carvalho@adjust.com' }
  s.source           = { :git => 'https://github.com/adjust/AdjustAdobeExtension.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'AdjustAdobeExtension/Classes/**/*'
  s.static_framework = true

#  s.public_header_files = 'AdjustAdobeExtension/Classes/**/*.h'
  s.dependency 'Adjust'
  s.dependency 'ACPCore'
end
