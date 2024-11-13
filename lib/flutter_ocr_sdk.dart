import 'dart:typed_data';

import 'flutter_ocr_sdk_platform_interface.dart';
import 'model_type.dart';
import 'ocr_line.dart';

class FlutterOcrSdk {
  Future<String?> getPlatformVersion() {
    return FlutterOcrSdkPlatform.instance.getPlatformVersion();
  }

  /// Initialize the SDK: https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform
  Future<int?> init(String key) {
    return FlutterOcrSdkPlatform.instance.init(key);
  }

  Future<List<List<OcrLine>>?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) {
    return FlutterOcrSdkPlatform.instance
        .recognizeByBuffer(bytes, width, height, stride, format);
  }

  Future<List<List<OcrLine>>?> recognizeByFile(String filename) {
    return FlutterOcrSdkPlatform.instance.recognizeByFile(filename);
  }

  Future<int?> loadModel({ModelType modelType = ModelType.mrz}) async {
    return FlutterOcrSdkPlatform.instance.loadModel(modelType: modelType);
  }
}
