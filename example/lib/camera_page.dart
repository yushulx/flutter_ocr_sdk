import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';

import 'camera/camera_manager.dart';
import 'global.dart';
import 'dart:math';

import 'result_page.dart';
import 'utils.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraManager _cameraManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _cameraManager = CameraManager(
        context: context,
        cbRefreshUi: refreshUI,
        cbIsMounted: isMounted,
        cbNavigation: navigation);
    _cameraManager.initState();
  }

  void navigation(dynamic order) {
    List<OcrLine> area = order;

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(information: area[0]),
        ));
  }

  void refreshUI() {
    setState(() {});
  }

  bool isMounted() {
    return mounted;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraManager.stopVideo();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraManager.controller == null ||
        !_cameraManager.controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraManager.controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _cameraManager.toggleCamera(0);
    }
  }

  List<Widget> createCameraPreview() {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      return [
        SizedBox(width: 640, height: 480, child: _cameraManager.getPreview()),
        Positioned(
          top: 0.0,
          right: 0.0,
          bottom: 0,
          left: 0.0,
          child: createOverlay(
            _cameraManager.ocrLines,
          ),
        ),
      ];
    } else {
      if (_cameraManager.controller != null &&
          _cameraManager.previewSize != null) {
        double width = _cameraManager.previewSize!.width;
        double height = _cameraManager.previewSize!.height;
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          if (MediaQuery.of(context).size.width <
              MediaQuery.of(context).size.height) {
            width = _cameraManager.previewSize!.height;
            height = _cameraManager.previewSize!.width;
          }
        }

        return [
          SizedBox(
              width: width, height: height, child: _cameraManager.getPreview()),
          Positioned(
            top: 0.0,
            right: 0.0,
            bottom: 0,
            left: 0.0,
            child: createOverlay(
              _cameraManager.ocrLines,
            ),
          ),
        ];
      } else {
        return [const CircularProgressIndicator()];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var captureButton = InkWell(
      onTap: () {
        _cameraManager.isReadyToGo = true;
      },
      child: Image.asset('images/icon-capture.png', width: 80, height: 80),
    );

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'MRZ/VIN Scanner',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(
              color: Colors
                  .white, // Set the color of the back arrow and other icons
            ),
          ),
          body: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Stack(
                    children: createCameraPreview(),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: 155,
                right: 155,
                child: captureButton,
              ),
            ],
          ),
          floatingActionButton: Opacity(
            opacity: 0.5,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              child: const Icon(Icons.flip_camera_android),
              onPressed: () {
                _cameraManager.switchCamera();
              },
            ),
          ),
        ));
  }
}
