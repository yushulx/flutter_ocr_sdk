# Flutter MRZ Scanner

A Flutter project that demonstrates how to use [Dynamsoft Label Recognizer](https://www.dynamsoft.com/label-recognition/overview/) to scan MRZ (Machine Readable Zone) from passport, visa, and ID cards.

https://github.com/yushulx/flutter_ocr_sdk/assets/2202306/bb10f353-bcfc-4b41-a1ef-fc7fcb6a25ef

## Supported Platforms
- **Web**
- **Android**
- **iOS**
- **Windows**
- **Linux** (Without camera support)

## Known Issues
When the application is executed on desktop browsers, the camera frame appears mirrored. This has been observed to cause failures in the Machine Readable Zone (MRZ) detection process. Therefore, it's necessary to address this issue within the [Flutter camera plugin](https://pub.dev/packages/camera).

![flutter camera issue for web](https://github.com/yushulx/flutter-MRZ-scanner/assets/2202306/7bdd7e57-7340-4149-a081-75f4622851aa)

A temporary workaround is to disable the camera flip code in [https://github.com/flutter/packages/blob/main/packages/camera/camera_web/lib/src/camera_web.dart](https://github.com/flutter/packages/blob/main/packages/camera/camera_web/lib/src/camera_web.dart):

```dart
// final bool isBackCamera = getLensDirection() == CameraLensDirection.back;

// Flip the picture horizontally if it is not taken from a back camera.
// if (!isBackCamera) {
//   canvas.context2D
//     ..translate(videoWidth, 0)
//     ..scale(-1, 1);
// }
```


## Getting Started
1. Apply for a [30-day trial license](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform) and replace the license key in the `global.dart` file with your own:

    ```dart
    Future<int> initMRZSDK() async {
        await mrzDetector.init(
            "LICENSE-KEY");
        return await mrzDetector.loadModel() ?? -1;
    }
    ```

2. Run the project:

    ```
    flutter run
    # flutter run -d windows
    # flutter run -d edge
    # flutter run -d linux
    ```
    
## Try Online Demo
[https://yushulx.me/flutter-MRZ-scanner/](https://yushulx.me/flutter-MRZ-scanner/)
