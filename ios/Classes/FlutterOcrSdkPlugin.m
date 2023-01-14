#import "FlutterOcrSdkPlugin.h"
#if __has_include(<flutter_ocr_sdk/flutter_ocr_sdk-Swift.h>)
#import <flutter_ocr_sdk/flutter_ocr_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_ocr_sdk-Swift.h"
#endif

@implementation FlutterOcrSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterOcrSdkPlugin registerWithRegistrar:registrar];
}
@end
