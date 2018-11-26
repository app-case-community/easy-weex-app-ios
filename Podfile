# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

inhibit_all_warnings!

workspace 'easy-weex'

# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

pre_install do |installer|
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

target 'easy-weex' do
    pod 'WeexKit', :path=>'./WeexKit'
end
