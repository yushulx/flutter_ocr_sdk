# flutter_ocr_sdk

A wrapper for [Dynamsoft OCR SDK](https://www.dynamsoft.com/label-recognition/overview/). It helps developers build Flutter applications to detect machine-readable zones (**MRZ**) in passports, travel documents, and ID cards. 

## Try MRZ Detection Example

```bash
cd example
flutter run -d <device>
```

![Flutter Passport MRZ recognition](https://www.dynamsoft.com/codepool/img/2021/07/flutter-passport-mrz-recognition.jpg)

## Usage
- Download the [model folder](https://github.com/yushulx/flutter_ocr_sdk/tree/main/example/model) to your project, and configure `assets` in `pubspec.yaml`:

    ```yml
    assets:
        - model/
    ```

- Initialize the MRZ detector with a [valid license key](https://www.dynamsoft.com/customer/license/trialLicense/?product=dlr):

    ```dart
    _mrzDetector = FlutterOcrSdk();
    int? ret = await _mrzDetector.init("",
        "DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==");
    ```
- Load the MRZ detection model:
    ```dart
    await _mrzDetector.loadModel('model/');
    ```
- Recognize and parse MRZ information from an image file:

    ```dart
    String? json = await _mrzDetector.recognizeByFile(photo.path);
    String results = getTextResults(json);

    String getTextResults(String json) {
    StringBuffer sb = StringBuffer();
    List<dynamic>? obj = jsonDecode(json)['results'];
        if (obj != null) {
            for (dynamic tmp in obj) {
                List<dynamic> area = tmp['area'];

                if (area.length == 2) {
                    String line1 = area[0]['text'];
                    String line2 = area[1]['text'];
                    return MRZ.parseTwoLines(line1, line2).toString();
                } else if (area.length == 3) {
                    String line1 = area[0]['text'];
                    String line2 = area[1]['text'];
                    String line3 = area[2]['text'];
                    return MRZ.parseThreeLines(line1, line2, line3).toString();
                }
            }
        }

        return 'No results';
    }
    ```


