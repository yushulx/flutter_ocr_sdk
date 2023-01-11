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

import org.json.JSONArray;
import org.json.JSONObject;

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

    public String recognizeByFile(String fileName) {
        JSONObject ret = new JSONObject();
        DLRResult[] results = null;
        try {
            results = mLabelRecognizer.recognizeFile(fileName);
            ret = wrapResults(results);
        } catch (Exception e) {
//            e.printStackTrace();
            Log.e(TAG, e.toString());
        }
        return ret.toString();
    }

    public String recognizeByBuffer(byte[] bytes, int width, int height, int stride, int format) {
        JSONObject ret = new JSONObject();
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
        return ret.toString();
    }

    private JSONObject wrapResults(DLRResult[] results) {
        JSONObject jsonObject = new JSONObject();
        if (results != null) {
            try {
                JSONArray jsonArray = new JSONArray();
                jsonObject.put("results", jsonArray);
                for (DLRResult result : results) {
                    DLRLineResult[] lineResults = result.lineResults;
                    JSONObject tmpObject = new JSONObject();
                    tmpObject.put("x1", result.location.points[0].x);
                    tmpObject.put("y1", result.location.points[0].y);
                    tmpObject.put("x2", result.location.points[1].x);
                    tmpObject.put("y2", result.location.points[1].y);
                    tmpObject.put("x3", result.location.points[2].x);
                    tmpObject.put("y3", result.location.points[2].y);
                    tmpObject.put("x4", result.location.points[3].x);
                    tmpObject.put("y4", result.location.points[3].y);
                    JSONArray tmpArray = new JSONArray();
                    tmpObject.put("area", tmpArray);
                    for (DLRLineResult line : lineResults) {
                        JSONObject lineObject = new JSONObject();
                        lineObject.put("text", line.text);
                        lineObject.put("x1", line.location.points[0].x);
                        lineObject.put("y1", line.location.points[0].y);
                        lineObject.put("x2", line.location.points[1].x);
                        lineObject.put("y2", line.location.points[1].y);
                        lineObject.put("x3", line.location.points[2].x);
                        lineObject.put("y3", line.location.points[2].y);
                        lineObject.put("x4", line.location.points[3].x);
                        lineObject.put("y4", line.location.points[3].y);
                        tmpArray.put(lineObject);
                    }

                    jsonArray.put(tmpObject);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return jsonObject;
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
