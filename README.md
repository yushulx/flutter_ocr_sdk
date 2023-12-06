# flutter_ocr_sdk

A wrapper for [Dynamsoft OCR SDK](https://www.dynamsoft.com/label-recognition/overview/) with MRZ detection model. It helps developers build Flutter applications to detect machine-readable zones (**MRZ**) in passports, travel documents, and ID cards. 

## Try MRZ Detection Example

### Mobile: Android and iOS
```bash
cd example
flutter run 
```

![Flutter Passport MRZ recognition](https://www.dynamsoft.com/codepool/img/2021/07/flutter-passport-mrz-recognition.jpg)

### Web
```bash
cd example
flutter run -d chrome
```

![Flutter MRZ recognition in web](https://www.dynamsoft.com/codepool/img/2023/01/flutter_mrz_ocr_web.png)

### Desktop: Windows and Linux
```bash
cd example
flutter run -d windows

# flutter run -d linux
```

![Flutter MRZ OCR in Windows](https://www.dynamsoft.com/codepool/img/2023/01/flutter-mrz-ocr-windows.png)

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

### One More Step for Web
Include the JavaScript library of Dynamsoft Label Recognizer in your `index.html` file:

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


