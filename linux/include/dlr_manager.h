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

FlValue *CreateLineResultMap(const CTextLineResultItem *result)
{
    FlValue *map = fl_value_new_map();
    fl_value_set_string_take(map, "confidence", fl_value_new_string(result->GetConfidence()));
    fl_value_set_string_take(map, "text", fl_value_new_string(result->GetText()));

    CPoint *points = result->GetLocation().points;

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

    return map;
}

class MyCapturedResultReceiver : public CCapturedResultReceiver
{
public:
    std::vector<CDecodedBarcodesResult *> results;
    std::mutex results_mutex;

    void OnRecognizedTextLinesReceived(CRecognizedTextLinesResult *pResult) override
    {
        pResult->Retain();
        std::lock_guard<std::mutex> lock(results_mutex);
        results.push_back(pResult);
    }
};

class MyImageSourceStateListener : public CImageSourceStateListener
{
private:
    CCaptureVisionRouter *m_router;
    MyCapturedResultReceiver *m_receiver;
    FlMethodCall *m_method_call;

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

    void OnImageSourceStateReceived(ImageSourceState state) override
    {
        if (state == ISS_EXHAUSTED)
        {
            m_router->StopCapturing();

            FlValue *out = fl_value_new_list();

            for (auto *result : m_receiver->results)
            {
                if (!result || result->GetItemsCount() == 0)
                {
                    continue;
                }

                int count = result->GetItemsCount();
                for (int j = 0; j < count; ++j)
                {
                    FlValue *area = fl_value_new_list();
                    const CTextLineResultItem *lineResultItem = result->GetItem(j);
                    fl_value_append_take(area, CreateLineResultMap(lineResultItem));

                    fl_value_append_take(out, area);
                }

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

class DlrManager
{
public:
    ~DlrManager()
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

    int LoadModel(const char *params)
    {
        if (!recognizer)
            return -1;

        memset(modelName, 0, 256);
        strcpy(modelName, params);

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
        char errorMsg[512] = {0};
        int errorCode = cvr->StartCapturing(modelName, false, errorMsg, 512);
        if (errorCode != 0)
        {
            printf("StartCapturing: %s\n", errorMsg);
        }
    }

    FlValue *RecognizeFile(const char *filename)
    {
        printf("RecognizeFile: %s\n", filename);
        capturedReceiver->pendingResults.push_back(std::move(pendingResult));
        fileFetcher->SetFile(filename);
        start();
    }

    FlValue *RecognizeBuffer(unsigned char *buffer, int width, int height, int stride, int format, int length)
    {
        capturedReceiver->pendingResults.push_back(std::move(pendingResult));
        CImageData *imageData = new CImageData(stride * height, buffer, width, height, stride, getPixelFormat(format));
        fileFetcher->SetFile(imageData);
        delete imageData;

        start();
    }

private:
    MyCapturedResultReceiver *capturedReceiver;
    CImageSourceStateListener *listener;
    CFileFetcher *fileFetcher;
    CCaptureVisionRouter *cvr;
    char modelName[256];
};

#endif