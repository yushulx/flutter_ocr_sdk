import Flutter
import UIKit
import DynamsoftCore
import DynamsoftLabelRecognizer 

public class SwiftFlutterOcrSdkPlugin: NSObject, FlutterPlugin, LicenseVerificationListener {
  var completionHandlers: [FlutterResult] = []
  private var recognizer: DynamsoftLabelRecognizer?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_ocr_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterOcrSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  override init() {
    recognizer = DynamsoftLabelRecognizer.init()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments: NSDictionary = call.arguments as! NSDictionary
    switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "init":
            completionHandlers.append(result)
            let license: String = arguments.value(forKey: "key") as! String
        DynamsoftLicenseManager.initLicense(license, verificationDelegate: self)
        case "loadModelFiles":
            let name: String = arguments.value(forKey: "name") as! String
            let prototxtBuffer: FlutterStandardTypedData = arguments.value(forKey: "prototxtBuffer") as! FlutterStandardTypedData
            let txtBuffer: FlutterStandardTypedData = arguments.value(forKey: "txtBuffer") as! FlutterStandardTypedData
            let characterModelBuffer: FlutterStandardTypedData = arguments.value(forKey: "characterModelBuffer") as! FlutterStandardTypedData
            DynamsoftLabelRecognizer.appendCharacterModel(name, prototxtBuffer: prototxtBuffer.data, txtBuffer: txtBuffer.data, characterModelBuffer: characterModelBuffer.data)
            result(0)
        case "loadTemplate":
            if self.recognizer == nil {
                result(.none)
                return
            }
            let params: String = arguments.value(forKey: "template") as! String
            try? self.recognizer!.initRuntimeSettings(params)
            result(0)
        case "recognizeByFile":
            if recognizer == nil {
                result(.none)
                return
            }

            DispatchQueue.global().async {
                let filename: String = arguments.value(forKey: "filename") as! String
                let res = try? self.recognizer!.recognizeFile(filename)
                result(res)
            }
        case "recognizeByBuffer":
            if self.recognizer == nil {
                result(.none)
                return
            }

            DispatchQueue.global().async {
                let buffer: FlutterStandardTypedData = arguments.value(forKey: "bytes") as! FlutterStandardTypedData
                let width: Int = arguments.value(forKey: "width") as! Int
                let height: Int = arguments.value(forKey: "height") as! Int
                let stride: Int = arguments.value(forKey: "stride") as! Int
                let format: Int = arguments.value(forKey: "format") as! Int
                let enumImagePixelFormat = EnumImagePixelFormat(rawValue: format)
                let imageData = iImageData.init()
                imageData.bytes = buffer.data
                imageData.width = width
                imageData.height = height
                imageData.stride = stride
                imageData.format = enumImagePixelFormat!
                let res = try? self.recognizer!.recognizeBuffer(imageData)
                result(res)
            }
        default:
            result(.none)
        }
  }

  public func licenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        if isSuccess {
            completionHandlers.first?(0)
        } else{
            completionHandlers.first?(-1)
        }
    }
}
