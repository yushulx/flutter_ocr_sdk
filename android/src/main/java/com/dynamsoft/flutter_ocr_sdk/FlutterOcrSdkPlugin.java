package com.dynamsoft.flutter_ocr_sdk;

import androidx.annotation.NonNull;

import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import android.app.Activity;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** FlutterOcrSdkPlugin */
public class FlutterOcrSdkPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private OCRManager mOCRManager;
  private HandlerThread mHandlerThread;
  private Handler mHandler;
  private final Executor mExecutor;
  private FlutterPluginBinding flutterPluginBinding;
  private Activity activity;

  public FlutterOcrSdkPlugin() {
    mOCRManager = new OCRManager();
    mHandler = new Handler(Looper.getMainLooper());
    mExecutor = Executors.newSingleThreadExecutor();
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_ocr_sdk");
    channel.setMethodCallHandler(this);
    this.flutterPluginBinding = flutterPluginBinding;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "init": {
        final String license = call.argument("key");
        mOCRManager.init(license, activity, result);
        break;
      }
      case "recognizeFile": {
        final String filename = call.argument("filename");
        final Result r = result;
        mExecutor.execute(new Runnable() {
          @Override
          public void run() {
            final ArrayList<ArrayList<HashMap<String, Object>>> results = mOCRManager.recognizeFile(filename);
            mHandler.post(new Runnable() {
              @Override
              public void run() {
                r.success(results);
              }
            });

          }
        });
      }
      break;
      case "recognizeBuffer": {
        final byte[] bytes = call.argument("bytes");
        final int width = call.argument("width");
        final int height = call.argument("height");
        final int stride = call.argument("stride");
        final int format = call.argument("format");
        final int rotation = call.argument("rotation");
        final Result r = result;
        mExecutor.execute(new Runnable() {
          @Override
          public void run() {
            final ArrayList<ArrayList<HashMap<String, Object>>> results = mOCRManager.recognizeBuffer(bytes, width, height, stride, format, rotation);
            mHandler.post(new Runnable() {
              @Override
              public void run() {
                r.success(results);
              }
            });

          }
        });
      }
      break;
      case "loadModel": {
        final String name = call.argument("template");
        mOCRManager.loadModel(name);
        result.success(0);
      }
      break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    flutterPluginBinding = null;
  }

  private void bind(ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
    bind(activityPluginBinding);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    bind(activityPluginBinding);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }
}
