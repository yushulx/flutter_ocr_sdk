import DynamsoftBarcodeReader

import DynamsoftCaptureVisionRouter

import DynamsoftCore

import DynamsoftLicense

import Flutter

import UIKit

public class SwiftFlutterOcrSdkPlugin: NSObject, FlutterPlugin, LicenseVerificationListener {
    var completionHandlers: [FlutterResult] = []
    let cvr = CaptureVisionRouter()
    var templateName: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_ocr_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterOcrSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    override init() {
        recognizer = DynamsoftLabelRecognizer.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments: NSDictionary = call.arguments as! NSDictionary
        switch call.method {
        case "init":
            completionHandlers.append(result)
            let license: String = arguments.value(forKey: "key") as! String
            DynamsoftLicenseManager.initLicense(license, verificationDelegate: self)
        case "loadModel":
            let name: String = arguments.value(forKey: "template") as! String
            templateName = name
            result(0)
        case "recognizeByFile":
            if recognizer == nil {
                result(.none)
                return
            }

            DispatchQueue.global().async {
                let filename: String = arguments.value(forKey: "filename") as! String
                let res = try? self.recognizer!.recognizeFile(filename)
                result(self.wrapResults(results: res))
            }
        case "recognizeByBuffer":
            if self.recognizer == nil {
                result(.none)
                return
            }

            DispatchQueue.global().async {
                let buffer: FlutterStandardTypedData =
                    arguments.value(forKey: "bytes") as! FlutterStandardTypedData
                let width: Int = arguments.value(forKey: "width") as! Int
                let height: Int = arguments.value(forKey: "height") as! Int
                let stride: Int = arguments.value(forKey: "stride") as! Int
                let format: Int = arguments.value(forKey: "format") as! Int
                let rotation: Int = arguments.value(forKey: "rotation") as! Int
                let enumImagePixelFormat = EnumImagePixelFormat(rawValue: format)
                let imageData = iImageData.init()
                imageData.bytes = buffer.data
                imageData.width = width
                imageData.height = height
                imageData.stride = stride
                imageData.format = enumImagePixelFormat!
                let res = try? self.recognizer!.recognizeBuffer(imageData)
                result(self.wrapResults(results: res))
            }
        default:
            result(.none)
        }
    }

    public func licenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        if isSuccess {
            completionHandlers.first?(0)
        } else {
            completionHandlers.first?(-1)
        }
    }

    func wrapResults(results: [iDLRResult]?) -> NSArray {
        let outResults = NSMutableArray()
        if results == nil {
            return outResults
        }
        for item in results! {
            let area = NSMutableArray()

            for line in item.lineResults! {
                let dictionary = NSMutableDictionary()
                dictionary.setObject(line.confidence, forKey: "confidence" as NSCopying)
                dictionary.setObject(line.text ?? "", forKey: "text" as NSCopying)

                let points = line.location!.points as! [CGPoint]
                dictionary.setObject(Int(points[0].x), forKey: "x1" as NSCopying)
                dictionary.setObject(Int(points[0].y), forKey: "y1" as NSCopying)
                dictionary.setObject(Int(points[1].x), forKey: "x2" as NSCopying)
                dictionary.setObject(Int(points[1].y), forKey: "y2" as NSCopying)
                dictionary.setObject(Int(points[2].x), forKey: "x3" as NSCopying)
                dictionary.setObject(Int(points[2].y), forKey: "y3" as NSCopying)
                dictionary.setObject(Int(points[3].x), forKey: "x4" as NSCopying)
                dictionary.setObject(Int(points[3].y), forKey: "y4" as NSCopying)

                area.add(dictionary)
            }
            outResults.add(area)
        }

        return outResults
    }
}
