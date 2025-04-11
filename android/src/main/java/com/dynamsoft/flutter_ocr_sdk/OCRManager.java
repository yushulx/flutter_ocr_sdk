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
import com.dynamsoft.dcp.ParsedResultItem;
import com.dynamsoft.core.basic_structures.ImageData;

import android.content.Context;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Calendar;

import io.flutter.plugin.common.MethodChannel.Result;

public class OCRManager {
    private static String TAG = "OCR";
    private CaptureVisionRouter mRouter;
    private String templateName;
    private int mBirthYear;

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

    public ArrayList<ArrayList<HashMap<String, Object>>> recognizeByBuffer(byte[] bytes, int width, int height, int stride, int format, int rotation) {
        ArrayList<ArrayList<HashMap<String, Object>>> ret = new ArrayList<ArrayList<HashMap<String, Object>>>();
        CapturedResult results = null;
        ImageData imageData = new ImageData();
        imageData.bytes = bytes;
        imageData.width = width;
        imageData.height = height;
        imageData.stride = stride;
        imageData.format = format;
        imageData.orientation = rotation;
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
            ArrayList<HashMap<String, Object>> area = new ArrayList<HashMap<String, Object>>();
            HashMap<String, Object> data = new HashMap<>();
            for (CapturedResultItem item : items) {
                if (item instanceof TextLineResultItem) {
                    
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

                    
                }
                else if (item instanceof ParsedResultItem) {
                    ParsedResultItem parsedItem = (ParsedResultItem)item;
                    HashMap<String, String> entry = parsedItem.getParsedFields();
                    if (templateName.equals("ReadVINText")) {
                        data.put("type", "VIN");
                        String vinString = entry.get("vinString") == null ? "" : entry.get("vinString");
                        String wmi = entry.get("WMI") == null ? "" : entry.get("WMI");
                        String region = entry.get("region") == null ? "" : entry.get("region");
                        String vds = entry.get("VDS") == null ? "" : entry.get("VDS");
                        String checkDigit = entry.get("checkDigit") == null ? "" : entry.get("checkDigit");
                        String modelYear = entry.get("modelYear") == null ? "" : entry.get("modelYear");
                        String plantCode = entry.get("plantCode") == null ? "" : entry.get("plantCode");
                        String serialNumber = entry.get("serialNumber") == null ? "" : entry.get("serialNumber");

                        data.put("vinString", vinString);
                        data.put("wmi", wmi);
                        data.put("region", region);
                        data.put("vds", vds);
                        data.put("checkDigit", checkDigit);
                        data.put("modelYear", modelYear);
                        data.put("plantCode", plantCode);
                        data.put("serialNumber", serialNumber);
                    }
                    else {
                        data.put("type", "MRZ");
                        
                        String docType = parsedItem.getCodeType();
                        String docNumber = entry.get("passportNumber") == null ? entry.get("documentNumber") == null
				? entry.get("longDocumentNumber") == null ? "" : entry.get("longDocumentNumber") :
				entry.get("documentNumber") : entry.get("passportNumber");
                        String nationality = entry.get("nationality") == null? "" : entry.get("nationality");
                        String issuingCountry = entry.get("issuingState") == null? "" : entry.get("issuingState");
                        String mrzText = "";
                        String givenName = entry.get("secondaryIdentifier") == null ? "" : entry.get("secondaryIdentifier");
                        String surname = entry.get("primaryIdentifier") == null ? "" : " " + entry.get("primaryIdentifier");

                        int expiryYear = 0;
                        int age;
                        try {
                            int year = Integer.parseInt(entry.get("birthYear"));
                            int month = Integer.parseInt(entry.get("birthMonth"));
                            int day = Integer.parseInt(entry.get("birthDay"));
                            expiryYear = Integer.parseInt(entry.get("expiryYear")) + 2000;
                            age = calculateAge(year, month, day);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        String sex = entry.get("sex");
                        String dateOfBirth = mBirthYear + "-" + entry.get("birthMonth") + "-" + entry.get("birthDay");
                        String dateOfExpire = expiryYear + "-" + entry.get("expiryMonth") + "-" + entry.get("expiryDay");
                        String line1 = entry.get("line1");
                        String line2 = entry.get("line2");
                        String line3 = entry.get("line3");
                        if (line1 != null) {
                            mrzText += line1 + "\n";
                        }
                        if (line2 != null) {
                            mrzText += line2 + "\n";
                        }
                        if (line3 != null) {
                            mrzText += line3;
                        }

                        data.put("docType", docType);
                        data.put("nationality", nationality);
                        data.put("surname", surname);
                        data.put("givenName", givenName);
                        data.put("docNumber", docNumber);
                        data.put("issuingCountry", issuingCountry);
                        data.put("birthDate", dateOfBirth);
                        data.put("gender", sex);
                        data.put("expiration", dateOfExpire);
                        data.put("mrzString", mrzText);
                    }
                    
                }
                else {
                    data.put("type", "unknown");
                }
               
            }

            area.add(data);
            objectList.add(area);
        }
        return objectList;
    }

    public void loadModel(String name) {
        templateName = name;
    }

    private int calculateAge(int year, int month, int day) {
		Calendar calendar = Calendar.getInstance();
		int cYear = calendar.get(Calendar.YEAR);
		int cMonth = calendar.get(Calendar.MONTH) + 1;
		int cDay = calendar.get(Calendar.DAY_OF_MONTH);
		mBirthYear = 1900 + year;
		int diffYear = cYear - mBirthYear;
		int diffMonth = cMonth - month;
		int diffDay = cDay - day;
		int age = minusYear(diffYear, diffMonth, diffDay);
		if (age > 100) {
			mBirthYear = 2000 + year;
			diffYear = cYear - mBirthYear;
			age = minusYear(diffYear, diffMonth, diffDay);
		} else if (age < 0) {
			age = 0;
		}
		return age;
	}

	private int minusYear(int diffYear, int diffMonth, int diffDay) {
		int age = Math.max(diffYear, 0);
		if (diffMonth < 0) {
			age = age - 1;

		} else if (diffMonth == 0) {
			if (diffDay < 0) {
				age = age - 1;
			}
		}
		return age;
	}
}
