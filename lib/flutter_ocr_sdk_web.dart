// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:typed_data';

import 'package:flutter_ocr_sdk/web_dlr_manager.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'flutter_ocr_sdk_platform_interface.dart';
import 'mrz_line.dart';

/// A web implementation of the FlutterOcrSdkPlatform of the FlutterOcrSdk plugin.
class FlutterOcrSdkWeb extends FlutterOcrSdkPlatform {
  final DLRManager _dlrManager = DLRManager();

  /// Constructs a FlutterOcrSdkWeb
  FlutterOcrSdkWeb();

  static void registerWith(Registrar registrar) {
    FlutterOcrSdkPlatform.instance = FlutterOcrSdkWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }

  /// Initialize the SDK: https://www.dynamsoft.com/customer/license/trialLicense?product=dlr
  @override
  Future<int?> init(String key) {
    return _dlrManager.init(key);
  }

  /// Recognize MRZ from a buffer
  /// [bytes] is the buffer
  /// [width] is the width of the image
  /// [height] is the height of the image
  /// [stride] is the stride of the image
  /// [format] is the format of the image
  /// Returns a list of MRZ lines
  @override
  Future<List<List<MrzLine>>?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) async {
    return _dlrManager.recognizeByBuffer(bytes, width, height, stride, format);
  }

  /// Recognize MRZ from a file
  /// [filename] is the path of the file
  /// Returns a list of MRZ lines
  @override
  Future<List<List<MrzLine>>?> recognizeByFile(String filename) async {
    return _dlrManager.recognizeByFile(filename);
  }

  /// Load the MRZ detection model.
  @override
  Future<int?> loadModel() async {
    return _dlrManager.loadModel();
  }
}
