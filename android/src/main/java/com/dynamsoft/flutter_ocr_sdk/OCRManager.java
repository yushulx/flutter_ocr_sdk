package com.dynamsoft.flutter_ocr_sdk;

import android.util.Log;
import android.graphics.Point;

import com.dynamsoft.cvr.CapturedResult;
import com.dynamsoft.core.basic_structures.CapturedResultItem;
import com.dynamsoft.cvr.CaptureVisionRouter;
import com.dynamsoft.cvr.SimplifiedCaptureVisionSettings;
import com.dynamsoft.dlr.RecognizedTextLinesResult;
import com.dynamsoft.dlr.TextLineResultItem;
import com.dynamsoft.license.LicenseManager;
import com.dynamsoft.core.basic_structures.ImageData;

import android.content.Context;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;

public class OCRManager {
    private static String TAG = "OCR";
    private CaptureVisionRouter mRouter;
    private String templateName;

    public void init(String license, Context context, final Result result) {
        if (mRouter == null) {
            mRouter = new CaptureVisionRouter(context);
        }

        LicenseManager.initLicense(license, context, (isSuccess, error) -> {
            if (!isSuccess) {
                result.success(-1);
            }
            else {
                result.success(0);
            }
        });
    }

    public ArrayList<ArrayList<HashMap<String, Object>>> recognizeByFile(String fileName) {
        ArrayList<ArrayList<HashMap<String, Object>>> ret = new ArrayList<ArrayList<HashMap<String, Object>>>();
        CapturedResult results = null;
        try {
            results = mRouter.capture(fileName, templateName);
            ret = wrapResults(results);
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return ret;
    }

    public ArrayList<ArrayList<HashMap<String, Object>>> recognizeByBuffer(byte[] bytes, int width, int height, int stride, int format) {
        ArrayList<ArrayList<HashMap<String, Object>>> ret = new ArrayList<ArrayList<HashMap<String, Object>>>();
        CapturedResult results = null;
        ImageData imageData = new ImageData();
        imageData.bytes = bytes;
        imageData.width = width;
        imageData.height = height;
        imageData.stride = stride;
        imageData.format = format;
        try {
            results = mRouter.capture(imageData, templateName);
            ret = wrapResults(results);
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return ret;
    }

    private ArrayList<ArrayList<HashMap<String, Object>>> wrapResults(CapturedResult results) {
        ArrayList<ArrayList<HashMap<String, Object>>> objectList = new ArrayList<ArrayList<HashMap<String, Object>>>();
        if (results != null) {
            CapturedResultItem[] items = results.getItems();
            for (CapturedResultItem item : items) {
                if (item instanceof TextLineResultItem) {
                    ArrayList<HashMap<String, Object>> area = new ArrayList<HashMap<String, Object>>();

                    HashMap<String, Object> data = new HashMap<>();
                    TextLineResultItem lineItem = (TextLineResultItem)item;
                    data.put("confidence", lineItem.getConfidence());
                    data.put("text", lineItem.getText());
                    Point[] points = lineItem.getLocation().points;
                    data.put("x1", points[0].x);
                    data.put("y1", points[0].y);
                    data.put("x2", points[1].x);
                    data.put("y2", points[1].y);
                    data.put("x3", points[2].x);
                    data.put("y3", points[2].y);
                    data.put("x4", points[3].x);
                    data.put("y4", points[3].y);

                    area.add(data);
                    objectList.add(area);
                }
               
            }
        }
        return objectList;
    }

    public void loadModel(String name) {
        templateName = name;
    }
}
