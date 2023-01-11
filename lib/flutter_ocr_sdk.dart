import 'dart:typed_data';

import 'flutter_ocr_sdk_platform_interface.dart';

class FlutterOcrSdk {
  Future<String?> getPlatformVersion() {
    return FlutterOcrSdkPlatform.instance.getPlatformVersion();
  }

  /// Initialize the SDK: https://www.dynamsoft.com/customer/license/trialLicense?product=dlr
  Future<int?> init(String path, String key) {
    return FlutterOcrSdkPlatform.instance.init(path, key);
  }

  Future<String?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) {
    return FlutterOcrSdkPlatform.instance
        .recognizeByBuffer(bytes, width, height, stride, format);
  }

  Future<String?> recognizeByFile(String filename) {
    return FlutterOcrSdkPlatform.instance.recognizeByFile(filename);
  }

  // Future<int?> loadModelFiles(String name, Uint8List prototxtBuffer,
  //     Uint8List txtBuffer, Uint8List characterModelBuffer) {
  //   return FlutterOcrSdkPlatform.instance
  //       .loadModelFiles(name, prototxtBuffer, txtBuffer, characterModelBuffer);
  // }

  // Future<int?> loadTemplate(String template) async {
  //   return FlutterOcrSdkPlatform.instance.loadTemplate(template);
  // }

  Future<int?> loadModel(String modelPath) async {
    return FlutterOcrSdkPlatform.instance.loadModel(modelPath);
  }
}
