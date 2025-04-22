import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_ocr_sdk/flutter_ocr_sdk_platform_interface.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter_lite_camera/flutter_lite_camera.dart';
import 'dart:ui' as ui;
import '../global.dart';

import 'frame_painter.dart';

class CameraManager {
  BuildContext context;
  CameraController? controller;
  List<CameraDescription> _cameras = [];
  Size? previewSize;
  bool _isScanAvailable = true;
  List<List<OcrLine>>? ocrLines;
  bool isDriverLicense = true;
  bool isFinished = false;
  int cameraIndex = 0;
  bool isReadyToGo = false;
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

  ui.Image? _latestFrame;
  bool _isCameraOpened = false;
  final _width = 640;
  final _height = 480;
  bool _shouldCapture = false;
  bool isDecoding = false;
  final FlutterLiteCamera _flutterLiteCameraPlugin = FlutterLiteCamera();
  List<String> _devices = [];

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
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _stopCamera();
    } else {
      // await controller!.stopImageStream();
      // controller!.dispose();
      // controller = null;
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
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _stopCamera();
    }
    if (controller == null) return;
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await controller!.stopImageStream();
    }

    controller!.dispose();
    controller = null;
  }

  Future<void> webCamera() async {
    _isWebFrameStarted = true;
    while (!(controller == null || isFinished || cbIsMounted() == false)) {
      XFile file = await controller!.takePicture();
      var results = await detector.recognizeFile(file.path);
      if (results == null || !cbIsMounted()) return;

      ocrLines = results;
      cbRefreshUi();
      if (isReadyToGo) {
        handleOcr(results);
      }
    }
    _isWebFrameStarted = false;
  }

  void handleOcr(List<List<OcrLine>> results) {
    if (results[0].isNotEmpty) {
      if (!isFinished) {
        isFinished = true;
        cbNavigation(results[0]);
      }
    }
  }

  void processId(
      Uint8List bytes, int width, int height, int stride, int format) {
    // cbRefreshUi();
    int rotation = 0;
    if (MediaQuery.of(context).size.width <
        MediaQuery.of(context).size.height) {
      if (Platform.isAndroid) {
        rotation = ImageRotation.rotation90.value;
      }
    }

    detector
        .recognizeBuffer(bytes, width, height, stride, format, rotation)
        .then((results) {
      if (results == null || !cbIsMounted()) return;

      ocrLines = results;
      cbRefreshUi();
      if (isReadyToGo) {
        handleOcr(results);
      }

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
    }
  }

  Future<void> initCamera() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
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
    } else {
      _devices = await _flutterLiteCameraPlugin.getDeviceList();
      if (_devices.isNotEmpty) {
        toggleCamera(0);
      }
    }
  }

  ///////////////////////////////////////////////////////
  /// Flutter Lite Camera Plugin

  Future<void> _startCamera(int index) async {
    try {
      if (_devices.isNotEmpty && index < _devices.length) {
        bool opened = await _flutterLiteCameraPlugin.open(index);
        if (opened) {
          _isCameraOpened = true;
          _shouldCapture = true;
          _captureFrames();
        } else {
          print("Failed to open the camera.");
        }
      }
    } catch (e) {
      // print("Error initializing camera: $e");
    }
  }

  Future<void> _stopCamera() async {
    _shouldCapture = false;

    if (_isCameraOpened) {
      await _flutterLiteCameraPlugin.release();
      _isCameraOpened = false;
      _latestFrame = null;
      isDecoding = false;
      ocrLines = null;
    }
  }

  Future<void> _decodeFrame(Uint8List rgb, int width, int height) async {
    if (isDecoding) return;

    isDecoding = true;
    ocrLines = await detector.recognizeBuffer(rgb, width, height, width * 3,
        ImagePixelFormat.IPF_RGB_888.index, ImageRotation.rotation0.value);

    if (cbIsMounted()) {
      cbRefreshUi();
      if (isReadyToGo && ocrLines != null && ocrLines!.isNotEmpty) {
        handleOcr(ocrLines!);
      }
    }

    isDecoding = false;
  }

  Future<void> _captureFrames() async {
    if (!_isCameraOpened || !_shouldCapture || !cbIsMounted()) return;

    try {
      Map<String, dynamic> frame =
          await _flutterLiteCameraPlugin.captureFrame();
      if (frame.containsKey('data')) {
        Uint8List rgbBuffer = frame['data'];
        _decodeFrame(rgbBuffer, frame['width'], frame['height']);
        await _convertBufferToImage(rgbBuffer, frame['width'], frame['height']);
      }
    } catch (e) {
      // print("Error capturing frame: $e");
    }

    // Schedule the next frame
    if (_shouldCapture) {
      Future.delayed(const Duration(milliseconds: 30), _captureFrames);
    }
  }

  Future<void> _convertBufferToImage(
      Uint8List rgbBuffer, int width, int height) async {
    final pixels = Uint8List(width * height * 4); // RGBA buffer

    for (int i = 0; i < width * height; i++) {
      int r = rgbBuffer[i * 3];
      int g = rgbBuffer[i * 3 + 1];
      int b = rgbBuffer[i * 3 + 2];

      // Populate RGBA buffer
      pixels[i * 4] = b;
      pixels[i * 4 + 1] = g;
      pixels[i * 4 + 2] = r;
      pixels[i * 4 + 3] = 255; // Alpha channel
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );

    final image = await completer.future;
    _latestFrame = image;

    cbRefreshUi();
  }

  Widget _buildCameraStream() {
    if (_latestFrame == null) {
      return Image.asset(
        'images/default.png',
      );
    } else {
      return CustomPaint(
        painter: FramePainter(_latestFrame!),
        child: SizedBox(
          width: _width.toDouble(),
          height: _height.toDouble(),
        ),
      );
    }
  }

  ///////////////////////////////////////////////////////

  Widget getPreview() {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return _buildCameraStream();
    }

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
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
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
            showInSnackBar(
                'Please go to Settings app to enable camera access.');
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
    } else {
      ocrLines = null;
      isFinished = false;
      _startCamera(index);
    }
  }
}
