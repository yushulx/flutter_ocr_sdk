import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_ocr_sdk_method_channel.dart';

abstract class FlutterOcrSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterOcrSdkPlatform.
  FlutterOcrSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOcrSdkPlatform _instance = MethodChannelFlutterOcrSdk();

  /// The default instance of [FlutterOcrSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOcrSdk].
  static FlutterOcrSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterOcrSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterOcrSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int?> init(String path, String key) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<String?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) {
    throw UnimplementedError('recognizeByBuffer() has not been implemented.');
  }

  Future<String?> recognizeByFile(String filename) {
    throw UnimplementedError('recognizeByFile() has not been implemented.');
  }

  // Future<int?> loadModelFiles(String name, Uint8List prototxtBuffer,
  //     Uint8List txtBuffer, Uint8List characterModelBuffer) {
  //   throw UnimplementedError('loadModelFiles() has not been implemented.');
  // }

  // Future<int?> loadTemplate(String template) async {
  //   throw UnimplementedError('loadTemplate() has not been implemented.');
  // }

  Future<int?> loadModel(String modelPath) async {
    throw UnimplementedError('loadModel() has not been implemented.');
  }
}
