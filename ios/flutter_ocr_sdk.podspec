#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_ocr_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ocr_sdk'
  s.version          = '1.0.0'
  s.summary          = 'A wrapper for Dynamsoft OCR SDK, detecting MRZ in passports, travel documents, and ID cards.'
  s.description      = <<-DESC
A wrapper for Dynamsoft OCR SDK, detecting MRZ in passports, travel documents, and ID cards.
                       DESC
  s.homepage         = 'https://github.com/yushulx/flutter_ocr_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'yushulx' => 'lingxiao1002@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.dependency 'DynamsoftLabelRecognizer', '2.2.20'
  s.dependency 'DynamsoftCore', '2.0.2'
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
