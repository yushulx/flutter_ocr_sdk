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
        if (area.length == 2) {
          MrzLine line1 = MrzLine();
          line1.text = area[0]['text'];
          line1.x1 = area[0]['x1'];
          line1.y1 = area[0]['y1'];
          line1.x2 = area[0]['x2'];
          line1.y2 = area[0]['y2'];
          line1.x3 = area[0]['x3'];
          line1.y3 = area[0]['y3'];
          line1.x4 = area[0]['x4'];
          line1.y4 = area[0]['y4'];

          MrzLine line2 = MrzLine();
          line2.text = area[1]['text'];
          line2.x1 = area[1]['x1'];
          line2.y1 = area[1]['y1'];
          line2.x2 = area[1]['x2'];
          line2.y2 = area[1]['y2'];
          line2.x3 = area[1]['x3'];
          line2.y3 = area[1]['y3'];
          line2.x4 = area[1]['x4'];
          line2.y4 = area[1]['y4'];

          lines.add(line1);
          lines.add(line2);
        } else if (area.length == 3) {
          MrzLine line1 = MrzLine();
          line1.text = area[0]['text'];
          line1.x1 = area[0]['x1'];
          line1.y1 = area[0]['y1'];
          line1.x2 = area[0]['x2'];
          line1.y2 = area[0]['y2'];
          line1.x3 = area[0]['x3'];
          line1.y3 = area[0]['y3'];
          line1.x4 = area[0]['x4'];
          line1.y4 = area[0]['y4'];

          MrzLine line2 = MrzLine();
          line2.text = area[1]['text'];
          line2.x1 = area[1]['x1'];
          line2.y1 = area[1]['y1'];
          line2.x2 = area[1]['x2'];
          line2.y2 = area[1]['y2'];
          line2.x3 = area[1]['x3'];
          line2.y3 = area[1]['y3'];
          line2.x4 = area[1]['x4'];
          line2.y4 = area[1]['y4'];

          MrzLine line3 = MrzLine();
          line3.text = area[2]['text'];
          line3.x1 = area[2]['x1'];
          line3.y1 = area[2]['y1'];
          line3.x2 = area[2]['x2'];
          line3.y2 = area[2]['y2'];
          line3.x3 = area[2]['x3'];
          line3.y3 = area[2]['y3'];
          line3.x4 = area[2]['x4'];
          line3.y4 = area[2]['y4'];

          lines.add(line1);
          lines.add(line2);
          lines.add(line3);
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
  Future<int?> loadModel(String modelPath) async {
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
