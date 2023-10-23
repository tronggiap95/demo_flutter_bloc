#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint octo_beat_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'octo_beat_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'RxSwift', '6.0.0-rc.1'
  s.dependency 'SwiftyBeaver'
  s.dependency 'MessagePack.swift', '~> 3.0'
  s.dependency 'CocoaAsyncSocket'
  s.dependency 'TrueTime'
  s.dependency 'ReachabilitySwift'
  s.dependency 'CryptoSwift'
  s.platform = :ios, '13.0'
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
