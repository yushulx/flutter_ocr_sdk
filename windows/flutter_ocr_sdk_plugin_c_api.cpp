#include "include/flutter_ocr_sdk/flutter_ocr_sdk_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_ocr_sdk_plugin.h"

void FlutterOcrSdkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_ocr_sdk::FlutterOcrSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
