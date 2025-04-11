import 'dart:async';

import 'package:camera_windows/camera_windows.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk_platform_interface.dart';
import 'package:flutter_ocr_sdk/model_type.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';

import '../global.dart';

import 'package:camera_platform_interface/camera_platform_interface.dart';

class CameraManager {
  BuildContext context;
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  Size? previewSize;
  bool _isScanAvailable = true;
  List<List<OcrLine>>? ocrLines;
  bool isDriverLicense = true;
  bool isFinished = false;
  StreamSubscription<FrameAvailabledEvent>? _frameAvailableStreamSubscription;
  int cameraIndex = 0;
  bool _isWebFrameStarted = false;
  bool isFrontFound = false;
  bool isBackFound = false;

  CameraManager(
      {required this.context,
      required this.cbRefreshUi,
      required this.cbIsMounted,
      required this.cbNavigation});

  Function cbRefreshUi;
  Function cbIsMounted;
  Function cbNavigation;

  void initState() {
    initCamera();
  }

  Future<void> switchCamera() async {
    if (_cameras.length == 1) return;
    isFinished = true;

    if (kIsWeb) {
      await waitForStop();
      controller?.dispose();
      controller = null;
    }

    cameraIndex = cameraIndex == 0 ? 1 : 0;
    toggleCamera(cameraIndex);
  }

  void resumeCamera() {
    toggleCamera(cameraIndex);
  }

  void pauseCamera() {
    stopVideo();
  }

  Future<void> waitForStop() async {
    while (true) {
      if (_isWebFrameStarted == false) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> stopVideo() async {
    isFinished = true;
    if (kIsWeb) {
      await waitForStop();
    }
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
    _isWebFrameStarted = true;
    while (!(controller == null || isFinished || cbIsMounted() == false)) {
      XFile file = await controller!.takePicture();
      var results = await detector.recognizeByFile(file.path);
      if (results == null || !cbIsMounted()) return;

      ocrLines = results;
      cbRefreshUi();
      handleOcr(results);
    }
    _isWebFrameStarted = false;
  }

  void handleOcr(List<List<OcrLine>> results) {
    if (isFinished || !cbIsMounted()) return;
    cbNavigation(results[0]);
  }

  void processId(
      Uint8List bytes, int width, int height, int stride, int format) {
    // cbRefreshUi();
    int rotation = 0;
    if (MediaQuery.of(context).size.width <
        MediaQuery.of(context).size.height) {
      if (Platform.isAndroid) {
        rotation = 90;
      }
    }

    detector
        .recognizeByBuffer(bytes, width, height, stride, format, rotation)
        .then((results) {
      if (results == null || !cbIsMounted()) return;

      ocrLines = results;
      cbRefreshUi();
      handleOcr(results);

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

      processId(availableImage.planes[0].bytes, availableImage.width,
          availableImage.height, availableImage.planes[0].bytesPerRow, format);
    });
  }

  Future<void> startVideo() async {
    ocrLines = null;

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

      processId(
          data, width, height, width * 4, ImagePixelFormat.IPF_ARGB_8888.index);
    }
  }

  Future<void> initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      List<CameraDescription> allCameras = await availableCameras();

      if (kIsWeb) {
        for (final CameraDescription cameraDescription in allCameras) {
          print(cameraDescription.name);
          if (cameraDescription.name.toLowerCase().contains('front')) {
            if (isFrontFound) continue;
            isFrontFound = true;
            _cameras.add(cameraDescription);
          } else if (cameraDescription.name.toLowerCase().contains('back')) {
            if (isBackFound) continue;
            isBackFound = true;
            _cameras.add(cameraDescription);
          } else {
            _cameras.add(cameraDescription);
          }
        }
      } else {
        _cameras = allCameras;
      }

      if (_cameras.isEmpty) return;

      if (!kIsWeb) {
        toggleCamera(cameraIndex);
      } else {
        if (_cameras.length > 1) {
          cameraIndex = 1;
          toggleCamera(cameraIndex);
        } else {
          toggleCamera(cameraIndex);
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

    // if (kIsWeb && !_isMobileWeb) {
    //   return Transform(
    //     alignment: Alignment.center,
    //     transform: Matrix4.identity()..scale(-1.0, 1.0), // Flip horizontally
    //     child: CameraPreview(controller!),
    //   );
    // }

    return CameraPreview(controller!);
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  Future<void> toggleCamera(int index) async {
    ResolutionPreset preset = ResolutionPreset.high;
    controller = CameraController(
        _cameras[index], kIsWeb ? ResolutionPreset.max : preset,
        enableAudio: false);

    try {
      await controller!.initialize();
      if (cbIsMounted()) {
        previewSize = controller!.value.previewSize;

        startVideo();
      }
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
        default:
          _showCameraException(e);
          break;
      }
    }
  }
}
