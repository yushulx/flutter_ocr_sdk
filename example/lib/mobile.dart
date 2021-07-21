import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk.dart';

Future<String> loadAssetString(String path) async {
  return await rootBundle.loadString(path);
}

Future<ByteData> loadAssetBytes(String path) async {
  return await rootBundle.load(path);
}

class Mobile extends StatefulWidget {
  final CameraDescription camera;

  const Mobile({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  MobileState createState() => MobileState();
}

String getTextResults(String json) {
  StringBuffer sb = new StringBuffer();
  List<dynamic> obj = jsonDecode(json)['results'];
  if (obj != null) {
    for (dynamic tmp in obj) {
      List<dynamic> area = tmp['area'];
      for (dynamic line in area) {
        sb.write(line['text']);
        sb.write("\n\n");
      }
    }
  }

  return sb.toString();
}

class MobileState extends State<Mobile> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  FlutterOcrSdk _textRecognizer;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((_) {
      setState(() {});
    });
    // Initialize Dynamsoft Barcode Reader
    initBarcodeSDK();
  }

  Future<void> initBarcodeSDK() async {
    _textRecognizer = FlutterOcrSdk();
    String modelPath = 'model/';

    var fileNames = [
      "NumberUppercase",
      "NumberUppercase_Assist_1lIJ",
      "NumberUppercase_Assist_8B",
      "NumberUppercase_Assist_8BHR",
      "NumberUppercase_Assist_number",
      "NumberUppercase_Assist_O0DQ",
      "NumberUppercase_Assist_upcase"
    ];
    for (var i = 0; i < fileNames.length; i++) {
      var fileName = fileNames[i];
      ByteData prototxtBuffer = await loadAssetBytes(
          modelPath + "CharacterModel/" + fileName + ".prototxt");

      ByteData txtBuffer = await loadAssetBytes(
          modelPath + "CharacterModel/" + fileName + ".caffemodel");

      ByteData characterModelBuffer = await loadAssetBytes(
          modelPath + "CharacterModel/" + fileName + ".txt");

      _textRecognizer.loadModelFiles(
          fileName,
          prototxtBuffer.buffer.asUint8List(),
          txtBuffer.buffer.asUint8List(),
          characterModelBuffer.buffer.asUint8List());
    }

    String template =
        await loadAssetString(modelPath + 'wholeImgMRZTemplate.json');
    _textRecognizer.loadTemplate(template);
  }

  void pictureScan() async {
    final image = await _controller.takePicture();
    String ret = await _textRecognizer.recognizeByFile(image?.path, '');
    String results = getTextResults(ret);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
            imagePath: image?.path, barcodeResults: results),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  Widget getCameraWidget() {
    if (!_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    } else {
      // https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched
      final size = MediaQuery.of(context).size;
      var scale = size.aspectRatio * _controller.value.aspectRatio;

      if (scale < 1) scale = 1 / scale;

      return Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(child: getCameraWidget()),
      ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              });
          pictureScan();
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String barcodeResults;

  const DisplayPictureScreen({Key key, this.imagePath, this.barcodeResults})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Stack(
        alignment: const Alignment(0.0, 0.0),
        children: [
          // Show full screen image: https://stackoverflow.com/questions/48716067/show-fullscreen-image-at-flutter
          Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
            ),
            child: Text(
              barcodeResults,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
