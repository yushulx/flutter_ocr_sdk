import 'dart:typed_data';

import 'package:flutter_ocr_sdk/web_dlr_manager.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'flutter_ocr_sdk_platform_interface.dart';
import 'model_type.dart';
import 'ocr_line.dart';

/// A web implementation of the FlutterOcrSdkPlatform of the FlutterOcrSdk plugin.
class FlutterOcrSdkWeb extends FlutterOcrSdkPlatform {
  final DLRManager _dlrManager = DLRManager();

  /// Constructs a FlutterOcrSdkWeb
  FlutterOcrSdkWeb();

  static void registerWith(Registrar registrar) {
    FlutterOcrSdkPlatform.instance = FlutterOcrSdkWeb();
  }

  /// Initializes the OCR SDK using the provided [key].
  ///
  /// Returns `0` on success, or a non-zero error code if initialization fails.
  @override
  Future<int?> init(String key) {
    return _dlrManager.init(key);
  }

  /// Performs OCR on an image buffer.
  ///
  /// Parameters:
  /// - [bytes]: Raw image data (RGBA).
  /// - [width]: Image width in pixels.
  /// - [height]: Image height in pixels.
  /// - [stride]: Number of bytes per row.
  /// - [format]: Pixel format index (e.g., [ImagePixelFormat.IPF_ARGB_8888.index]).
  /// - [rotation]: Rotation angle in degrees (0, 90, 180, 270).
  ///
  /// Returns a list of OCR results, where each item is a list of [OcrLine]
  /// representing one text region (like MRZ or VIN blocks).
  @override
  Future<List<List<OcrLine>>?> recognizeBuffer(Uint8List bytes, int width,
      int height, int stride, int format, int rotation) async {
    return _dlrManager.recognizeBuffer(
        bytes, width, height, stride, format, rotation);
  }

  /// Performs OCR on an image file specified by [filename].
  ///
  /// Returns a list of OCR results, each represented as a list of [OcrLine]
  /// for text regions found in the image.
  @override
  Future<List<List<OcrLine>>?> recognizeByFile(String filename) async {
    return _dlrManager.recognizeByFile(filename);
  }

  /// Loads the OCR model for the specified [modelType].
  ///
  /// Supported types are [ModelType.mrz] (default) and [ModelType.vin].
  ///
  /// Returns `0` on success, or an error code on failure.
  @override
  Future<int?> loadModel({ModelType modelType = ModelType.mrz}) async {
    return _dlrManager.loadModel(modelType);
  }
}
