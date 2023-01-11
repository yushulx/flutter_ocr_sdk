import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter_ocr_sdk/flutter_ocr_sdk.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:image_picker/image_picker.dart';

class Mobile extends StatefulWidget {
  @override
  MobileState createState() => MobileState();
}

String getTextResults(String json) {
  StringBuffer sb = StringBuffer();
  List<dynamic>? obj = jsonDecode(json)['results'];
  if (obj != null) {
    for (dynamic tmp in obj) {
      List<dynamic> area = tmp['area'];

      if (area.length == 2) {
        String line1 = area[0]['text'];
        String line2 = area[1]['text'];
        return MRZ.parseTwoLines(line1, line2).toString();
      } else if (area.length == 3) {
        String line1 = area[0]['text'];
        String line2 = area[1]['text'];
        String line3 = area[2]['text'];
        return MRZ.parseThreeLines(line1, line2, line3).toString();
      }
    }
  }

  return 'No results';
}

class MobileState extends State<Mobile> {
  late FlutterOcrSdk _mrzDetector;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    initSDK();
  }

  Future<void> initSDK() async {
    _mrzDetector = FlutterOcrSdk();
    int? ret = await _mrzDetector.init("",
        "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
    await _mrzDetector.loadModel('model/');
  }

  void pictureScan(String source) async {
    XFile? photo;
    if (source == 'camera') {
      photo = await picker.pickImage(source: ImageSource.camera);
    } else {
      photo = await picker.pickImage(source: ImageSource.gallery);
    }

    if (photo == null) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }
    String? json = await _mrzDetector.recognizeByFile(photo.path);
    if (json != null) {
      String results = getTextResults(json);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
              imagePath: photo!.path, barcodeResults: results),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double left = 5;
    double mrzHeight = 50;
    double mrzWidth = width - left * 2;
    return Scaffold(
      body: Stack(children: [
        Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    pictureScan('gallery');
                  },
                  child: const Text('Pick gallery image'),
                ),
                MaterialButton(
                  textColor: Colors.white,
                  color: Colors.blue,
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        });
                    pictureScan('camera');
                  },
                  child: const Text('Pick camera image'),
                ),
              ]),
        )
      ]),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String barcodeResults;

  const DisplayPictureScreen(
      {Key? key, required this.imagePath, required this.barcodeResults})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MRZ OCR')),
      body: Stack(
        alignment: const Alignment(0.0, 0.0),
        children: [
          // Show full screen image: https://stackoverflow.com/questions/48716067/show-fullscreen-image-at-flutter
          Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.black45,
            ),
            child: Text(
              barcodeResults,
              style: const TextStyle(
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
