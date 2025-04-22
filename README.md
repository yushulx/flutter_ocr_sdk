# Flutter MRZ/VIN SDK 

A Flutter wrapper for the **Dynamsoft Capture Vision SDK**, featuring built-in **MRZ (Machine Readable Zone)** and **VIN (Vehicle Identification Number)** detection models.

## Demo Video

- **Android**

  https://github.com/user-attachments/assets/7e84b0c8-c492-4262-97c7-851651d9327e

- **iOS**

  https://github.com/user-attachments/assets/56ddd2a7-7ef9-4376-a090-2b562801c660

- **Web**

  https://github.com/user-attachments/assets/df02a1e7-a751-4048-9ed0-b9df6ee27621

- **Windows**

  https://github.com/user-attachments/assets/b3e9f541-1747-413f-98f5-2291be35bd71

- **Linux**

  https://github.com/user-attachments/assets/7a8748a4-dcc7-4889-9043-805d1a6aba62


## Supported Platforms
- ✅ Windows
- ✅ Linux
- ✅ Android
- ✅ iOS
    
    Add camera and microphone usage descriptions to `ios/Runner/Info.plist`:
    
    ```xml
    <key>NSCameraUsageDescription</key>
    <string>Can I use the camera please?</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Can I use the mic please?</string>
    ```

- ✅ Web
        
    In `index.html`, include:

    ```html
    <script src="https://cdn.jsdelivr.net/npm/dynamsoft-capture-vision-bundle@2.6.1000/dist/dcv.bundle.min.js"></script>
    ```


## Prerequisites
- A valid [Dynamsoft Capture Vision license key](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform)

## Getting Started
1. Set the license key in `example/lib/global.dart`:

    ```dart
    Future<int> initSDK() async {
      int? ret = await detector.init(
          "LICENSE-KEY");
      ...
    }
    ```
2. Run the example project on your desired platform:

    ```bash
    cd example
    flutter run -d chrome    # Run on Web
    flutter run -d linux     # Run on Linux
    flutter run -d windows   # Run on Windows
    flutter run              # Run on default connected device (e.g., Android)
    ```

## API Reference

| Method                                                                 | Description                                             | Parameters                                                                                                                                                     | Return Type                        |
|------------------------------------------------------------------------|---------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------|
| `Future<int?> init(String key)`                                        | Initializes the OCR SDK with a license key.             | `key`: License string                                                                                                                                            | `Future<int?>`                     |
| `Future<List<List<OcrLine>>?> recognizeBuffer(Uint8List bytes, int width, int height, int stride, int format, int rotation)` | Performs OCR on a raw image buffer.                    | `bytes`: RGBA image buffer  <br> `width`, `height`: Image dimensions <br> `stride`: Row bytes <br> `format`: Pixel format index <br> `rotation`: 0/90/180/270 | `Future<List<List<OcrLine>>?>`    |
| `Future<List<List<OcrLine>>?> recognizeFile(String filename)`       | Performs OCR on an image file.                          | `filename`: Path to the image file                                                                                                                              | `Future<List<List<OcrLine>>?>`    |
| `Future<int?> loadModel({ModelType modelType = ModelType.mrz})`       | Loads the OCR model by type (`mrz` or `vin`).           | `modelType`: Optional, defaults to `ModelType.mrz`                                                                                                              | `Future<int?>`                     |
