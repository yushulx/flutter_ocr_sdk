#ifndef DLR_MANAGER_H_
#define DLR_MANAGER_H_

#include <vector>
#include <iostream>
#include <map>

#include <flutter/standard_method_codec.h>

#include <thread>
#include <condition_variable>
#include <mutex>
#include <queue>
#include <functional>

#include "DynamsoftCaptureVisionRouter.h"
#include "DynamsoftUtility.h"

using namespace std;
using namespace dynamsoft::license;
using namespace dynamsoft::cvr;
using namespace dynamsoft::dlr;
using namespace dynamsoft::utility;
using namespace dynamsoft::basic_structures;
using namespace dynamsoft::dcp;

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

// Define as inline to avoid multiple definition errors
inline void printf_to_cerr(const char *format, ...)
{
    char buffer[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(buffer, sizeof(buffer), format, args);
    va_end(args);
    std::cerr << buffer;
}

// Define printf to use our custom function
#define printf printf_to_cerr

class MyCapturedResultReceiver : public CCapturedResultReceiver
{
public:
    vector<CRecognizedTextLinesResult *> results;
    vector<std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>> pendingResults = {};
    EncodableList out;
    string modelName;

public:
    void SetModelName(string &name)
    {
        modelName = name;
    }

    void OnCapturedResultReceived(CCapturedResult *pResult) override
    {
        WrapResults(pResult);
    }
    void OnRecognizedTextLinesReceived(CRecognizedTextLinesResult *pResult) override
    {
        // WrapResults(pResult);
    }

    void sendResult()
    {
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result = std::move(pendingResults.front());
        pendingResults.erase(pendingResults.begin());
        result->Success(out);
        out.clear();
    }

    void WrapResults(CCapturedResult *capturedResult)
    {
        EncodableList area;
        if (!capturedResult)
        {
            out.push_back(area);
            return;
        }

        CParsedResult *dcpResult = capturedResult->GetParsedResult();
        if (dcpResult == NULL || dcpResult->GetItemsCount() == 0)
        {
            out.push_back(area);
            return;
        }

        CRecognizedTextLinesResult *pResults = capturedResult->GetRecognizedTextLinesResult();

        int count = pResults->GetItemsCount();

        for (int i = 0; i < count; i++)
        {
            const CTextLineResultItem *result = pResults->GetItem(i);
            CPoint *points = result->GetLocation().points;

            int x1 = points[0][0];
            int y1 = points[0][1];
            int x2 = points[1][0];
            int y2 = points[1][1];
            int x3 = points[2][0];
            int y3 = points[2][1];
            int x4 = points[3][0];
            int y4 = points[3][1];

            EncodableMap map;
            map[EncodableValue("confidence")] = EncodableValue(result->GetConfidence());
            map[EncodableValue("text")] = EncodableValue(result->GetText());
            map[EncodableValue("x1")] = EncodableValue(x1);
            map[EncodableValue("y1")] = EncodableValue(y1);
            map[EncodableValue("x2")] = EncodableValue(x2);
            map[EncodableValue("y2")] = EncodableValue(y2);
            map[EncodableValue("x3")] = EncodableValue(x3);
            map[EncodableValue("y3")] = EncodableValue(y3);
            map[EncodableValue("x4")] = EncodableValue(x4);
            map[EncodableValue("y4")] = EncodableValue(y4);

            const CParsedResultItem *item = dcpResult->GetItem(i);
            if (modelName == "ReadVINText")
            {
                map[EncodableValue("type")] = EncodableValue("VIN");

                string vinstring;
                string wmi;
                string region;
                string vds;
                string checkDigit;
                string modelYear;
                string plantCode;
                string serialNumber;

                if (item->GetFieldValidationStatus("vinString") != VS_FAILED && item->GetFieldValue("vinString") != NULL)
                {
                    vinstring = item->GetFieldValue("vinString");
                }

                if (item->GetFieldValidationStatus("WMI") != VS_FAILED && item->GetFieldValue("WMI") != NULL)
                {
                    wmi = item->GetFieldValue("WMI");
                }

                if (item->GetFieldValidationStatus("region") != VS_FAILED && item->GetFieldValue("region") != NULL)
                {
                    region = item->GetFieldValue("region");
                }

                if (item->GetFieldValidationStatus("VDS") != VS_FAILED && item->GetFieldValue("VDS") != NULL)
                {
                    vds = item->GetFieldValue("VDS");
                }

                if (item->GetFieldValidationStatus("checkDigit") != VS_FAILED && item->GetFieldValue("checkDigit") != NULL)
                {
                    checkDigit = item->GetFieldValue("checkDigit");
                }

                if (item->GetFieldValidationStatus("modelYear") != VS_FAILED && item->GetFieldValue("modelYear") != NULL)
                {
                    modelYear = item->GetFieldValue("modelYear");
                }

                if (item->GetFieldValidationStatus("plantCode") != VS_FAILED && item->GetFieldValue("plantCode") != NULL)
                {
                    plantCode = item->GetFieldValue("plantCode");
                }

                if (item->GetFieldValidationStatus("serialNumber") != VS_FAILED && item->GetFieldValue("serialNumber") != NULL)
                {
                    serialNumber = item->GetFieldValue("serialNumber");
                }

                map[EncodableValue("vinString")] = EncodableValue(vinstring);
                map[EncodableValue("wmi")] = EncodableValue(wmi);
                map[EncodableValue("region")] = EncodableValue(region);
                map[EncodableValue("vds")] = EncodableValue(vds);
                map[EncodableValue("checkDigit")] = EncodableValue(checkDigit);
                map[EncodableValue("modelYear")] = EncodableValue(modelYear);
                map[EncodableValue("plantCode")] = EncodableValue(plantCode);
                map[EncodableValue("serialNumber")] = EncodableValue(serialNumber);
            }
            else
            {
                map[EncodableValue("type")] = EncodableValue("MRZ");

                string docId;
                string docType;
                string nationality;
                string issuer;
                string dateOfBirth;
                string dateOfExpiry;
                string gender;
                string surname;
                string givenname;
                string rawText;

                docType = item->GetCodeType();

                if (docType == "MRTD_TD3_PASSPORT")
                {
                    if (item->GetFieldValidationStatus("passportNumber") != VS_FAILED && item->GetFieldValue("passportNumber") != NULL)
                    {
                        docId = item->GetFieldValue("passportNumber");
                    }
                }
                else if (item->GetFieldValidationStatus("documentNumber") != VS_FAILED && item->GetFieldValue("documentNumber") != NULL)
                {
                    docId = item->GetFieldValue("documentNumber");
                }

                string line;
                if (docType == "MRTD_TD1_ID")
                {
                    if (item->GetFieldValue("line1") != NULL)
                    {
                        line = item->GetFieldValue("line1");
                        if (item->GetFieldValidationStatus("line1") == VS_FAILED)
                        {
                            line += ", Validation Failed";
                        }
                        rawText += line + "\n";
                    }

                    if (item->GetFieldValue("line2") != NULL)
                    {
                        line = item->GetFieldValue("line2");
                        if (item->GetFieldValidationStatus("line2") == VS_FAILED)
                        {
                            line += ", Validation Failed";
                        }
                        rawText += line + "\n";
                    }

                    if (item->GetFieldValue("line3") != NULL)
                    {
                        line = item->GetFieldValue("line3");
                        if (item->GetFieldValidationStatus("line3") == VS_FAILED)
                        {
                            line += ", Validation Failed";
                        }
                        rawText += line + "\n";
                    }
                }
                else
                {
                    if (item->GetFieldValue("line1") != NULL)
                    {
                        line = item->GetFieldValue("line1");
                        if (item->GetFieldValidationStatus("line1") == VS_FAILED)
                        {
                            line += ", Validation Failed";
                        }
                        rawText += line + "\n";
                    }

                    if (item->GetFieldValue("line2") != NULL)
                    {
                        line = item->GetFieldValue("line2");
                        if (item->GetFieldValidationStatus("line2") == VS_FAILED)
                        {
                            line += ", Validation Failed";
                        }
                        rawText += line + "\n";
                    }
                }

                if (item->GetFieldValidationStatus("nationality") != VS_FAILED && item->GetFieldValue("nationality") != NULL)
                {
                    nationality = item->GetFieldValue("nationality");
                }
                if (item->GetFieldValidationStatus("issuingState") != VS_FAILED && item->GetFieldValue("issuingState") != NULL)
                {
                    issuer = item->GetFieldValue("issuingState");
                }
                if (item->GetFieldValidationStatus("dateOfBirth") != VS_FAILED && item->GetFieldValue("dateOfBirth") != NULL)
                {
                    dateOfBirth = item->GetFieldValue("dateOfBirth");
                }
                if (item->GetFieldValidationStatus("dateOfExpiry") != VS_FAILED && item->GetFieldValue("dateOfExpiry") != NULL)
                {
                    dateOfExpiry = item->GetFieldValue("dateOfExpiry");
                }
                if (item->GetFieldValidationStatus("sex") != VS_FAILED && item->GetFieldValue("sex") != NULL)
                {
                    gender = item->GetFieldValue("sex");
                }
                if (item->GetFieldValidationStatus("primaryIdentifier") != VS_FAILED && item->GetFieldValue("primaryIdentifier") != NULL)
                {
                    surname = item->GetFieldValue("primaryIdentifier");
                }
                if (item->GetFieldValidationStatus("secondaryIdentifier") != VS_FAILED && item->GetFieldValue("secondaryIdentifier") != NULL)
                {
                    givenname = item->GetFieldValue("secondaryIdentifier");
                }

                map[EncodableValue("docType")] = EncodableValue(docType);
                map[EncodableValue("nationality")] = EncodableValue(nationality);
                map[EncodableValue("surname")] = EncodableValue(surname);
                map[EncodableValue("givenName")] = EncodableValue(givenname);
                map[EncodableValue("docNumber")] = EncodableValue(docId);
                map[EncodableValue("issuingCountry")] = EncodableValue(issuer);
                map[EncodableValue("birthDate")] = EncodableValue(dateOfBirth);
                map[EncodableValue("gender")] = EncodableValue(gender);
                map[EncodableValue("expiration")] = EncodableValue(dateOfExpiry);
                map[EncodableValue("mrzString")] = EncodableValue(rawText);
            }

            area.push_back(map);

            out.push_back(area);
        }
    }
};

class MyImageSourceStateListener : public CImageSourceStateListener
{
private:
    CCaptureVisionRouter *m_router;
    MyCapturedResultReceiver *m_receiver;

public:
    MyImageSourceStateListener(CCaptureVisionRouter *router, MyCapturedResultReceiver *receiver)
    {
        m_router = router;
        m_receiver = receiver;
    }

    void OnImageSourceStateReceived(ImageSourceState state)
    {
        if (state == ISS_EXHAUSTED)
        {
            m_router->StopCapturing();
            m_receiver->sendResult();
        }
    }
};

class CaptureVisionManager
{
public:
    ~CaptureVisionManager()
    {
        if (cvr != NULL)
        {
            delete cvr;
            cvr = NULL;
        }

        if (listener)
        {
            delete listener;
            listener = NULL;
        }

        if (fileFetcher)
        {
            delete fileFetcher;
            fileFetcher = NULL;
        }

        if (capturedReceiver)
        {
            delete capturedReceiver;
            capturedReceiver = NULL;
        }
    };

    int Init(const char *license)
    {
        // Click https://www.dynamsoft.com/customer/license/trialLicense/?product=dcv&package=cross-platform to get a trial license.
        char errorMsgBuffer[512];
        int ret = CLicenseManager::InitLicense(license, errorMsgBuffer, 512);
        printf("InitLicense: %s\n", errorMsgBuffer);

        if (ret) return ret;

        cvr = new CCaptureVisionRouter;

        fileFetcher = new CFileFetcher();
        ret = cvr->SetInput(fileFetcher);
        if (ret)
        {
            printf("SetInput error: %d\n", ret);
        }

        capturedReceiver = new MyCapturedResultReceiver;
        ret = cvr->AddResultReceiver(capturedReceiver);
        if (ret)
        {
            printf("AddResultReceiver error: %d\n", ret);
        }

        listener = new MyImageSourceStateListener(cvr, capturedReceiver);
        ret = cvr->AddImageSourceStateListener(listener);
        if (ret)
        {
            printf("AddImageSourceStateListener error: %d\n", ret);
        }

        return ret;
    }

    int LoadModel(string &name)
    {
        if (!cvr)
            return -1;

        modelName = name;

        if (capturedReceiver)
        {
            capturedReceiver->SetModelName(modelName);
        }

        return 0;
    }

    ImagePixelFormat getPixelFormat(int format)
    {
        ImagePixelFormat pixelFormat = IPF_BGR_888;
        switch (format)
        {
        case 0:
            pixelFormat = IPF_BINARY;
            break;
        case 1:
            pixelFormat = IPF_BINARYINVERTED;
            break;
        case 2:
            pixelFormat = IPF_GRAYSCALED;
            break;
        case 3:
            pixelFormat = IPF_NV21;
            break;
        case 4:
            pixelFormat = IPF_RGB_565;
            break;
        case 5:
            pixelFormat = IPF_RGB_555;
            break;
        case 6:
            pixelFormat = IPF_RGB_888;
            break;
        case 7:
            pixelFormat = IPF_ARGB_8888;
            break;
        case 8:
            pixelFormat = IPF_RGB_161616;
            break;
        case 9:
            pixelFormat = IPF_ARGB_16161616;
            break;
        case 10:
            pixelFormat = IPF_ABGR_8888;
            break;
        case 11:
            pixelFormat = IPF_ABGR_16161616;
            break;
        case 12:
            pixelFormat = IPF_BGR_888;
            break;
        }

        return pixelFormat;
    }

    void start()
    {
        if (!cvr)
            return;

        char errorMsg[512] = {0};
        int errorCode = cvr->StartCapturing(modelName.c_str(), false, errorMsg, 512);
        if (errorCode != 0)
        {
            printf("StartCapturing: %s\n", errorMsg);
        }
    }

    void RecognizeFile(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> &pendingResult, const char *filename)
    {
        if (!cvr) {
            EncodableList out;
            EncodableList area;
            out.push_back(area);
            pendingResult->Success(out);
            return;
        } 

        printf("RecognizeFile: %s\n", filename);
        capturedReceiver->pendingResults.push_back(std::move(pendingResult));
        fileFetcher->SetFile(filename);
        start();
    }

    void RecognizeBuffer(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> &pendingResult, const unsigned char *buffer, int width, int height, int stride, int format, int rotation)
    {
        if (!cvr) {
            EncodableList out;
            EncodableList area;
            out.push_back(area);
            pendingResult->Success(out);
            return;
        } 

        capturedReceiver->pendingResults.push_back(std::move(pendingResult));
        CImageData *imageData = new CImageData(stride * height, buffer, width, height, stride, getPixelFormat(format), rotation);
        fileFetcher->SetFile(imageData);
        delete imageData;

        start();
    }

private:
    MyCapturedResultReceiver *capturedReceiver;
    MyImageSourceStateListener *listener;
    CFileFetcher *fileFetcher;
    CCaptureVisionRouter *cvr;
    string modelName;
};

#endif