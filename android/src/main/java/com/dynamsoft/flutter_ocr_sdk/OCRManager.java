package com.dynamsoft.flutter_ocr_sdk;

import android.util.Log;

import com.dynamsoft.dlr.DLRImageData;
import com.dynamsoft.dlr.DLRLTSLicenseVerificationListener;
import com.dynamsoft.dlr.DLRLineResult;
import com.dynamsoft.dlr.DLRResult;
import com.dynamsoft.dlr.LabelRecognition;
import com.dynamsoft.dlr.LabelRecognitionException;
import com.dynamsoft.dlr.DMLTSConnectionParameters;

import org.json.JSONArray;
import org.json.JSONObject;

public class OCRManager {
    private static String TAG = "OCR";
    private LabelRecognition mLabelRecognition;

    public OCRManager() {
        try {
            mLabelRecognition = new LabelRecognition();
            DMLTSConnectionParameters ltspar = new DMLTSConnectionParameters();
            ltspar.organizationID = "200001";
            mLabelRecognition.initLicenseFromLTS(ltspar, new DLRLTSLicenseVerificationListener() {
                @Override
                public void LTSLicenseVerificationCallback(boolean b, Exception e) {
                    if (e != null) {
                        Log.e("lts error: ", e.getMessage());
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public void setOrganizationID(String id) {
        DMLTSConnectionParameters ltspar = new DMLTSConnectionParameters();
        ltspar.organizationID = id;
        mLabelRecognition.initLicenseFromLTS(ltspar, new DLRLTSLicenseVerificationListener() {
            @Override
            public void LTSLicenseVerificationCallback(boolean b, Exception e) {
                if (e != null) {
                    Log.e("lts error: ", e.getMessage());
                }
            }
        });
    }

    public String recognizeByFile(String fileName, String templateName) {
        JSONObject ret = new JSONObject();
        DLRResult[] results = null;
        try {
            results = mLabelRecognition.recognizeByFile(fileName, templateName);
            ret = wrapResults(results);
        } catch (LabelRecognitionException e) {
//            e.printStackTrace();
            Log.e(TAG, e.toString());
        }
        return ret.toString();
    }

    public String recognizeByBuffer(byte[] bytes, int width, int height, int stride, int format, String templateName) {
        JSONObject ret = new JSONObject();
        DLRResult[] results = null;
        DLRImageData data = new DLRImageData();
        data.bytes = bytes;
        data.width = width;
        data.height = height;
        data.stride = stride;
        data.format = format;
        try {
            results = mLabelRecognition.recognizeByBuffer(data, templateName);
            ret = wrapResults(results);
        } catch (LabelRecognitionException e) {
//            e.printStackTrace();
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
            mLabelRecognition.appendCharacterModelBuffer(name, prototxtBuffer, txtBuffer, characterModelBuffer);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void loadTemplate(String content) {
        try {
            mLabelRecognition.appendSettingsFromString(content);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        mLabelRecognition.destroy();
    }
}
