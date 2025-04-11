import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk_platform_interface.dart';
import 'package:flutter_ocr_sdk/model_type.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'result_page.dart';
import 'utils.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
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
  bool isMrzSelected = true;
  void openResultPage(OcrLine information) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(information: information),
        ));
  }

  void scanImage() async {
    XFile? photo = await picker.pickImage(source: ImageSource.gallery);

    if (photo == null) {
      return;
    }

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      File rotatedImage =
          await FlutterExifRotation.rotateImage(path: photo.path);
      photo = XFile(rotatedImage.path);
    }

    Uint8List fileBytes = await photo.readAsBytes();

    ui.Image image = await decodeImageFromList(fileBytes);

    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData != null) {
      List<List<OcrLine>>? results = await detector.recognizeByBuffer(
          byteData.buffer.asUint8List(),
          image.width,
          image.height,
          byteData.lengthInBytes ~/ image.height,
          ImagePixelFormat.IPF_ARGB_8888.index,
          0);

      if (results != null && results[0].isNotEmpty) {
        openResultPage(results[0][0]);
      } else {
        showAlert(context, "OCR Result", "Recognition Failed!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        Container(
            padding: const EdgeInsets.only(
              top: 30,
              left: 33,
            ),
            child: const Text('MRZ/VIN SCAN',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                )))
      ],
    );

    final description = Row(
      children: [
        Container(
            padding: const EdgeInsets.only(top: 6, left: 33, bottom: 44),
            child: const SizedBox(
              width: 271,
              child: Text(
                  'Recognizes MRZ code & extracts data from passports, visas, and ID cards',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
            ))
      ],
    );

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
            onTap: () {
              if (!kIsWeb && Platform.isLinux) {
                showAlert(context, "Warning",
                    "${Platform.operatingSystem} is not supported");
                return;
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const CameraPage();
              }));
            },
            child: Container(
              width: 150,
              height: 125,
              decoration: BoxDecoration(
                color: colorOrange,
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
                  const Text(
                    "Camera Scan",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
            )),
        GestureDetector(
            onTap: () {
              scanImage();
            },
            child: Container(
              width: 150,
              height: 125,
              decoration: BoxDecoration(
                color: colorBackground,
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
                  const Text(
                    "Image Scan",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
            ))
      ],
    );

    final image = Image.asset(
      "images/image-mrz.png",
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
    );
    return Scaffold(
      body: Column(
        children: [
          title,
          description,
          Center(
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              isSelected: [isMrzSelected, !isMrzSelected],
              selectedColor: Colors.white,
              fillColor: Colors.orange,
              color: Colors.grey,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('MRZ'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('VIN'),
                ),
              ],
              onPressed: (index) {
                setState(() {
                  isMrzSelected = (index == 0);
                  if (isMrzSelected) {
                    switchModel(ModelType.mrz);
                  } else {
                    switchModel(ModelType.vin);
                  }
                });
              },
            ),
          ),
          buttons,
          const SizedBox(
            height: 34,
          ),
          Expanded(
              child: Stack(
            children: [
              Positioned.fill(
                child: image,
              ),
              if (!isLicenseValid)
                Opacity(
                  opacity: 0.8,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 40,
                      color: const Color(0xffFF1A1A),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: InkWell(
                          onTap: () {
                            launchUrlString(
                                'https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform');
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.white, size: 20),
                              Text(
                                "  License expired! Renew your license",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ))),
                )
            ],
          ))
        ],
      ),
    );
  }
}
