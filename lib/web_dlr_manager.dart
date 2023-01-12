@JS('Dynamsoft')
library dynamsoft;

import 'dart:convert';
import 'dart:typed_data';

import 'package:js/js.dart';

import 'mrz_line.dart';
import 'utils.dart';

/// DocumentNormalizer class.
@JS('DLR.LabelRecognizer')
class LabelRecognizer {
  external static set license(String license);
  external static set engineResourcePath(String resourcePath);
  external static PromiseJsImpl<LabelRecognizer> createInstance();
  external PromiseJsImpl<void> updateRuntimeSettingsFromString(String settings);
  external PromiseJsImpl<List<dynamic>> recognize(dynamic source);
  external PromiseJsImpl<List<dynamic>> recognizeBuffer(
      Uint8List buffer, int width, int height, int stride, int format);
}

/// DLRManager class.
class DLRManager {
  LabelRecognizer? _recognizer;

  /// Configure Dynamsoft Label Recognizer.
  /// Returns 0 if successful.
  Future<int> init(String path, String key) async {
    LabelRecognizer.engineResourcePath = path;
    LabelRecognizer.license = key;

    _recognizer = await handleThenable(LabelRecognizer.createInstance());

    return 0;
  }

  /// MRZ detection.
  /// [file] - path to the file.
  /// Returns a [List] of [List<MrzLine>].
  Future<List<List<MrzLine>>?> recognizeByFile(String file) async {
    if (_recognizer != null) {
      List<dynamic> results =
          await handleThenable(_recognizer!.recognize(file));
      return _resultWrapper(results);
    }

    return [];
  }

  /// MRZ detection.
  /// [bytes] - image buffer.
  /// Returns a [List] of [List<MrzLine>].
  Future<List<List<MrzLine>>?> recognizeByBuffer(
      Uint8List bytes, int width, int height, int stride, int format) async {
    if (_recognizer != null) {
      List<dynamic> results = await handleThenable(
          _recognizer!.recognizeBuffer(bytes, width, height, stride, format));
      return _resultWrapper(results);
    }

    return [];
  }

  Future<int?> loadModel() async {
    if (_recognizer != null) {
      await handleThenable(_recognizer!.updateRuntimeSettingsFromString("MRZ"));
    }
    return 0;
  }

  /// Convert List<dynamic> to List<List<MrzLine>>.
  List<List<MrzLine>> _resultWrapper(List<dynamic> results) {
    List<List<MrzLine>> output = [];

    for (dynamic result in results) {
      Map value = json.decode(stringify(result));

      List<dynamic> area = value['lineResults'];
      List<MrzLine> lines = [];
      if (area.length == 2 || area.length == 3) {
        for (int i = 0; i < area.length; i++) {
          MrzLine line = MrzLine();
          line.text = area[i]['text'];
          line.x1 = area[i]['location']['points'][0]['x'];
          line.y1 = area[i]['location']['points'][0]['y'];
          line.x2 = area[i]['location']['points'][1]['x'];
          line.y2 = area[i]['location']['points'][1]['y'];
          line.x3 = area[i]['location']['points'][2]['x'];
          line.y3 = area[i]['location']['points'][2]['y'];
          line.x4 = area[i]['location']['points'][3]['x'];
          line.y4 = area[i]['location']['points'][3]['y'];
          lines.add(line);
        }
      }
      output.add(lines);
    }

    return output;
  }
}
