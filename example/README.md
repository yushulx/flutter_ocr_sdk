# Flutter MRZ/VIN Scanner

A Flutter project that demonstrates how to use Dynamsoft Capture Vision to scan MRZ (Machine Readable Zone) and VIN (Vehicle Identification Number) from images and camera streams.

https://github.com/user-attachments/assets/c754ec46-f147-45f1-b293-6fbbd20a6e52

## Supported Platforms
- **Windows**

## Getting Started
1. Apply for a [30-day trial license](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform) and replace the license key in the `global.dart` file with your own:

    ```dart
    Future<int> initSDK() async {
        int? ret = await detector.init("LICENSE-KEY");

        if (ret == 0) isLicenseValid = true;
        return await detector.loadModel(modelType: model) ?? -1;
    }
    ```

2. Run the project:

    ```
    flutter run -d windows
    ```
