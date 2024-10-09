# Camera Web Plugin
The Flutter Camera Web Plugin project is ported from [https://github.com/flutter/packages/tree/main/packages/camera/camera_web](https://github.com/flutter/packages/tree/main/packages/camera/camera_web). The front camera flip is disabled in this project.

```dart
// final bool isBackCamera = getLensDirection() == CameraLensDirection.back;

// Flip the picture horizontally if it is not taken from a back camera.
// if (!isBackCamera) {
//   canvas.context2D
//     ..translate(videoWidth, 0)
//     ..scale(-1, 1);
// }
```
