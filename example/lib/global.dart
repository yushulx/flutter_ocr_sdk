import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';

FlutterOcrSdk mrzDetector = FlutterOcrSdk();

Future<void> initMRZSDK() async {
  await mrzDetector.init(
      "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
  await mrzDetector.loadModel();
}

Widget createOverlay(List<List<MrzLine>>? mrzResults) {
  return CustomPaint(
    painter: OverlayPainter(mrzResults),
  );
}

class OverlayPainter extends CustomPainter {
  List<List<MrzLine>>? mrzResults;

  OverlayPainter(this.mrzResults);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    if (mrzResults != null) {
      for (List<MrzLine> area in mrzResults!) {
        for (MrzLine line in area) {
          canvas.drawLine(Offset(line.x1.toDouble(), line.y1.toDouble()),
              Offset(line.x2.toDouble(), line.y2.toDouble()), paint);
          canvas.drawLine(Offset(line.x2.toDouble(), line.y2.toDouble()),
              Offset(line.x3.toDouble(), line.y3.toDouble()), paint);
          canvas.drawLine(Offset(line.x3.toDouble(), line.y3.toDouble()),
              Offset(line.x4.toDouble(), line.y4.toDouble()), paint);
          canvas.drawLine(Offset(line.x4.toDouble(), line.y4.toDouble()),
              Offset(line.x1.toDouble(), line.y1.toDouble()), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) => true;
}

List<List<MrzLine>> rotate90mrz(List<List<MrzLine>> input, int height) {
  List<List<MrzLine>> output = [];

  for (List<MrzLine> area in input) {
    List<MrzLine> tmp = [];
    for (int i = 0; i < area.length; i++) {
      MrzLine line = area[i];
      int x1 = line.x1;
      int x2 = line.x2;
      int x3 = line.x3;
      int x4 = line.x4;
      int y1 = line.y1;
      int y2 = line.y2;
      int y3 = line.y3;
      int y4 = line.y4;

      MrzLine newline = MrzLine();
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
