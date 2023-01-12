import 'dart:typed_data';

import 'flutter_ocr_sdk_platform_interface.dart';
import 'mrz_line.dart';

class FlutterOcrSdk {
  Future<String?> getPlatformVersion() {
    return FlutterOcrSdkPlatform.instance.getPlatformVersion();
  }

  /// Initialize the SDK: https://www.dynamsoft.com/customer/license/trialLicense?product=dlr
  Future<int?> init(String path, String key) {
    return FlutterOcrSdkPlatform.instance.init(path, key);
  }

  Future<List<List<MrzLine>>?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) {
    return FlutterOcrSdkPlatform.instance
        .recognizeByBuffer(bytes, width, height, stride, format);
  }

  Future<List<List<MrzLine>>?> recognizeByFile(String filename) {
    return FlutterOcrSdkPlatform.instance.recognizeByFile(filename);
  }

  Future<int?> loadModel() async {
    return FlutterOcrSdkPlatform.instance.loadModel();
  }
}
