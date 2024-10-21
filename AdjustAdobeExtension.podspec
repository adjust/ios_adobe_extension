
Pod::Spec.new do |s|
  s.name             = 'AdjustAdobeExtension'
  s.version          = '3.0.0'
  s.summary          = 'Adjust SDK extension for Adobe Experience Platform.'
  s.description      = <<-DESC
A leading attribution solution that brings the full power of mobile ad measurement to your campaigns.
                       DESC
  s.homepage         = 'https://github.com/adjust/ios_adobe_extension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adjust' => 'sdk@adjust.com' }
  s.source           = { :git => 'https://github.com/adjust/ios_adobe_extension.git', :tag => "v#{s.version}" }
    
  s.ios.deployment_target = '12.0'

  s.source_files = 'AdjustAdobeExtension/Classes/**/*'
  s.static_framework = true

  s.dependency 'Adjust', '5.0.1'
  s.dependency 'AEPCore', '~> 4.2'
end
