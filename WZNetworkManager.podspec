Pod::Spec.new do |s|
  s.name             = "WZNetworkManager"
  s.version          = "1.0.0"
  s.summary          = "A Network Framework based on AFNetworking used on iOS."
  s.description      = <<-DESC
                       It is a Network Framework used on iOS, which implement by Objective-C.
                       DESC
  s.homepage         = "https://github.com/zhangyanrui/networkManager"
  s.license          = 'MIT'
  s.author           = { "张彦瑞" => "zhangyanrui@live.com" }
  s.source           = { :git => "git@github.com:zhangyanrui/networkManager.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/zhangyanrui'

  s.platform     = :ios, '7.0'
  # s.ios.deployment_target = '5.0'
  # s.osx.deployment_target = '10.7'
  s.requires_arc = true

  s.source_files = 'NetworkManager/*'
  # s.resources = 'Assets'

  # s.ios.exclude_files = 'Classes/osx'
  # s.osx.exclude_files = 'Classes/ios'
  # s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit', 'AFNetworking'

end
