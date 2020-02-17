#
# Be sure to run `pod lib lint RickSwiftLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RickSwiftLib'
  s.version          = '0.1.1'
  s.summary          = 'Rick Swift Library'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  It is a Base Swift Project Library
                       DESC

  s.homepage         = 'https://github.com/RickwangF/RickSwiftLib'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'woshiwwy16@126.com' => 'woshiwwy16@126.com' }
  s.source           = { :git => 'https://github.com/RickwangF/RickSwiftLib.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.source_files = 'RickSwiftLib/Classes/**/*'
end
