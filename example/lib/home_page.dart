import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk_platform_interface.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:flutter_ocr_sdk_example/utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'camera_page.dart';
import 'global.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        Container(
            padding: EdgeInsets.only(
              top: 30,
              left: 33,
            ),
            child: Text('MRZ SCANNER',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                )))
      ],
    );

    final description = Row(
      children: [
        Container(
            padding: EdgeInsets.only(top: 6, left: 33, bottom: 44),
            child: SizedBox(
              width: 271,
              child: Text(
                  'Recognizes MRZ code & extracts data from 1D-codes, passports, and visas.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
            ))
      ],
    );

    void scanImage() async {
      XFile? photo;
      if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
        photo = await picker.pickImage(source: ImageSource.gallery);
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

      // if (!mounted) return;
      // Navigator.pop(context);
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => DisplayPictureScreen(
      //         imagePath: photo!.path, mrzInformation: information),
      //   ),
      // );
    }

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
            onTap: () {
              if (Platform.isLinux) {
                showAlert(context, "Warning",
                    "${Platform.operatingSystem} is not supported");
                return;
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CameraPage();
              }));
            },
            child: Container(
              width: 150,
              height: 125,
              decoration: BoxDecoration(
                color: Color(0xFFfe8e14),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/icon-camera.png",
                    width: 90,
                    height: 60,
                  ),
                  Text(
                    "Camera Scan",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
            )),
        GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: Container(
              width: 150,
              height: 125,
              decoration: BoxDecoration(
                color: Color(0xFF323234),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/icon-image.png",
                    width: 90,
                    height: 60,
                  ),
                  Text(
                    "Image Scan",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
            ))
      ],
    );
    final image = Expanded(
        child: Image.asset(
      "images/image-mrz.png",
      fit: BoxFit.cover,
    ));
    return Scaffold(
      body: Column(
        children: [
          title,
          description,
          buttons,
          SizedBox(
            height: 34,
          ),
          image
        ],
      ),
    );
  }
}
