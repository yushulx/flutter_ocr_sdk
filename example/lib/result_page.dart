import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global.dart';

class ResultPage extends StatefulWidget {
  const ResultPage(
      {super.key, required this.information, this.isViewOnly = false});

  final MrzResult information;
  final bool isViewOnly;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    var keyStyle = TextStyle(color: colorText, fontSize: 14);
    const valueStyle = TextStyle(color: Colors.white, fontSize: 14);
    final infoList = Row(mainAxisAlignment: MainAxisAlignment.start, children: [
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
                Text(widget.information.type!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Issuing State", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.issuingCountry!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Surname", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.surname!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Given Name", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.givenName!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Passport Number", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.passportNumber!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Nationality", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.nationality!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Date of Birth (YYYY-MM-DD)", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.birthDate!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Gender", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.gender!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("Date of Expiry(YYYY-MM-DD)", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.expiration!, style: valueStyle),
                const SizedBox(
                  height: 6,
                ),
                Text("MRZ String", style: keyStyle),
                const SizedBox(
                  height: 3,
                ),
                Text(widget.information.lines!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        overflow: TextOverflow.ellipsis)),
                const SizedBox(
                  height: 6,
                ),
              ],
            ),
          ))
    ]);

    void close() {
      Navigator.pop(context);
    }

    final button = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            padding: const EdgeInsets.only(bottom: 23),
            child: MaterialButton(
              minWidth: 208,
              height: 45,
              onPressed: () async {
                Map<String, dynamic> jsonObject = widget.information.toJson();
                String jsonString = jsonEncode(jsonObject);
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                var results = prefs.getStringList('mrz_data');
                if (results == null) {
                  prefs.setStringList('mrz_data', <String>[jsonString]);
                } else {
                  results.add(jsonString);
                  prefs.setStringList('mrz_data', results);
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
                    Map<String, dynamic> jsonObject =
                        widget.information.toJson();
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
              if (!widget.isViewOnly) button
            ],
          ),
        ));
  }
}
