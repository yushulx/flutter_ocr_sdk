import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';
import 'package:flutter_ocr_sdk/vin_result.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';

class ResultPage extends StatefulWidget {
  const ResultPage(
      {super.key, required this.information, this.isViewOnly = false});

  final OcrLine information;
  final bool isViewOnly;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    var keyStyle = TextStyle(color: colorText, fontSize: 14);
    const valueStyle = TextStyle(color: Colors.white, fontSize: 14);
    void close() {
      Navigator.pop(context);
    }

    MrzResult? mrzResult = widget.information.mrzResult;
    VinResult? vinResult = widget.information.vinResult;
    var infoList;
    var button;
    if (mrzResult != null) {
      infoList = Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.only(left: 35, bottom: 40),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Document Type", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.type!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Issuing State", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.issuingCountry!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Surname", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.surname!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Given Name", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.givenName!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Passport Number", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.docNumber!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Nationality", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.nationality!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Date of Birth", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.birthDate!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Gender", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.gender!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Date of Expiry", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.expiration!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("MRZ String", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(mrzResult.lines!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(
                    height: 6,
                  ),
                ],
              ),
            ))
      ]);

      button = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.only(bottom: 23),
              child: MaterialButton(
                minWidth: 208,
                height: 45,
                onPressed: () async {
                  Map<String, dynamic> jsonObject = mrzResult.toJson();
                  String jsonString = jsonEncode(jsonObject);
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var results = prefs.getStringList('vin_data');
                  if (results == null) {
                    prefs.setStringList('vin_data', <String>[jsonString]);
                  } else {
                    results.add(jsonString);
                    prefs.setStringList('vin_data', results);
                  }

                  close();
                },
                color: colorOrange,
                child: const Text(
                  'Save and Continue',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ))
        ],
      );
    }

    if (vinResult != null) {
      infoList = Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
            padding: const EdgeInsets.only(left: 35, bottom: 40),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("WMI", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.wmi!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Region", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.region!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("VDS", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.vds!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Check Digit", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.checkDigit!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Model Year", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.modelYear!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Manufacturer plant", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.plantCode!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("Serial Number", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.serialNumber!, style: valueStyle),
                  const SizedBox(
                    height: 6,
                  ),
                  Text("VIN String", style: keyStyle),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(vinResult.vinString!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis)),
                  const SizedBox(
                    height: 6,
                  ),
                ],
              ),
            ))
      ]);

      button = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.only(bottom: 23),
              child: MaterialButton(
                minWidth: 208,
                height: 45,
                onPressed: () async {
                  Map<String, dynamic> jsonObject = vinResult.toJson();
                  String jsonString = jsonEncode(jsonObject);
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  var results = prefs.getStringList('vin_data');
                  if (results == null) {
                    prefs.setStringList('vin_data', <String>[jsonString]);
                  } else {
                    results.add(jsonString);
                    prefs.setStringList('vin_data', results);
                  }

                  close();
                },
                color: colorOrange,
                child: const Text(
                  'Save and Continue',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ))
        ],
      );
    }

    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Result',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(
              color: Colors
                  .white, // Set the color of the back arrow and other icons
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: IconButton(
                  onPressed: () {
                    Map<String, dynamic> jsonObject = mrzResult == null
                        ? vinResult == null
                            ? <String, dynamic>{}
                            : vinResult.toJson()
                        : mrzResult.toJson();
                    String jsonString = jsonEncode(jsonObject);
                    Share.share(jsonString);
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                ),
              )
            ],
          ),
          body: Column(
            children: [
              infoList,
              Expanded(
                child: Container(),
              ),
              // if (!widget.isViewOnly) button
            ],
          ),
        ));
  }
}
