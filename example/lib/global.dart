import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk.dart';
import 'package:flutter_ocr_sdk/model_type.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';

FlutterOcrSdk detector = FlutterOcrSdk();
bool isLicenseValid = false;
ModelType model = ModelType.mrz;

Future<int> initSDK() async {
  int? ret = await detector.init(
      "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");

  if (ret == 0) isLicenseValid = true;
  return await detector.loadModel(modelType: model) ?? -1;
}

Future<void> switchModel(ModelType newModel) async {
  model = newModel;
  await detector.loadModel(modelType: newModel);
}

Color colorMainTheme = const Color(0xff1D1B20);
Color colorOrange = const Color(0xffFE8E14);
Color colorTitle = const Color(0xffF5F5F5);
Color colorSelect = const Color(0xff757575);
Color colorText = const Color(0xff888888);
Color colorBackground = const Color(0xFF323234);
Color colorSubtitle = const Color(0xffCCCCCC);

Widget createOverlay(List<List<OcrLine>>? ocrResults) {
  return CustomPaint(
    painter: OverlayPainter(ocrResults),
  );
}

class OverlayPainter extends CustomPainter {
  List<List<OcrLine>>? ocrResults;

  OverlayPainter(this.ocrResults);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.red, // Set the text color
      fontSize: 16, // Set the font size
    );

    if (ocrResults != null) {
      for (List<OcrLine> area in ocrResults!) {
        for (OcrLine line in area) {
          canvas.drawLine(Offset(line.x1.toDouble(), line.y1.toDouble()),
              Offset(line.x2.toDouble(), line.y2.toDouble()), paint);
          canvas.drawLine(Offset(line.x2.toDouble(), line.y2.toDouble()),
              Offset(line.x3.toDouble(), line.y3.toDouble()), paint);
          canvas.drawLine(Offset(line.x3.toDouble(), line.y3.toDouble()),
              Offset(line.x4.toDouble(), line.y4.toDouble()), paint);
          canvas.drawLine(Offset(line.x4.toDouble(), line.y4.toDouble()),
              Offset(line.x1.toDouble(), line.y1.toDouble()), paint);

          // draw text
          final textSpan = TextSpan(
            text: line.text,
            style: textStyle,
          );

          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          );

          // Layout the text based on its constraints
          textPainter.layout();

          // Calculate the position to draw the text
          final offset = Offset(
            line.x1.toDouble(),
            line.y1.toDouble(),
          );

          // Draw the text on the canvas
          textPainter.paint(canvas, offset);
        }
      }
    }
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) => true;
}

List<List<OcrLine>> rotate90mrz(List<List<OcrLine>> input, int height) {
  List<List<OcrLine>> output = [];

  for (List<OcrLine> area in input) {
    List<OcrLine> tmp = [];
    for (int i = 0; i < area.length; i++) {
      OcrLine line = area[i];
      int x1 = line.x1;
      int x2 = line.x2;
      int x3 = line.x3;
      int x4 = line.x4;
      int y1 = line.y1;
      int y2 = line.y2;
      int y3 = line.y3;
      int y4 = line.y4;

      OcrLine newline = OcrLine();
      newline.confidence = line.confidence;
      newline.text = line.text;
      newline.x1 = height - y1;
      newline.y1 = x1;
      newline.x2 = height - y2;
      newline.y2 = x2;
      newline.x3 = height - y3;
      newline.y3 = x3;
      newline.x4 = height - y4;
      newline.y4 = x4;

      tmp.add(newline);
    }
    output.add(tmp);
  }

  return output;
}
