# Flutter MRZ Scanner

A Flutter project that demonstrates how to use [Dynamsoft Label Recognizer](https://www.dynamsoft.com/label-recognition/overview/) to scan MRZ (Machine Readable Zone) from passport, visa, and ID cards.

https://github.com/user-attachments/assets/1bed4643-a76d-4f75-bfc2-5449a14a8a1a

## Supported Platforms
- **Web**
- **Android**
- **iOS**
- **Windows**
- **Linux** (Without camera support)

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
[https://yushulx.me/flutter_ocr_sdk/](https://yushulx.me/flutter_ocr_sdk/)
