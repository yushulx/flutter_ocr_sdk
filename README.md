# Flutter MRZ SDK

A wrapper for [Dynamsoft Label Recognizer v2.x](https://www.dynamsoft.com/label-recognition/overview/) with MRZ detection model. It helps developers build Flutter applications to detect machine-readable zones (**MRZ**) in passports, travel documents, and ID cards. 

## License Key
To use the SDK, you need a [license key for Dynamsoft Label Recognizer](https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform). Make sure to get your trial or commercial license before using the library.

## Try Flutter MRZ Detection Example

```bash
cd example
flutter run # for Android
flutter run -d chrome # for Web
flutter run -d windows # for Windows
```

![Flutter Passport MRZ recognition](https://www.dynamsoft.com/codepool/img/2024/10/flutter-passport-mrz-reader-scanner.png)


## Supported Platforms
- Android
- Web
- Windows
- Linux
- iOS

## Installation
Add `flutter_ocr_sdk` as a dependency in your `pubspec.yaml` file.

```yml
dependencies:
    ...
    flutter_ocr_sdk:
```

### Additional Step for Web
To support web functionality, include the JavaScript library of Dynamsoft Label Recognizer in your `index.html` file:

```html
<script src="https://cdn.jsdelivr.net/npm/dynamsoft-label-recognizer@2.2.31/dist/dlr.js"></script>
```


## API Compatibility
| Methods      | Android |    iOS | Windows | Linux | macOS | Web|
| ----------- | ----------- | ----------- | ----------- |----------- |----------- |----------- |
| `Future<int?> init(String key)`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:      | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:    |
| `Future<int?> loadModel()`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:     |:heavy_check_mark:      |
| `Future<List<List<MrzLine>>?> recognizeByFile(String filename)`     | :heavy_check_mark:      | :heavy_check_mark:   | :heavy_check_mark:      |:heavy_check_mark:      | :heavy_check_mark:     |:heavy_check_mark:    |
| `Future<List<List<MrzLine>>?> recognizeByBuffer(Uint8List bytes, int width, int height, int stride, int format)`     | :heavy_check_mark:       | :heavy_check_mark:   | :heavy_check_mark:       | :heavy_check_mark:       |:heavy_check_mark:      | :heavy_check_mark:     |


## Usage
- Initialize the MRZ detector with a [valid license key](https://www.dynamsoft.com/customer/license/trialLicense/?product=dlr):

    ```dart
    FlutterOcrSdk _mrzDetector = FlutterOcrSdk();
    int? ret = await _mrzDetector.init( "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
    ```
- Load the MRZ detection model:
    ```dart
    await _mrzDetector.loadModel();
    ```
- Recognize MRZ from an image file:

    ```dart
    List<List<MrzLine>>? results = await _mrzDetector.recognizeByFile(photo.path);
    ```
- Recognize MRZ from an image buffer:

    ```dart
    ui.Image image = await decodeImageFromList(fileBytes);

    ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    List<List<MrzLine>>? results = await _mrzDetector.recognizeByBuffer(
          byteData.buffer.asUint8List(),
          image.width,
          image.height,
          byteData.lengthInBytes ~/ image.height,
          ImagePixelFormat.IPF_ARGB_8888.index);
    ```
- Parse MRZ information:

    ```dart
    String information = '';
    if (results != null && results.isNotEmpty) {
        for (List<MrzLine> area in results) {
            if (area.length == 2) {
            information =
                MRZ.parseTwoLines(area[0].text, area[1].text).toString();
            } else if (area.length == 3) {
            information = MRZ
                .parseThreeLines(area[0].text, area[1].text, area[2].text)
                .toString();
            }
        }
    }
    ```


