import 'package:flutter_ocr_sdk/flutter_ocr_sdk.dart';

FlutterOcrSdk mrzDetector = FlutterOcrSdk();

Future<void> initMRZSDK() async {
  await mrzDetector.init(
      "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
  await mrzDetector.loadModel();
}
