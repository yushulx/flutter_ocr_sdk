#ifndef DLR_MANAGER_H_
#define DLR_MANAGER_H_

#include "DynamsoftCore.h"
#include "DynamsoftLabelRecognizer.h"

#include <vector>
#include <iostream>
#include <map>

#include <flutter/standard_method_codec.h>

using namespace std;
using namespace dynamsoft::dlr;

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

class DlrManager
{
public:
    ~DlrManager()
    {
        if (recognizer != NULL)
        {
            DLR_DestroyInstance(recognizer);
            recognizer = NULL;
        }

    };

    int Init(const char *license)
    {
        // Click https://www.dynamsoft.com/customer/license/trialLicense/?product=dlr to get a trial license.
        char errorMsgBuffer[512];
		int ret = DLR_InitLicense(license, errorMsgBuffer, 512);
		printf("DC_InitLicense: %s\n", errorMsgBuffer);
        recognizer = DLR_CreateInstance();
        return ret;
    }

    int LoadModel(const char *modelPath, const char *params)
    {
        if (!recognizer) return -1;

        char errorMessage[256];

        int ret = DLR_AppendSettingsFromString(recognizer, params, errorMessage, 256);
        printf("DLR_InitRuntimeSettings: %s, model path: %s\n", errorMessage, modelPath);
        
        return ret;
    }

    EncodableList RecognizeFile(const char *filename)
    {
        EncodableList out;
        if (recognizer == NULL) return out;

        int ret = DLR_RecognizeByFile(recognizer, filename, "locr");
        if (ret)
		{
			printf("Detection error: %s\n", DLR_GetErrorString(ret));
		}
        return WrapResults();
    }

    EncodableList WrapResults() {
        EncodableList out;
        DLR_ResultArray *pResults = NULL;
		DLR_GetAllResults(recognizer, &pResults);
		if (!pResults)
		{
			return out;
		}

		int count = pResults->resultsCount;

		for (int i = 0; i < count; i++)
		{
            EncodableList area;
			DLR_Result *mrzResult = pResults->results[i];
			int lCount = mrzResult->lineResultsCount;
			for (int j = 0; j < lCount; j++)
			{
                EncodableMap map;

				DM_Point *points = mrzResult->lineResults[j]->location.points;
				int x1 = points[0].x;
				int y1 = points[0].y;
				int x2 = points[1].x;
				int y2 = points[1].y;
				int x3 = points[2].x;
				int y3 = points[2].y;
				int x4 = points[3].x;
				int y4 = points[3].y;

				map[EncodableValue("confidence")] = EncodableValue(mrzResult->lineResults[j]->confidence);
                map[EncodableValue("text")] = EncodableValue(mrzResult->lineResults[j]->text);
                map[EncodableValue("x1")] = EncodableValue(x1);
                map[EncodableValue("y1")] = EncodableValue(y1);
                map[EncodableValue("x2")] = EncodableValue(x2);
                map[EncodableValue("y2")] = EncodableValue(y2);
                map[EncodableValue("x3")] = EncodableValue(x3);
                map[EncodableValue("y3")] = EncodableValue(y3);
                map[EncodableValue("x4")] = EncodableValue(x4);
                map[EncodableValue("y4")] = EncodableValue(y4);
                area.push_back(map);
			}

            out.push_back(area);
		}

		// Release memory
		DLR_FreeResults(&pResults);
        return out;
    }

    EncodableList RecognizeBuffer(unsigned char * buffer, int width, int height, int stride, int format, int length)
    {
        EncodableList out;
        if (recognizer == NULL) return out;
        
        ImagePixelFormat pixelFormat = IPF_BGR_888;
        switch(format) {
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

        ImageData data;
        data.bytes = buffer;
        data.width = width;
        data.height = height;
        data.stride = stride;
        data.format = pixelFormat;
        data.bytesLength = length;

        int ret = DLR_RecognizeByBuffer(recognizer, &data, "locr");
        if (ret)
		{
			printf("Detection error: %s\n", DLR_GetErrorString(ret));
		}

        return WrapResults();
    }

private:
    void *recognizer;
};

#endif