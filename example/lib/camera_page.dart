import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';

import 'camera/camera_manager.dart';
import 'global.dart';
import 'dart:math';

import 'result_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraManager _mobileCamera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _mobileCamera = CameraManager(
        context: context,
        cbRefreshUi: refreshUI,
        cbIsMounted: isMounted,
        cbNavigation: navigation);
    _mobileCamera.initState();
  }

  void navigation(dynamic order) {
    // Navigator.of(context).pop();
    List<MrzLine> finalArea = order;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(area: finalArea),
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
    _mobileCamera.stopVideo();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_mobileCamera.controller == null ||
        !_mobileCamera.controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _mobileCamera.controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _mobileCamera.toggleCamera(0);
    }
  }

  List<Widget> createCameraPreview() {
    if (_mobileCamera.controller != null && _mobileCamera.previewSize != null) {
      final hint = Text(
          'P<CANAMAN<<RITA<TANIA<<<<<<<<<<<<<<<<<<<<<<<\nERE82721<9CAN8412070M2405252<<<<<<<<<<<<<<08',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ));
      return [
        SizedBox(
            width: MediaQuery.of(context).size.width <
                    MediaQuery.of(context).size.height
                ? _mobileCamera.previewSize!.height
                : _mobileCamera.previewSize!.width,
            height: MediaQuery.of(context).size.width <
                    MediaQuery.of(context).size.height
                ? _mobileCamera.previewSize!.width
                : _mobileCamera.previewSize!.height,
            child: _mobileCamera.getPreview()),
        Positioned(
          top: 0.0,
          right: 0.0,
          bottom: 0,
          left: 0.0,
          child: createOverlay(
            _mobileCamera.mrzLines,
          ),
        ),
        Positioned(
          top: 100,
          left: 100,
          right: 100,
          bottom: 100,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: !kIsWeb && (Platform.isAndroid || Platform.isIOS) ? 0 : 150,
          child: !kIsWeb && (Platform.isAndroid || Platform.isIOS)
              ? Transform.rotate(
                  angle: pi / 2, // 90 degrees in radians
                  child: hint,
                )
              : hint,
        ),
        Positioned(
          left: 122,
          right: 122,
          bottom: 28,
          child: Text('Powered by Dynamsoft',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              )),
        )
      ];
    } else {
      return [const CircularProgressIndicator()];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'MRZ Scanner',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Stack(
            children: <Widget>[
              if (_mobileCamera.controller != null &&
                  _mobileCamera.previewSize != null)
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
            ],
          ),
        ));
  }
}
