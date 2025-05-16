import DynamsoftMRZScannerBundle

import Flutter

import UIKit

public class SwiftFlutterOcrSdkPlugin: NSObject, FlutterPlugin, LicenseVerificationListener {
    var completionHandlers: [FlutterResult] = []
    let cvr = CaptureVisionRouter()
    var templateName: String = ""

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_ocr_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterOcrSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    override init() {
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments: NSDictionary = call.arguments as! NSDictionary
        switch call.method {
        case "init":
            completionHandlers.append(result)
            let license: String = arguments.value(forKey: "key") as! String
            LicenseManager.initLicense(license, verificationDelegate: self)
        case "loadModel":
            let name: String = arguments.value(forKey: "template") as! String
            templateName = name
            result(0)
        case "recognizeFile":
            DispatchQueue.global().async {
                let filename: String = arguments.value(forKey: "filename") as! String
                let res = self.cvr.captureFromFile(filename, templateName: self.templateName)
                result(self.wrapResults(result: res))
            }
        case "recognizeBuffer":
            DispatchQueue.global().async {
                let buffer: FlutterStandardTypedData =
                    arguments.value(forKey: "bytes") as! FlutterStandardTypedData
                let width: Int = arguments.value(forKey: "width") as! Int
                let height: Int = arguments.value(forKey: "height") as! Int
                let stride: Int = arguments.value(forKey: "stride") as! Int
                let format: Int = arguments.value(forKey: "format") as! Int
                let rotation: Int = arguments.value(forKey: "rotation") as! Int
                let enumImagePixelFormat = ImagePixelFormat(rawValue: format)
                let imageData = ImageData.init()
                imageData.bytes = buffer.data
                imageData.width = UInt(width)
                imageData.height = UInt(height)
                imageData.stride = UInt(stride)
                imageData.format = enumImagePixelFormat!
                imageData.orientation = rotation
                let res = self.cvr.captureFromBuffer(imageData, templateName: self.templateName)
                result(self.wrapResults(result: res))
            }
        default:
            result(.none)
        }
    }

    public func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        if isSuccess {
            completionHandlers.first?(0)
        } else {
            completionHandlers.first?(-1)
        }
    }

    func wrapResults(result: CapturedResult) -> NSArray {
        let outResults = NSMutableArray()
        let tmp = NSMutableArray()
        let items = result.items

        if items != nil && items!.count > 0 {
            let subDic = NSMutableDictionary()
            for item in items! {
                if item.type == .textLine {
                    guard let lineItem = item as? TextLineResultItem,
                        let points = lineItem.location.points as? [CGPoint], points.count >= 4
                    else {
                        continue
                    }

                    subDic["confidence"] = lineItem.confidence
                    subDic["text"] = lineItem.text

                    for (i, point) in points.prefix(4).enumerated() {
                        subDic["x\(i + 1)"] = Int(point.x)
                        subDic["y\(i + 1)"] = Int(point.y)
                    }

                } else if item.type == .parsedResult {
                    let parsedItem: ParsedResultItem = item as! ParsedResultItem
                    let parsedFields = parsedItem.parsedFields

                    if templateName == "ReadVINText" {
                        subDic["type"] = "VIN"

                        let vinString = parsedFields["vinString"] ?? "N/A"
                        let wmi = parsedFields["WMI"] ?? "N/A"
                        let region = parsedFields["region"] ?? "N/A"
                        let vds = parsedFields["VDS"] ?? "N/A"
                        let checkDigit = parsedFields["checkDigit"] ?? "N/A"
                        let modelYear = parsedFields["modelYear"] ?? "N/A"
                        let plantCode = parsedFields["plantCode"] ?? "N/A"
                        let serialNumber = parsedFields["serialNumber"] ?? "N/A"

                        subDic["vinString"] = vinString
                        subDic["wmi"] = wmi
                        subDic["region"] = region
                        subDic["vds"] = vds
                        subDic["checkDigit"] = checkDigit
                        subDic["modelYear"] = modelYear
                        subDic["plantCode"] = plantCode
                        subDic["serialNumber"] = serialNumber

                    } else {
                        subDic["type"] = "MRZ"

                        let docType = parsedItem.codeType
                        let docNumber: String = {
                            switch docType {
                            case "MRTD_TD1_ID":
                                return parsedFields["documentNumber"] ?? parsedFields[
                                    "longDocumentNumber"] ?? "N/A"
                            case "MRTD_TD2_ID", "MRTD_TD2_FRENCH_ID":
                                return parsedFields["documentNumber"] ?? "N/A"
                            case "MRTD_TD3_PASSPORT":
                                return parsedFields["passportNumber"] ?? "N/A"
                            default:
                                return "N/A"
                            }
                        }()

                        let nationality = parsedFields["nationality"] ?? "N/A"
                        let issuingCountry = parsedFields["issuingState"] ?? "N/A"
                        let givenName = parsedFields["secondaryIdentifier"] ?? "N/A"
                        let surname = parsedFields["primaryIdentifier"].map { " \($0)" } ?? "N/A"
                        let sex = parsedFields["sex"] ?? "N/A"
                        let dateOfBirth = parsedFields["dateOfBirth"] ?? "N/A"
                        let dateOfExpire = parsedFields["dateOfExpiry"] ?? "N/A"

                        let mrzText = [
                            parsedFields["line1"], parsedFields["line2"], parsedFields["line3"],
                        ]
                        .compactMap { $0 }
                        .joined(separator: "\n")

                        subDic["docType"] = docType
                        subDic["nationality"] = nationality
                        subDic["surname"] = surname
                        subDic["givenName"] = givenName
                        subDic["docNumber"] = docNumber
                        subDic["issuingCountry"] = issuingCountry
                        subDic["birthDate"] = dateOfBirth
                        subDic["gender"] = sex
                        subDic["expiration"] = dateOfExpire
                        subDic["mrzString"] = mrzText
                    }
                } else {
                    subDic["type"] = "unknown"
                }
            }
            tmp.add(subDic)
        }

        outResults.add(tmp)

        return outResults
    }
}
