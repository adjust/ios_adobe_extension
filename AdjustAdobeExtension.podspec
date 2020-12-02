
Pod::Spec.new do |s|
  s.name             = 'AdjustAdobeExtension'
  s.version          = '0.0.1'
  s.summary          = 'Adjust SDK extension for Adobe Experience Platform.'
  s.description      = <<-DESC
Adjust SDK extension for Adobe Experience Platform.
                       DESC

  s.homepage         = 'https://github.com/adjust/ios_adobe_extension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adjust SDK Team' => 'sdk@adjust.com' }
  s.source           = { :git => 'https://github.com/adjust/ios_adobe_extension.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'AdjustAdobeExtension/Classes/**/*'
  s.static_framework = true

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'}

  s.dependency 'Adjust', '4.23.2'
  s.dependency 'ACPCore'
end
