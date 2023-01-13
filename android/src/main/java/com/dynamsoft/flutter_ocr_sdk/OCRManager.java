package com.dynamsoft.flutter_ocr_sdk;

import android.util.Log;

import com.dynamsoft.core.ImageData;
import com.dynamsoft.core.CoreException;
import com.dynamsoft.core.LicenseManager;
import com.dynamsoft.core.LicenseVerificationListener;
import com.dynamsoft.dlr.LabelRecognizer;
import com.dynamsoft.dlr.DLRResult;
import com.dynamsoft.dlr.DLRLineResult;

import android.content.Context;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel.Result;

public class OCRManager {
    private static String TAG = "OCR";
    private LabelRecognizer mLabelRecognizer;

    public OCRManager() {
        try {
            mLabelRecognizer = new LabelRecognizer();
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public void init(String license, Context context, final Result result) {
        LicenseManager.initLicense(
            license, context,
                new LicenseVerificationListener() {
                    @Override
                    public void licenseVerificationCallback(boolean isSuccessful, CoreException e) {
                        if (isSuccessful)
                        {
                            result.success(0);
                        }
                        else {
                            result.success(-1);
                        }
                    }
                });
    }

    public ArrayList<ArrayList<HashMap<String, Object>>> recognizeByFile(String fileName) {
        ArrayList<ArrayList<HashMap<String, Object>>> ret = new ArrayList<ArrayList<HashMap<String, Object>>>();
        DLRResult[] results = null;
        try {
            results = mLabelRecognizer.recognizeFile(fileName);
            ret = wrapResults(results);
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return ret;
    }

    public ArrayList<ArrayList<HashMap<String, Object>>> recognizeByBuffer(byte[] bytes, int width, int height, int stride, int format) {
        ArrayList<ArrayList<HashMap<String, Object>>> ret = new ArrayList<ArrayList<HashMap<String, Object>>>();
        DLRResult[] results = null;
        ImageData data = new ImageData();
        data.bytes = bytes;
        data.width = width;
        data.height = height;
        data.stride = stride;
        data.format = format;
        try {
            results = mLabelRecognizer.recognizeBuffer(data);
            ret = wrapResults(results);
        } catch (Exception e) {
            Log.e(TAG, e.toString());
        }
        return ret;
    }

    private ArrayList<ArrayList<HashMap<String, Object>>> wrapResults(DLRResult[] results) {
        ArrayList<ArrayList<HashMap<String, Object>>> objectList = new ArrayList<ArrayList<HashMap<String, Object>>>();
        if (results != null) {
            try {
                for (DLRResult result : results) {
                    ArrayList<HashMap<String, Object>> area = new ArrayList<HashMap<String, Object>>();
                    
                    DLRLineResult[] lineResults = result.lineResults;
                    for (DLRLineResult lineResult : lineResults) {
                        HashMap<String, Object> line = new HashMap<>();

                        line.put("confidence", lineResult.confidence);
                        line.put("text", lineResult.text);
                        line.put("x1", lineResult.location.points[0].x);
                        line.put("y1", lineResult.location.points[0].y);
                        line.put("x2", lineResult.location.points[1].x);
                        line.put("y2", lineResult.location.points[1].y);
                        line.put("x3", lineResult.location.points[2].x);
                        line.put("y3", lineResult.location.points[2].y);
                        line.put("x4", lineResult.location.points[3].x);
                        line.put("y4", lineResult.location.points[3].y);
                        
                        area.add(line);
                    }

                    objectList.add(area);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return objectList;
    }

    public void loadModelFiles(String name, byte[] prototxtBuffer, byte[] txtBuffer, byte[] characterModelBuffer) {
        try {
            mLabelRecognizer.appendCharacterModelBuffer(name, prototxtBuffer, txtBuffer, characterModelBuffer);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void loadTemplate(String content) {
        try {
            mLabelRecognizer.initRuntimeSettings(content);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
