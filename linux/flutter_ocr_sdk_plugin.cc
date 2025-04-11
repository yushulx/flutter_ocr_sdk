#include "include/flutter_ocr_sdk/flutter_ocr_sdk_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include "include/dlr_manager.h"

#define FLUTTER_OCR_SDK_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_ocr_sdk_plugin_get_type(), \
                              FlutterOcrSdkPlugin))

struct _FlutterOcrSdkPlugin
{
  GObject parent_instance;
  DlrManager *manager;
};

G_DEFINE_TYPE(FlutterOcrSdkPlugin, flutter_ocr_sdk_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void flutter_ocr_sdk_plugin_handle_method_call(
    FlutterOcrSdkPlugin *self,
    FlMethodCall *method_call)
{
  bool isAsync = false;
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);
  FlValue *args = fl_method_call_get_args(method_call);

  if (strcmp(method, "init") == 0)
  {
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP)
    {
      return;
    }

    FlValue *value = fl_value_lookup_string(args, "key");
    if (value == nullptr)
    {
      return;
    }
    const char *license = fl_value_get_string(value);

    int ret = self->manager->Init(license);
    g_autoptr(FlValue) result = fl_value_new_int(ret);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "loadModel") == 0)
  {
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP)
    {
      return;
    }

    FlValue *value = fl_value_lookup_string(args, "template");
    if (value == nullptr)
    {
      return;
    }
    const char *params = fl_value_get_string(value);

    std::string str(params);
    int ret = self->manager->LoadModel(str);

    g_autoptr(FlValue) result = fl_value_new_int(ret);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "recognizeByFile") == 0)
  {
    isAsync = true;
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP)
    {
      return;
    }

    FlValue *value = fl_value_lookup_string(args, "filename");
    if (value == nullptr)
    {
      return;
    }
    const char *filename = fl_value_get_string(value);

    self->manager->RecognizeFile(method_call, filename);
  }
  else if (strcmp(method, "recognizeBuffer") == 0)
  {
    isAsync = true;
    if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP)
    {
      return;
    }

    FlValue *value = fl_value_lookup_string(args, "bytes");
    if (value == nullptr)
    {
      return;
    }
    unsigned char *bytes = (unsigned char *)fl_value_get_uint8_list(value);

    value = fl_value_lookup_string(args, "width");
    if (value == nullptr)
    {
      return;
    }
    int width = fl_value_get_int(value);

    value = fl_value_lookup_string(args, "height");
    if (value == nullptr)
    {
      return;
    }
    int height = fl_value_get_int(value);

    value = fl_value_lookup_string(args, "stride");
    if (value == nullptr)
    {
      return;
    }
    int stride = fl_value_get_int(value);

    value = fl_value_lookup_string(args, "format");
    if (value == nullptr)
    {
      return;
    }
    int format = fl_value_get_int(value);

    value = fl_value_lookup_string(args, "rotation");
    if (value == nullptr)
    {
      return;
    }
    int rotation = fl_value_get_int(value);

    self->manager->RecognizeBuffer(method_call, bytes, width, height, stride, format, stride * height, rotation);
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  if (!isAsync)
  {
    fl_method_call_respond(method_call, response, nullptr);
  }
}

static void flutter_ocr_sdk_plugin_dispose(GObject *object)
{
  FlutterOcrSdkPlugin *self = FLUTTER_OCR_SDK_PLUGIN(object);
  delete self->manager;
  G_OBJECT_CLASS(flutter_ocr_sdk_plugin_parent_class)->dispose(object);
}

static void flutter_ocr_sdk_plugin_class_init(FlutterOcrSdkPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = flutter_ocr_sdk_plugin_dispose;
}

static void flutter_ocr_sdk_plugin_init(FlutterOcrSdkPlugin *self)
{
  self->manager = new DlrManager();
}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  FlutterOcrSdkPlugin *plugin = FLUTTER_OCR_SDK_PLUGIN(user_data);
  flutter_ocr_sdk_plugin_handle_method_call(plugin, method_call);
}

void flutter_ocr_sdk_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  FlutterOcrSdkPlugin *plugin = FLUTTER_OCR_SDK_PLUGIN(
      g_object_new(flutter_ocr_sdk_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "flutter_ocr_sdk",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
