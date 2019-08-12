#
# Be sure to run `pod lib lint WeexKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WeexKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of WeexKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        WeexKit
                      DESC

  s.homepage         = 'https://github.com/snice/WeexKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'snice' => 'zhuzhe@findpiano.cn' }
  # s.source           = { :git => 'https://github.com/snice/WeexKit.git', :tag => s.version.to_s }
  s.source = { :path => '.'}

  s.ios.deployment_target = '9.0'

  s.source_files = 'WeexKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WeexKit' => ['WeexKit/Assets/*.png']
  # }
  s.public_header_files = "WeexKit/Classes/WeexKit.h",
                          "WeexKit/Classes/WXDemoViewController.h",
                          "WeexKit/Classes/Scanner/WXScannerVC.h"
  s.requires_arc = true
  s.xcconfig = { "OTHER_LINK_FLAG" => '$(inherited) -ObjC'}

  s.dependency 'WeexSDK'
  # s.dependency 'WXDevtool', '0.15.3'
  # s.dependency 'ATSDK-Weex', '0.0.1'
  s.dependency 'SDWebImage', '3.7.5'
  s.dependency 'SocketRocket', '0.4.2'
  s.dependency 'BindingX', '~> 1.0.3'
  # s.dependency 'WeexGcanvas'
  s.dependency 'SVProgressHUD'
  s.dependency 'lottie-ios', '2.5.2'
  s.dependency 'ORouter', '~> 0.0.3'

end
