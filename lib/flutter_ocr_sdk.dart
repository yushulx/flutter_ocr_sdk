import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class FlutterOcrSdk {
  static const MethodChannel _channel = const MethodChannel('flutter_ocr_sdk');

  /// Returns a [String] containing the version of the platform.
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Set an organization ID.
  /// Register a Dynamsoft account: https://www.dynamsoft.com/customer/license/trialLicense?product=dlr
  Future<void> setOrganizationID(String id) async {
    await _channel.invokeMethod('setOrganizationID', {'id': id});
  }

  /// Do OCR by image buffer.
  ///
  /// E.g. [CameraImage]
  Future<String> recognizeByBuffer(Uint8List bytes, int width, int height,
      int stride, int format, String template) async {
    return await _channel.invokeMethod('recognizeByBuffer', {
      'bytes': bytes,
      'width': width,
      'height': height,
      'stride': stride,
      'format': format,
      'template': template,
    });
  }

  /// Do OCR by file.
  Future<String> recognizeByFile(String filename, String template) async {
    return await _channel.invokeMethod('recognizeByFile', {
      'filename': filename,
      'template': template,
    });
  }

  /// Load custom model files.
  Future<String> loadModelFiles(String name, Uint8List prototxtBuffer,
      Uint8List txtBuffer, Uint8List characterModelBuffer) async {
    return await _channel.invokeMethod('loadModelFiles', {
      'name': name,
      'prototxtBuffer': prototxtBuffer,
      'txtBuffer': txtBuffer,
      'characterModelBuffer': characterModelBuffer,
    });
  }

  /// Load template file.
  Future<String> loadTemplate(String template) async {
    return await _channel.invokeMethod('loadTemplate', {
      'template': template,
    });
  }
}
