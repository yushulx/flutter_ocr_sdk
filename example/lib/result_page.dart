import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';
import 'package:flutter_ocr_sdk/mrz_parser.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.area});

  final List<MrzLine> area;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late MrzResult _information;

  @override
  void initState() {
    super.initState();

    List<MrzLine> area = widget.area;
    if (area.length == 2) {
      _information = MRZ.parseTwoLines(area[0].text, area[1].text);
    } else if (area.length == 3) {
      _information =
          MRZ.parseThreeLines(area[0].text, area[1].text, area[2].text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyStyle = TextStyle(color: Color(0xff888888), fontSize: 14);
    final valueStyle = TextStyle(color: Colors.white, fontSize: 14);
    final infoList = Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          padding: EdgeInsets.only(left: 35, bottom: 40),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Document Type", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.type!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Issuing State", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.issuingCountry!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Surname", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.surname!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Given Name", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.givenName!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Passport Number", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.passportNumber!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Nationality", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.nationality!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Date of Birth (YYYY-MM-DD)", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.birthDate!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Gender", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.gender!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Date of Expiry(YYYY-MM-DD)", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(_information.expiration!, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("MRZ String", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(
                    widget.area.length == 2
                        ? '${widget.area[0].text}\n${widget.area[1].text}'
                        : '${widget.area[0].text}\n${widget.area[1].text}\n${widget.area[2].text}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        overflow: TextOverflow.ellipsis)),
                SizedBox(
                  height: 6,
                ),
              ],
            ),
          ))
    ]);

    final button = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: EdgeInsets.only(bottom: 23),
            child: MaterialButton(
              minWidth: 208,
              height: 45,
              onPressed: () async {
                Map<String, dynamic> jsonObject = _information.toJson();
                String jsonString = jsonEncode(jsonObject);
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                var results = await prefs.getStringList('mrz_data');
                if (results == null) {
                  prefs.setStringList('mrz_data', <String>[jsonString]);
                } else {
                  results.add(jsonString);
                  prefs.setStringList('mrz_data', results);
                }

                Navigator.pop(context);
              },
              color: Color(0xffFE8E14),
              child: Text(
                'Save and Continue',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ))
      ],
    );

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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20), // Add padding here
                child: IconButton(
                  onPressed: () {
                    Map<String, dynamic> jsonObject = _information.toJson();
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
              button
            ],
          ),
        ));
  }
}
