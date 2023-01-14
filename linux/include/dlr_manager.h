#ifndef DLR_MANAGER_H_
#define DLR_MANAGER_H_

#include "DynamsoftCore.h"
#include "DynamsoftLabelRecognizer.h"

#include <vector>
#include <iostream>
#include <map>

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

using namespace std;
using namespace dynamsoft::dlr;

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

    FlValue* RecognizeFile(const char *filename)
    {
        FlValue* out = fl_value_new_list();
        if (recognizer == NULL) return out;

        int ret = DLR_RecognizeByFile(recognizer, filename, "locr");
        if (ret)
		{
			printf("Detection error: %s\n", DLR_GetErrorString(ret));
		}
        return WrapResults();
    }

    FlValue* WrapResults() {
        FlValue* out = fl_value_new_list();
        DLR_ResultArray *pResults = NULL;
		DLR_GetAllResults(recognizer, &pResults);
		if (!pResults)
		{
			return out;
		}

		int count = pResults->resultsCount;

		for (int i = 0; i < count; i++)
		{
            FlValue* area = fl_value_new_list();
			DLR_Result *mrzResult = pResults->results[i];
			int lCount = mrzResult->lineResultsCount;
			for (int j = 0; j < lCount; j++)
			{
                FlValue* lineInfo = fl_value_new_map ();

				DM_Point *points = mrzResult->lineResults[j]->location.points;
				int x1 = points[0].x;
				int y1 = points[0].y;
				int x2 = points[1].x;
				int y2 = points[1].y;
				int x3 = points[2].x;
				int y3 = points[2].y;
				int x4 = points[3].x;
				int y4 = points[3].y;

                fl_value_set_string_take (lineInfo, "confidence", fl_value_new_int(mrzResult->confidence));
                fl_value_set_string_take (lineInfo, "text", fl_value_new_string(mrzResult->lineResults[j]->text));
                fl_value_set_string_take (lineInfo, "x1", fl_value_new_int(x1));
                fl_value_set_string_take (lineInfo, "y1", fl_value_new_int(y1));
                fl_value_set_string_take (lineInfo, "x2", fl_value_new_int(x2));
                fl_value_set_string_take (lineInfo, "y2", fl_value_new_int(y2));
                fl_value_set_string_take (lineInfo, "x3", fl_value_new_int(x3));
                fl_value_set_string_take (lineInfo, "y3", fl_value_new_int(y3));
                fl_value_set_string_take (lineInfo, "x4", fl_value_new_int(x4));
                fl_value_set_string_take (lineInfo, "y4", fl_value_new_int(y4));

                fl_value_append_take (area, lineInfo);
			}

            fl_value_append_take(out, area);
		}

		// Release memory
		DLR_FreeResults(&pResults);
        return out;
    }

    FlValue* RecognizeBuffer(unsigned char * buffer, int width, int height, int stride, int format, int length)
    {
        FlValue* out = fl_value_new_list();
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