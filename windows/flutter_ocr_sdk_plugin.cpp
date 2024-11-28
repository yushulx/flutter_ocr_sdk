#include "flutter_ocr_sdk_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace flutter_ocr_sdk
{

  // static
  void FlutterOcrSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "flutter_ocr_sdk",
            &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<FlutterOcrSdkPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result)
        {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  FlutterOcrSdkPlugin::FlutterOcrSdkPlugin()
  {
    manager = new DlrManager();
  }

  FlutterOcrSdkPlugin::~FlutterOcrSdkPlugin()
  {
    delete manager;
  }

  void FlutterOcrSdkPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {

    const auto *arguments = std::get_if<EncodableMap>(method_call.arguments());

    if (method_call.method_name().compare("getPlatformVersion") == 0)
    {
      std::ostringstream version_stream;
      version_stream << "Windows ";
      if (IsWindows10OrGreater())
      {
        version_stream << "10+";
      }
      else if (IsWindows8OrGreater())
      {
        version_stream << "8";
      }
      else if (IsWindows7OrGreater())
      {
        version_stream << "7";
      }
      result->Success(flutter::EncodableValue(version_stream.str()));
    }
    else if (method_call.method_name().compare("init") == 0)
    {
      std::string license;
      int ret = 0;

      if (arguments)
      {
        auto license_it = arguments->find(EncodableValue("key"));
        if (license_it != arguments->end())
        {
          license = std::get<std::string>(license_it->second);
        }
        ret = manager->Init(license.c_str());
      }

      result->Success(EncodableValue(ret));
    }
    else if (method_call.method_name().compare("loadModel") == 0)
    {
      std::string path, params;
      int ret = 0;

      if (arguments)
      {
        auto params_it = arguments->find(EncodableValue("template"));
        if (params_it != arguments->end())
        {
          params = std::get<std::string>(params_it->second);
        }
        ret = manager->LoadModel(params.c_str());
      }

      result->Success(EncodableValue(ret));
    }
    else if (method_call.method_name().compare("recognizeByFile") == 0)
    {
      std::string filename;
      EncodableList results;

      if (arguments)
      {
        auto filename_it = arguments->find(EncodableValue("filename"));
        if (filename_it != arguments->end())
        {
          filename = std::get<std::string>(filename_it->second);
        }

        manager->RecognizeFile(result, filename.c_str());
      }
    }
    else if (method_call.method_name().compare("recognizeByBuffer") == 0)
    {
      EncodableList results;

      std::vector<unsigned char> bytes;
      int width = 0, height = 0, stride = 0, format = 0;

      if (arguments)
      {
        auto bytes_it = arguments->find(EncodableValue("bytes"));
        if (bytes_it != arguments->end())
        {
          bytes = std::get<vector<unsigned char>>(bytes_it->second);
        }

        auto width_it = arguments->find(EncodableValue("width"));
        if (width_it != arguments->end())
        {
          width = std::get<int>(width_it->second);
        }

        auto height_it = arguments->find(EncodableValue("height"));
        if (height_it != arguments->end())
        {
          height = std::get<int>(height_it->second);
        }

        auto stride_it = arguments->find(EncodableValue("stride"));
        if (stride_it != arguments->end())
        {
          stride = std::get<int>(stride_it->second);
        }

        auto format_it = arguments->find(EncodableValue("format"));
        if (format_it != arguments->end())
        {
          format = std::get<int>(format_it->second);
        }
        manager->RecognizeBuffer(result, reinterpret_cast<unsigned char *>(bytes.data()), width, height, stride, format);
      }
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace flutter_ocr_sdk
