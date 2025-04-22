#ifndef DLR_MANAGER_H_
#define DLR_MANAGER_H_

#include "DynamsoftCaptureVisionRouter.h"
#include "DynamsoftUtility.h"

#include <vector>
#include <iostream>
#include <map>
#include <mutex>

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

using namespace std;
using namespace dynamsoft::license;
using namespace dynamsoft::cvr;
using namespace dynamsoft::dlr;
using namespace dynamsoft::utility;
using namespace dynamsoft::basic_structures;
using namespace dynamsoft::dcp;

class MyCapturedResultReceiver : public CCapturedResultReceiver
{
public:
    std::vector<CCapturedResult *> results;
    std::mutex results_mutex;

    void OnCapturedResultReceived(CCapturedResult *pResult) override
    {
        pResult->Retain();
        std::lock_guard<std::mutex> lock(results_mutex);
        results.push_back(pResult);
    }

    void OnRecognizedTextLinesReceived(CRecognizedTextLinesResult *pResult) override
    {
        // pResult->Retain();
        // std::lock_guard<std::mutex> lock(results_mutex);
        // results.push_back(pResult);
    }
};

class MyImageSourceStateListener : public CImageSourceStateListener
{
private:
    CCaptureVisionRouter *m_router;
    MyCapturedResultReceiver *m_receiver;
    FlMethodCall *m_method_call;
    string modelName;

public:
    MyImageSourceStateListener(CCaptureVisionRouter *router, MyCapturedResultReceiver *receiver)
        : m_router(router), m_receiver(receiver), m_method_call(nullptr) {}

    ~MyImageSourceStateListener()
    {
        if (m_method_call)
        {
            g_object_unref(m_method_call);
        }
    }

    FlValue *WrapResults(const CCapturedResult *capturedResult)
    {
        FlValue *map = fl_value_new_map();

        CParsedResult *dcpResult = capturedResult->GetParsedResult();
        if (dcpResult == NULL || dcpResult->GetItemsCount() == 0)
        {
            return map;
        }

        CRecognizedTextLinesResult *pResults = capturedResult->GetRecognizedTextLinesResult();

        int count = pResults->GetItemsCount();

        for (int i = 0; i < count; i++)
        {
            const CTextLineResultItem *result = pResults->GetItem(i);

            fl_value_set_string_take(map, "confidence", fl_value_new_int(result->GetConfidence()));
            fl_value_set_string_take(map, "text", fl_value_new_string(result->GetText()));

            CQuadrilateral location = result->GetLocation();
            CPoint *points = location.points;

            int x1 = points[0][0];
            int y1 = points[0][1];
            int x2 = points[1][0];
            int y2 = points[1][1];
            int x3 = points[2][0];
            int y3 = points[2][1];
            int x4 = points[3][0];
            int y4 = points[3][1];

            fl_value_set_string_take(map, "x1", fl_value_new_int(x1));
            fl_value_set_string_take(map, "y1", fl_value_new_int(y1));
            fl_value_set_string_take(map, "x2", fl_value_new_int(x2));
            fl_value_set_string_take(map, "y2", fl_value_new_int(y2));
            fl_value_set_string_take(map, "x3", fl_value_new_int(x3));
            fl_value_set_string_take(map, "y3", fl_value_new_int(y3));
            fl_value_set_string_take(map, "x4", fl_value_new_int(x4));
            fl_value_set_string_take(map, "y4", fl_value_new_int(y4));

            const CParsedResultItem *item = dcpResult->GetItem(i);
            if (modelName == "ReadVINText")
            {
                fl_value_set_string_take(map, "type", fl_value_new_string("VIN"));

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

                fl_value_set_string_take(map, "vinString", fl_value_new_string(vinstring.c_str()));
                fl_value_set_string_take(map, "wmi", fl_value_new_string(wmi.c_str()));
                fl_value_set_string_take(map, "region", fl_value_new_string(region.c_str()));
                fl_value_set_string_take(map, "vds", fl_value_new_string(vds.c_str()));
                fl_value_set_string_take(map, "checkDigit", fl_value_new_string(checkDigit.c_str()));
                fl_value_set_string_take(map, "modelYear", fl_value_new_string(modelYear.c_str()));
                fl_value_set_string_take(map, "plantCode", fl_value_new_string(plantCode.c_str()));
                fl_value_set_string_take(map, "serialNumber", fl_value_new_string(serialNumber.c_str()));
            }
            else
            {
                fl_value_set_string_take(map, "type", fl_value_new_string("MRZ"));

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

                fl_value_set_string_take(map, "docType", fl_value_new_string(docType.c_str()));
                fl_value_set_string_take(map, "nationality", fl_value_new_string(nationality.c_str()));
                fl_value_set_string_take(map, "surname", fl_value_new_string(surname.c_str()));
                fl_value_set_string_take(map, "givenName", fl_value_new_string(givenname.c_str()));
                fl_value_set_string_take(map, "docNumber", fl_value_new_string(docId.c_str()));
                fl_value_set_string_take(map, "issuingCountry", fl_value_new_string(issuer.c_str()));
                fl_value_set_string_take(map, "birthDate", fl_value_new_string(dateOfBirth.c_str()));
                fl_value_set_string_take(map, "gender", fl_value_new_string(gender.c_str()));
                fl_value_set_string_take(map, "expiration", fl_value_new_string(dateOfExpiry.c_str()));
                fl_value_set_string_take(map, "mrzString", fl_value_new_string(rawText.c_str()));
            }
        }

        return map;
    }

    void SetModelName(string &name)
    {
        modelName = name;
    }

    void OnImageSourceStateReceived(ImageSourceState state) override
    {
        if (state == ISS_EXHAUSTED)
        {
            m_router->StopCapturing();

            FlValue *out = fl_value_new_list();

            for (auto *result : m_receiver->results)
            {
                FlValue *area = fl_value_new_list();
                fl_value_append_take(area, WrapResults(result));

                fl_value_append_take(out, area);

                result->Release();
            }

            m_receiver->results.clear();

            g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(out));
            if (m_method_call)
            {
                fl_method_call_respond(m_method_call, response, nullptr);
                g_object_unref(m_method_call); // Release the method call
                m_method_call = nullptr;
            }
        }
    }

    void SetMethodCall(FlMethodCall *method_call)
    {
        if (m_method_call)
        {
            g_object_unref(m_method_call);
        }
        m_method_call = method_call;
        if (m_method_call)
        {
            g_object_ref(m_method_call); // Retain the method call
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

        if (listener)
        {
            listener->SetModelName(modelName);
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

    void RecognizeFile(FlMethodCall *method_call, const char *filename)
    {
        if (!cvr) {
            FlValue *out = fl_value_new_list();
            FlValue *area = fl_value_new_list();
            fl_value_append_take(out, area);
            g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(out));
            fl_method_call_respond(method_call, response, nullptr);
            return;
        }
        printf("RecognizeFile: %s\n", filename);
        fileFetcher->SetFile(filename);
        listener->SetMethodCall(method_call);
        start();
    }

    void RecognizeBuffer(FlMethodCall *method_call, unsigned char *buffer, int width, int height, int stride, int format, int length, int rotation)
    {
        if (!cvr) {
            FlValue *out = fl_value_new_list();
            FlValue *area = fl_value_new_list();
            fl_value_append_take(out, area);
            g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(fl_method_success_response_new(out));
            fl_method_call_respond(method_call, response, nullptr);
            return;
        }

        CImageData *imageData = new CImageData(stride * height, buffer, width, height, stride, getPixelFormat(format), rotation);
        fileFetcher->SetFile(imageData);
        delete imageData;
        listener->SetMethodCall(method_call);
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