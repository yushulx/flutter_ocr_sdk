import 'package:flutter/material.dart';
import 'dart:async';

import 'package:camera/camera.dart';

import 'mobile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      title: 'OCR',
      home: Scaffold(
        appBar: AppBar(
          title: Text("OCR"),
        ),
        body: Mobile(
          camera: firstCamera,
        ),
      ),
    ),
  );
}
