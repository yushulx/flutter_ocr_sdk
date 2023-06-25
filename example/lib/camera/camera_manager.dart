import 'dart:async';

import 'package:camera_windows/camera_windows.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk_platform_interface.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';

import '../global.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera_platform_interface/camera_platform_interface.dart';

enum ScanType { id, barcode, document }

class CameraManager {
  BuildContext context;
  CameraController? controller;
  late List<CameraDescription> _cameras;
  Size? previewSize;
  bool _isScanAvailable = true;
  List<List<MrzLine>>? mrzLines;
  bool isDriverLicense = true;
  ScanType scanType = ScanType.id;
  bool isFinished = false;
  StreamSubscription<FrameAvailabledEvent>? _frameAvailableStreamSubscription;
  bool _isMobileWeb = false;

  CameraManager(
      {required this.context,
      required this.cbRefreshUi,
      required this.cbIsMounted,
      required this.cbNavigation,
      required this.scanType});

  Function cbRefreshUi;
  Function cbIsMounted;
  Function cbNavigation;

  void initState() {
    initCamera();
  }

  Future<void> stopVideo() async {
    if (controller == null) return;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await controller!.stopImageStream();
    }

    controller!.dispose();
    controller = null;

    _frameAvailableStreamSubscription?.cancel();
    _frameAvailableStreamSubscription = null;
  }

  Future<void> webCamera() async {
    if (controller == null || isFinished || cbIsMounted() == false) return;

    XFile file = await controller!.takePicture();

    if (scanType == ScanType.id) {
      var results = await mrzDetector.recognizeByFile(file.path);
      if (results == null || !cbIsMounted()) return;

      mrzLines = results;
      cbRefreshUi();
      handleMrz(results);
    }

    if (!isFinished) {
      webCamera();
    }
  }

  void handleMrz(List<List<MrzLine>> results) {
    if (results.isNotEmpty) {
      MrzResult information = MrzResult();

      try {
        for (List<MrzLine> area in results) {
          if (area.length == 2) {
            information = MRZ.parseTwoLines(area[0].text, area[1].text);
          } else if (area.length == 3) {
            information =
                MRZ.parseThreeLines(area[0].text, area[1].text, area[2].text);
          }
        }
      } catch (e) {
        print(e);
      }

      if (information.surname == '') {
        information.surname = 'Not found';
      }

      if (information.givenName == '') {
        information.givenName = 'Not found';
      }

      if (information.nationality == '') {
        information.nationality = 'Not found';
      }

      if (information.passportNumber == '') {
        information.passportNumber = 'Not found';
      }

      if (!isFinished) {
        isFinished = true;
        // ProfileData scannedData = ProfileData();

        // scannedData.firstName = information.givenName;
        // scannedData.lastName = information.surname;
        // scannedData.nationality = information.nationality;
        // scannedData.idNumber = information.passportNumber;
        // cbNavigation(scannedData);
      }
    }
  }

  void processId(
      Uint8List bytes, int width, int height, int stride, int format) {
    cbRefreshUi();
    mrzDetector
        .recognizeByBuffer(bytes, width, height, stride, format)
        .then((results) {
      if (results == null || !cbIsMounted()) return;

      if (MediaQuery.of(context).size.width <
          MediaQuery.of(context).size.height) {
        if (Platform.isAndroid) {
          results = rotate90mrz(results, previewSize!.height.toInt());
        }
      }

      mrzLines = results;
      cbRefreshUi();
      handleMrz(results);

      _isScanAvailable = true;
    });
  }

  Future<void> mobileCamera() async {
    await controller!.startImageStream((CameraImage availableImage) async {
      assert(defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
      if (cbIsMounted() == false || isFinished) return;
      int format = ImagePixelFormat.IPF_NV21.index;

      switch (availableImage.format.group) {
        case ImageFormatGroup.yuv420:
          format = ImagePixelFormat.IPF_NV21.index;
          break;
        case ImageFormatGroup.bgra8888:
          format = ImagePixelFormat.IPF_ARGB_8888.index;
          break;
        default:
          format = ImagePixelFormat.IPF_RGB_888.index;
      }

      if (!_isScanAvailable) {
        return;
      }

      _isScanAvailable = false;

      if (scanType == ScanType.id) {
        processId(
            availableImage.planes[0].bytes,
            availableImage.width,
            availableImage.height,
            availableImage.planes[0].bytesPerRow,
            format);
      }
    });
  }

  Future<void> startVideo() async {
    mrzLines = null;

    isFinished = false;

    cbRefreshUi();

    if (kIsWeb) {
      webCamera();
    } else if (Platform.isAndroid || Platform.isIOS) {
      mobileCamera();
    } else if (Platform.isWindows) {
      _frameAvailableStreamSubscription?.cancel();
      _frameAvailableStreamSubscription =
          (CameraPlatform.instance as CameraWindows)
              .onFrameAvailable(controller!.cameraId)
              .listen(_onFrameAvailable);
    }
  }

  void _onFrameAvailable(FrameAvailabledEvent event) {
    if (cbIsMounted() == false || isFinished) return;

    Map<String, dynamic> map = event.toJson();
    final Uint8List? data = map['bytes'] as Uint8List?;
    if (data != null) {
      if (!_isScanAvailable) {
        return;
      }

      _isScanAvailable = false;
      int width = previewSize!.width.toInt();
      int height = previewSize!.height.toInt();

      if (scanType == ScanType.id) {
        processId(data, width, height, width * 4,
            ImagePixelFormat.IPF_ARGB_8888.index);
      }
    }
  }

  Future<void> initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
      int index = 0;

      for (; index < _cameras.length; index++) {
        CameraDescription description = _cameras[index];
        if (description.name.toLowerCase().contains('back')) {
          _isMobileWeb = true;
          break;
        }
      }
      if (_cameras.isEmpty) return;

      if (!kIsWeb) {
        toggleCamera(0);
      } else {
        if (_isMobileWeb) {
          toggleCamera(index);
        } else {
          toggleCamera(0);
        }
      }
    } on CameraException catch (e) {
      print(e);
    }
  }

  Widget getPreview() {
    if (controller == null || !controller!.value.isInitialized || isFinished) {
      return Container(
        child: const Text('No camera available!'),
      );
    }

    if (kIsWeb && !_isMobileWeb) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip horizontally
        child: CameraPreview(controller!),
      );
    }

    return CameraPreview(controller!);
  }

  Future<void> toggleCamera(int index) async {
    if (controller != null) controller!.dispose();

    controller = CameraController(_cameras[index], ResolutionPreset.medium);
    controller!.initialize().then((_) {
      if (!cbIsMounted()) {
        return;
      }

      previewSize = controller!.value.previewSize;

      startVideo();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }
}
