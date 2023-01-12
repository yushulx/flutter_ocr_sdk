import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';

import 'flutter_ocr_sdk_platform_interface.dart';

/// An implementation of [FlutterOcrSdkPlatform] that uses method channels.
class MethodChannelFlutterOcrSdk extends FlutterOcrSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ocr_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Initialize the SDK
  @override
  Future<int?> init(String path, String key) async {
    return await methodChannel
        .invokeMethod<int>('init', {'path': path, 'key': key});
  }

  /// Do OCR by image buffer.
  /// Returns a [List<List<MrzLine>>] containing the OCR results.
  @override
  Future<List<List<MrzLine>>?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) async {
    String? json = await methodChannel.invokeMethod('recognizeByBuffer', {
      'bytes': bytes,
      'width': width,
      'height': height,
      'stride': stride,
      'format': format,
    });

    if (json == null || json == '') return [];
    return _resultWrapper(json);
  }

  /// Do OCR by file.
  /// Returns a [List<List<MrzLine>>] containing the OCR results.
  @override
  Future<List<List<MrzLine>>?> recognizeByFile(String filename) async {
    String? json = await methodChannel.invokeMethod('recognizeByFile', {
      'filename': filename,
    });

    if (json == null || json == '') return [];
    return _resultWrapper(json);
  }

  /// Convert JSON string to List<MrzLine>
  List<List<MrzLine>> _resultWrapper(String json) {
    List<List<MrzLine>> results = [];
    List<dynamic>? obj = jsonDecode(json)['results'];
    if (obj != null) {
      for (dynamic tmp in obj) {
        List<dynamic> area = tmp['area'];
        List<MrzLine> lines = [];
        if (area.length == 2 || area.length == 3) {
          for (int i = 0; i < area.length; i++) {
            MrzLine line = MrzLine();
            line.text = area[i]['text'];
            line.x1 = area[i]['x1'];
            line.y1 = area[i]['y1'];
            line.x2 = area[i]['x2'];
            line.y2 = area[i]['y2'];
            line.x3 = area[i]['x3'];
            line.y3 = area[i]['y3'];
            line.x4 = area[i]['x4'];
            line.y4 = area[i]['y4'];
            lines.add(line);
          }
        }

        results.add(lines);
      }
    }

    return results;
  }

  /// Load custom model files.
  /// Returns a [String] containing the OCR results.
  Future<int?> loadModelFiles(String name, Uint8List prototxtBuffer,
      Uint8List txtBuffer, Uint8List characterModelBuffer) async {
    return await methodChannel.invokeMethod('loadModelFiles', {
      'name': name,
      'prototxtBuffer': prototxtBuffer,
      'txtBuffer': txtBuffer,
      'characterModelBuffer': characterModelBuffer,
    });
  }

  /// Load s template file.
  Future<int?> loadTemplate(String template) async {
    return await methodChannel.invokeMethod('loadTemplate', {
      'template': template,
    });
  }

  /// Load the whole model by folder.
  @override
  Future<int?> loadModel() async {
    String modelPath = 'model/';
    int? ret = 0;
    var fileNames = ["MRZ"];
    for (var i = 0; i < fileNames.length; i++) {
      var fileName = fileNames[i];
      ByteData prototxtBuffer =
          await loadAssetBytes(modelPath + fileName + ".prototxt");

      ByteData txtBuffer = await loadAssetBytes(modelPath + fileName + ".txt");

      ByteData characterModelBuffer =
          await loadAssetBytes(modelPath + fileName + ".caffemodel");

      loadModelFiles(
          fileName,
          prototxtBuffer.buffer.asUint8List(),
          txtBuffer.buffer.asUint8List(),
          characterModelBuffer.buffer.asUint8List());
    }

    String template = await loadAssetString(modelPath + 'MRZ.json');
    ret = await loadTemplate(template);
    return ret;
  }

  /// Retrieve a string from the asset bundle.
  Future<String> loadAssetString(String path) async {
    return await rootBundle.loadString(path);
  }

  /// Retrieve a binary resource from the asset bundle as a data stream.
  Future<ByteData> loadAssetBytes(String path) async {
    return await rootBundle.load(path);
  }
}
