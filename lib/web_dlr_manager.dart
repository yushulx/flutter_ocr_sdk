@JS('Dynamsoft')
library dynamsoft;

import 'package:flutter_ocr_sdk/template.dart';

import 'vin_result.dart';
import 'model_type.dart';
import 'mrz_result.dart';
import 'ocr_line.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:js/js.dart';
import 'utils.dart';
import 'dart:js_util';

@JS()
@anonymous
class RecognitionResult {
  external String get codeType;
  external String get jsonString;
  external String getFieldValue(String field);
}

@JS()
@anonymous
class CapturedResult {
  external List<CapturedItem> get items;
}

@JS()
@anonymous
class CapturedItem {
  external int get type;
  external String get text;
  external String get formatString;
  external Location get location;
  external int get angle;
  external Uint8List get bytes;
  external int get confidence;
}

@JS()
@anonymous
class Location {
  external List<Point> get points;
}

@JS()
@anonymous
class Point {
  external num get x;
  external num get y;
}

@JS('License.LicenseManager')
class LicenseManager {
  external static PromiseJsImpl<void> initLicense(
      String license, bool executeNow);
}

@JS('Core.CoreModule')
class CoreModule {
  external static PromiseJsImpl<void> loadWasm(List<String> modules);
}

@JS('DCP.CodeParserModule')
class CodeParserModule {
  external static PromiseJsImpl<void> loadSpec(String resource);
}

@JS('DLR.LabelRecognizerModule')
class LabelRecognizerModule {
  external static PromiseJsImpl<void> loadRecognitionData(String resource);
}

@JS('DCP.CodeParser')
class CodeParser {
  external static PromiseJsImpl<CodeParser> createInstance();
  external PromiseJsImpl<RecognitionResult> parse(String text);
}

@JS('CVR.CaptureVisionRouter')
class CaptureVisionRouter {
  /// Creates a new instance of [CaptureVisionRouter].
  ///
  /// This method returns a `PromiseJsImpl` that must be handled asynchronously.
  external static PromiseJsImpl<CaptureVisionRouter> createInstance();

  /// Recognize MRZ/VIN from a source.
  ///
  /// The [data] parameter can be a file object or a DSImageData object.
  external PromiseJsImpl<CapturedResult> capture(dynamic data, String template);

  /// Initializes runtime settings from a JSON string.
  external PromiseJsImpl<void> initSettings(String settings);
}

/// CaptureVisionManager class.
class CaptureVisionManager {
  CaptureVisionRouter? _cvr;
  CodeParser? _parser;
  String modelName = '';

  /// Returns 0 if successful.
  Future<int> init(String key) async {
    try {
      await handleThenable(LicenseManager.initLicense(key, true));
      await handleThenable(CoreModule.loadWasm(["DLR"]));
      _parser = await handleThenable(CodeParser.createInstance());

      await handleThenable(CodeParserModule.loadSpec("VIN"));
      await handleThenable(LabelRecognizerModule.loadRecognitionData("VIN"));

      await handleThenable(CodeParserModule.loadSpec("MRTD_TD1_ID"));
      await handleThenable(CodeParserModule.loadSpec("MRTD_TD2_FRENCH_ID"));
      await handleThenable(CodeParserModule.loadSpec("MRTD_TD2_ID"));
      await handleThenable(CodeParserModule.loadSpec("MRTD_TD2_VISA"));
      await handleThenable(CodeParserModule.loadSpec("MRTD_TD3_PASSPORT"));
      await handleThenable(CodeParserModule.loadSpec("MRTD_TD3_VISA"));
      await handleThenable(LabelRecognizerModule.loadRecognitionData("MRZ"));

      _cvr = await handleThenable(CaptureVisionRouter.createInstance());

      await handleThenable(_cvr!.initSettings(template));
    } catch (e) {
      print(e);
      return -1;
    }

    return 0;
  }

  /// MRZ detection.
  /// [file] - path to the file.
  /// Returns a [List] of [List<OcrLine>].
  Future<List<List<OcrLine>>?> recognizeFile(String file) async {
    CapturedResult capturedResult =
        await handleThenable(_cvr!.capture(file, modelName));

    return await _resultWrapper(capturedResult.items);
  }

  /// MRZ detection.
  /// [bytes] - image buffer.
  /// Returns a [List] of [List<OcrLine>].
  Future<List<List<OcrLine>>?> recognizeBuffer(Uint8List bytes, int width,
      int height, int stride, int format, int rotation) async {
    final dsImage = jsify({
      'bytes': bytes,
      'width': width,
      'height': height,
      'stride': stride,
      'format': format,
      'orientation': rotation
    });

    CapturedResult capturedResult =
        await handleThenable(_cvr!.capture(dsImage, modelName));

    return await _resultWrapper(capturedResult.items);
  }

  Future<int?> loadModel(ModelType modelType) async {
    if (modelType == ModelType.mrz) {
      modelName = "ReadMRZ";
    } else {
      modelName = "ReadVINText";
    }
    return 0;
  }

  /// Convert List<dynamic> to List<List<OcrLine>>.
  Future<List<List<OcrLine>>> _resultWrapper(List<dynamic> results) async {
    List<List<OcrLine>> output = [];
    List<OcrLine> lines = [];
    for (CapturedItem result in results) {
      if (result.type != 4) continue;
      OcrLine line = OcrLine();
      line.confidence = result.confidence;
      line.text = result.text;
      line.x1 = result.location.points[0].x.toInt();
      line.y1 = result.location.points[0].y.toInt();
      line.x2 = result.location.points[1].x.toInt();
      line.y2 = result.location.points[1].y.toInt();
      line.x3 = result.location.points[2].x.toInt();
      line.y3 = result.location.points[2].y.toInt();
      line.x4 = result.location.points[3].x.toInt();
      line.y4 = result.location.points[3].y.toInt();

      RecognitionResult data =
          await handleThenable(_parser!.parse(result.text));

      if (modelName == "ReadMRZ") {
        String type = data.getFieldValue("documentCode");
        String mrzString = line.text;
        String docType = data.codeType;
        String nationality = data.getFieldValue("nationality");
        String surname = data.getFieldValue("primaryIdentifier");
        String givenName = data.getFieldValue("secondaryIdentifier");
        String docNumber = type == "P"
            ? data.getFieldValue("passportNumber")
            : data.getFieldValue("documentNumber");
        String issuingCountry = data.getFieldValue("issuingState");
        String birthDate = data.getFieldValue("dateOfBirth");
        String gender = data.getFieldValue("sex");
        String expiration = data.getFieldValue("dateOfExpiry");

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
      } else if (modelName == "ReadVINText") {
        String vinString = line.text;
        String wmi = data.getFieldValue('WMI');
        String region = data.getFieldValue('region');
        String vds = data.getFieldValue('VDS');
        String checkDigit = data.getFieldValue('checkDigit');
        String modelYear = data.getFieldValue('modelYear');
        String plantCode = data.getFieldValue('plantCode');
        String serialNumber = data.getFieldValue('serialNumber');

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
    output.add(lines);
    return output;
  }
}
