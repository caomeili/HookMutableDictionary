#
# Be sure to run `pod lib lint HookMutableDictionary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HookMutableDictionary'

s.version          = '1.0.1'
s.summary          = 'A short description of HookDictionary.'

s.description      = <<-DESC
TODO: Add long description of the pod here.
DESC

s.homepage         = 'http://www.ushareit.com'
s.author           = { 'caomeili' => 'caoml@ushareit.com' }
s.source           = { :git => 'git@github.com:caomeili/HookMutableDictionary.git', :tag => s.version.to_s }

s.ios.deployment_target = '7.0'

s.source_files = 'HookMutableDictionary/Classes/**/*'
s.public_header_files = 'HookMutableDictionary/Classes/**/*.h'
s.dependency 'BlockStrongReference'

end
