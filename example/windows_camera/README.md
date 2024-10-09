# Camera Windows Plugin

The Flutter Camera Windows Plugin project is ported from [camera_windows](https://github.com/flutter/packages/tree/main/packages/camera/camera_windows). It provides a temporary solution for solving the known [issue #97542](https://github.com/flutter/flutter/issues/97542): Support for image streaming is not yet implemented. With the plugin, you can get the camera frames for image processing.

## Usage
1. In `pubspec.yaml` of your flutter project, add the following dependency:

    ```yaml
    camera_windows: 
        git:
        url: https://github.com/yushulx/flutter_camera_windows.git
    ```
2. Create a `StreamSubscription<FrameAvailabledEvent>` to receive the camera frames for image processing:

    ```dart
    void _onFrameAvailable(FrameAvailabledEvent event) {
        if (mounted) {
            Map<String, dynamic> map = event.toJson();
            final Uint8List? data = map['bytes'] as Uint8List?;
            // image processing
        }
    }

    StreamSubscription<FrameAvailabledEvent>? _frameAvailableStreamSubscription;
    _frameAvailableStreamSubscription?.cancel();
      _frameAvailableStreamSubscription =
          (CameraPlatform.instance as CameraWindows)
              .onFrameAvailable(cameraId)
              .listen(_onFrameAvailable);
    ```

    **Note: To avoid blocking the main thread, you need to move heavy computation to a worker thread: Dart isolate or native thread implemented in platform-specific code. The example demonstrates how to use Dynamsoft Barcode Reader to scan barcode and QR codes. The barcode decoding method is implemented using C++ thread and task queue.**