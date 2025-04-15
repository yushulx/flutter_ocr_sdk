#ifndef FLUTTER_PLUGIN_FLUTTER_OCR_SDK_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_OCR_SDK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "include/dlr_manager.h"

namespace flutter_ocr_sdk
{

  class FlutterOcrSdkPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    FlutterOcrSdkPlugin();

    virtual ~FlutterOcrSdkPlugin();

    // Disallow copy and assign.
    FlutterOcrSdkPlugin(const FlutterOcrSdkPlugin &) = delete;
    FlutterOcrSdkPlugin &operator=(const FlutterOcrSdkPlugin &) = delete;

  private:
    CaptureVisionManager *manager;
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  };

} // namespace flutter_ocr_sdk

#endif // FLUTTER_PLUGIN_FLUTTER_OCR_SDK_PLUGIN_H_
