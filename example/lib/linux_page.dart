import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_ocr_sdk/flutter_ocr_sdk_platform_interface.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'dart:ui' as ui;

import 'global.dart';

class LinuxPage extends StatefulWidget {
  @override
  MobileState createState() => MobileState();
}

class MobileState extends State<LinuxPage> {
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  void pictureScan(String source) async {
    XFile? photo;
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
      if (source == 'camera') {
        photo = await picker.pickImage(source: ImageSource.camera);
      } else {
        photo = await picker.pickImage(source: ImageSource.gallery);
      }
    } else if (Platform.isWindows || Platform.isLinux) {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'images',
        extensions: <String>['jpg', 'png', 'bmp', 'tiff', 'pdf', 'gif'],
      );
      photo = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    }

    if (photo == null) {
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    String information = 'No results';

    // List<List<MrzLine>>? results =
    //     await mrzDetector.recognizeByFile(photo.path);
    // print(results);
    // if (results != null && results.isNotEmpty) {
    //   for (List<MrzLine> area in results) {
    //     if (area.length == 2) {
    //       information =
    //           MRZ.parseTwoLines(area[0].text, area[1].text).toString();
    //     } else if (area.length == 3) {
    //       information = MRZ
    //           .parseThreeLines(area[0].text, area[1].text, area[2].text)
    //           .toString();
    //     }
    //   }
    // }

    Uint8List fileBytes = await photo.readAsBytes();

    ui.Image image = await decodeImageFromList(fileBytes);

    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData != null) {
      List<List<MrzLine>>? results = await mrzDetector.recognizeByBuffer(
          byteData.buffer.asUint8List(),
          image.width,
          image.height,
          byteData.lengthInBytes ~/ image.height,
          ImagePixelFormat.IPF_ARGB_8888.index);

      if (results != null && results.isNotEmpty) {
        for (List<MrzLine> area in results) {
          if (area.length == 2) {
            information =
                MRZ.parseTwoLines(area[0].text, area[1].text).toString();
          } else if (area.length == 3) {
            information = MRZ
                .parseThreeLines(area[0].text, area[1].text, area[2].text)
                .toString();
          }
        }
      }
    }

    if (!mounted) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
            imagePath: photo!.path, mrzInformation: information),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              ]),
        )
      ]),
    );
  }
}

Image getImage(String imagePath) {
  if (kIsWeb) {
    return Image.network(imagePath);
  } else {
    return Image.file(
      File(imagePath),
      fit: BoxFit.contain,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String mrzInformation;

  const DisplayPictureScreen(
      {Key? key, required this.imagePath, required this.mrzInformation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MRZ OCR')),
      body: Stack(
        alignment: const Alignment(0.0, 0.0),
        children: [
          getImage(imagePath),
          Container(
            decoration: const BoxDecoration(
              color: Colors.black45,
            ),
            child: Text(
              mrzInformation,
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
