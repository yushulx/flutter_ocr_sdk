import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'flutter_ocr_sdk_platform_interface.dart';
import 'model_type.dart';

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
  Future<int?> init(String key) async {
    return await methodChannel.invokeMethod<int>('init', {'key': key});
  }

  /// Do OCR by image buffer.
  /// Returns a [List<List<OcrLine>>] containing the OCR results.
  @override
  Future<List<List<OcrLine>>?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) async {
    List<dynamic>? results =
        await methodChannel.invokeMethod('recognizeByBuffer', {
      'bytes': bytes,
      'width': width,
      'height': height,
      'stride': stride,
      'format': format,
    });

    if (results == null || results.isEmpty) return [];

    return _resultWrapper(results);
  }

  /// Do OCR by file.
  /// Returns a [List<List<OcrLine>>] containing the OCR results.
  @override
  Future<List<List<OcrLine>>?> recognizeByFile(String filename) async {
    List<dynamic>? results =
        await methodChannel.invokeMethod('recognizeByFile', {
      'filename': filename,
    });

    if (results == null || results.isEmpty) return [];

    return _resultWrapper(results);
  }

  /// Convert JSON string to List<OcrLine>
  List<List<OcrLine>> _resultWrapper(List<dynamic> data) {
    List<List<OcrLine>> results = [];

    for (List<dynamic> area in data) {
      List<OcrLine> lines = [];
      for (int i = 0; i < area.length; i++) {
        OcrLine line = OcrLine();
        Map<dynamic, dynamic> map = area[i];
        line.confidence = map['confidence'];
        line.text = map['text'];
        line.x1 = map['x1'];
        line.y1 = map['y1'];
        line.x2 = map['x2'];
        line.y2 = map['y2'];
        line.x3 = map['x3'];
        line.y3 = map['y3'];
        line.x4 = map['x4'];
        line.y4 = map['y4'];
        lines.add(line);
      }

      results.add(lines);
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
  Future<int?> loadModel({ModelType modelType = ModelType.mrz}) async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    String modelPath = 'packages/flutter_ocr_sdk/lib/model/mrz/';
    var fileName = "MRZ";
    var templateName = 'MRZ.json';

    bool isDesktop = false;
    if (Platform.isWindows || Platform.isLinux) {
      isDesktop = true;
    }

    int? ret = 0;

    if (modelType == ModelType.vin) {
      fileName = "VIN";
      modelPath = 'packages/flutter_ocr_sdk/lib/model/vin/';
      templateName = 'VIN.json';
    }

    var prototxtName = '$fileName.prototxt';
    var prototxtBufferPath = join(modelPath, prototxtName);
    print(prototxtBufferPath);
    ByteData prototxtBuffer = await loadAssetBytes(prototxtBufferPath);

    var txtBufferName = '$fileName.txt';
    var txtBufferPath = join(modelPath, txtBufferName);
    ByteData txtBuffer = await loadAssetBytes(txtBufferPath);

    var characterModelName = '$fileName.caffemodel';
    var characterModelBufferPath = join(modelPath, characterModelName);
    ByteData characterModelBuffer =
        await loadAssetBytes(characterModelBufferPath);

    if (isDesktop) {
      List<int> bytes = prototxtBuffer.buffer.asUint8List();
      await File(join(directory.path, prototxtName)).writeAsBytes(bytes);

      bytes = txtBuffer.buffer.asUint8List();
      await File(join(directory.path, txtBufferName)).writeAsBytes(bytes);

      bytes = characterModelBuffer.buffer.asUint8List();
      await File(join(directory.path, characterModelName)).writeAsBytes(bytes);
    } else {
      loadModelFiles(
          fileName,
          prototxtBuffer.buffer.asUint8List(),
          txtBuffer.buffer.asUint8List(),
          characterModelBuffer.buffer.asUint8List());
    }

    var templatePath = join(modelPath, templateName);
    String template = await loadAssetString(templatePath);
    if (isDesktop) {
      var templateMap = json.decode(template);
      templateMap['CharacterModelArray'][0]['DirectoryPath'] = directory.path;

      ByteData templateBuffer = await loadAssetBytes(templatePath);
      List<int> bytes = templateBuffer.buffer.asUint8List();
      await File(join(directory.path, templateName)).writeAsBytes(bytes);
      await methodChannel.invokeMethod('loadModel',
          {'path': directory.path, 'template': json.encode(templateMap)});
    } else {
      ret = await loadTemplate(template);
    }

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
