# flutter_ocr_sdk

A wrapper for [Dynamsoft OCR SDK](https://www.dynamsoft.com/label-recognition/overview/), focusing on [Passport MRZ](https://en.wikipedia.org/wiki/Passport_MRZ) recognition.



## Try Passport MRZ Example

```bash
cd example
flutter run -d <device>
```

![Flutter Passport MRZ recognition](https://www.dynamsoft.com/blog/wp-content/uploads/2021/07/flutter-passport-mrz-recognition.jpg)

## Usage
- Download the [model package](https://github.com/yushulx/flutter_ocr_sdk/releases/download/v0.0.1/model.zip). Unzip model files to `model/` folder, and configure `assets` in `pubspec.yaml`:

    ```yml
    assets:
    - model/
    - model/CharacterModel/
    ```

- Initialize the object and load the model path by the asset path:

    ```dart
    _textRecognizer = FlutterOcrSdk();
    _textRecognizer.loadModel('model/');
    ```
- Recognize passport MRZ by setting an image file and the template name `locr`. The template name is defined in `model/wholeImgMRZTemplate.json`:

    ```dart
    String ret = await _textRecognizer.recognizeByFile(image?.path, 'locr');
    ```

- Recognize passport MRZ by setting an image buffer (E.g. [CameraImage](https://pub.dev/documentation/camera/latest/camera/CameraImage-class.html)) and the template name `locr`:
    
    ```dart
    CameraImage availableImage;
    String ret = await _textRecognizer.recognizeByFile(availableImage.planes[0].bytes,
              availableImage.width,
              availableImage.height,
              availableImage.planes[0].bytesPerRow,
              format, 'locr');
    ```
- Set the [organization ID](https://www.dynamsoft.com/customer/license/trialLicense?product=dlr) if you have a Dynamsoft account:
    
    ```dart
    await _textRecognizer.setOrganizationID('YOUR-ID');
    ```


