import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';
import 'package:flutter_ocr_sdk/vin_result.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'flutter_ocr_sdk_platform_interface.dart';
import 'model_type.dart';
import 'mrz_result.dart';

/// A [FlutterOcrSdkPlatform] implementation that communicates with
/// the native platform using a [MethodChannel].
///
/// This class provides methods for initializing the OCR SDK, performing OCR
/// from image buffers or file paths, and loading OCR models based on type.
class MethodChannelFlutterOcrSdk extends FlutterOcrSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_ocr_sdk');

  /// Initializes the OCR SDK using the provided [key].
  ///
  /// Returns `0` on success, or a non-zero error code if initialization fails.
  @override
  Future<int?> init(String key) async {
    return await methodChannel.invokeMethod<int>('init', {'key': key});
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
    List<dynamic>? results =
        await methodChannel.invokeMethod('recognizeBuffer', {
      'bytes': bytes,
      'width': width,
      'height': height,
      'stride': stride,
      'format': format,
      'rotation': rotation
    });

    if (results == null || results.isEmpty) return [];

    return _resultWrapper(results);
  }

  /// Performs OCR on an image file specified by [filename].
  ///
  /// Returns a list of OCR results, each represented as a list of [OcrLine]
  /// for text regions found in the image.
  @override
  Future<List<List<OcrLine>>?> recognizeByFile(String filename) async {
    List<dynamic>? results =
        await methodChannel.invokeMethod('recognizeByFile', {
      'filename': filename,
    });

    if (results == null || results.isEmpty) return [];

    return _resultWrapper(results);
  }

  /// Converts a decoded JSON result from the native platform into
  /// a structured [List<List<OcrLine>>] format.
  ///
  /// Each inner list represents one text block containing one or more lines.
  List<List<OcrLine>> _resultWrapper(List<dynamic> data) {
    List<List<OcrLine>> results = [];

    for (List<dynamic> area in data) {
      List<OcrLine> lines = [];
      for (int i = 0; i < area.length; i++) {
        OcrLine line = OcrLine();
        Map<dynamic, dynamic> map = area[i];
        if (map.isEmpty) continue;
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

        if (map['type'] == 'MRZ') {
          String mrzString = map['mrzString'];
          String docType = map["docType"];
          String nationality = map["nationality"];
          String surname = map["surname"];
          String givenName = map["givenName"];
          String docNumber = map["docNumber"];
          String issuingCountry = map["issuingCountry"];
          String birthDate = map["birthDate"];
          String gender = map["gender"];
          String expiration = map["expiration"];

          MrzResult mrzResult = MrzResult(
              type: docType,
              nationality: nationality,
              surname: surname,
              givenName: givenName,
              docNumber: docNumber,
              issuingCountry: issuingCountry,
              birthDate: birthDate,
              gender: gender,
              expiration: expiration,
              lines: mrzString);
          line.mrzResult = mrzResult;
        } else if (map['type'] == 'VIN') {
          String vinString = map['vinString'];
          String wmi = map['wmi'];
          String region = map['region'];
          String vds = map['vds'];
          String checkDigit = map['checkDigit'];
          String modelYear = map['modelYear'];
          String plantCode = map['plantCode'];
          String serialNumber = map['serialNumber'];

          VinResult vinResult = VinResult(
              vinString: vinString,
              wmi: wmi,
              region: region,
              vds: vds,
              checkDigit: checkDigit,
              modelYear: modelYear,
              plantCode: plantCode,
              serialNumber: serialNumber);

          line.vinResult = vinResult;
        }

        lines.add(line);
      }

      results.add(lines);
    }

    return results;
  }

  /// Loads the OCR model for the specified [modelType].
  ///
  /// Supported types are [ModelType.mrz] (default) and [ModelType.vin].
  ///
  /// Returns `0` on success, or an error code on failure.
  @override
  Future<int?> loadModel({ModelType modelType = ModelType.mrz}) async {
    String templateName = "ReadPassportAndId";

    if (modelType == ModelType.vin) {
      templateName = "ReadVINText";
    }

    int ret = await methodChannel
        .invokeMethod('loadModel', {'template': templateName});
    return ret;
  }
}
