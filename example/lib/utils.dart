import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'dart:math' as math;

void showAlert(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

Future<ui.Image> createImage(
    Uint8List buffer, int width, int height, ui.PixelFormat pixelFormat) {
  final Completer<ui.Image> completer = Completer();

  ui.decodeImageFromPixels(buffer, width, height, pixelFormat, (ui.Image img) {
    completer.complete(img);
  });

  return completer.future;
}

Uint8List yuv420ToRgba8888(List<Uint8List> planes, int width, int height) {
  final yPlane = planes[0];
  final uPlane = planes[1];
  final vPlane = planes[2];

  final Uint8List rgbaBytes = Uint8List(width * height * 4);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * width + x;
      final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

      final int yValue = yPlane[yIndex] & 0xFF;
      final int uValue = uPlane[uvIndex] & 0xFF;
      final int vValue = vPlane[uvIndex] & 0xFF;

      final int r = (yValue + 1.13983 * (vValue - 128)).round().clamp(0, 255);
      final int g =
          (yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128))
              .round()
              .clamp(0, 255);
      final int b = (yValue + 2.03211 * (uValue - 128)).round().clamp(0, 255);

      final int rgbaIndex = yIndex * 4;
      rgbaBytes[rgbaIndex] = r.toUnsigned(8);
      rgbaBytes[rgbaIndex + 1] = g.toUnsigned(8);
      rgbaBytes[rgbaIndex + 2] = b.toUnsigned(8);
      rgbaBytes[rgbaIndex + 3] = 255; // Alpha value
    }
  }

  return rgbaBytes;
}

Uint8List rotate90Degrees(Uint8List src, int width, int height) {
  var dst = Uint8List(4 * width * height);
  int newIndex = 0;

  for (int j = 0; j < width; j++) {
    for (int i = height - 1; i >= 0; i--) {
      int oldIndex = 4 * (i * width + j);
      dst[newIndex] = src[oldIndex];
      dst[newIndex + 1] = src[oldIndex + 1];
      dst[newIndex + 2] = src[oldIndex + 2];
      dst[newIndex + 3] = src[oldIndex + 3];
      newIndex += 4;
    }
  }

  return dst;
}

double calculateArea(Offset p1, Offset p2, Offset p3, Offset p4) {
  double area1 = calculateTriangleArea(p1, p2, p3);
  double area2 = calculateTriangleArea(p1, p3, p4);

  return area1 + area2;
}

double calculateTriangleArea(Offset p1, Offset p2, Offset p3) {
  double a = distanceBetween(p1, p2);
  double b = distanceBetween(p2, p3);
  double c = distanceBetween(p3, p1);
  double s = (a + b + c) / 2;
  return math.sqrt(s * (s - a) * (s - b) * (s - c));
}

double distanceBetween(Offset p1, Offset p2) {
  return math.sqrt(math.pow(p2.dx - p1.dx, 2) + math.pow(p2.dy - p1.dy, 2));
}
