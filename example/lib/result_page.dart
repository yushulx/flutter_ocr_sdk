import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/mrz_line.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.area, required this.information});
  final MrzResult information;
  final List<MrzLine> area;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
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
                Text(widget.information.type, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Issuing State", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.issuingCountry, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Surname", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.surname, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Given Name", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.givenName, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Passport Number", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.passportNumber, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Nationality", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.nationality, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Date of Birth (YYYY-MM-DD)", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.birthDate, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Gender", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.gender, style: valueStyle),
                SizedBox(
                  height: 6,
                ),
                Text("Date of Expiry(YYYY-MM-DD)", style: keyStyle),
                SizedBox(
                  height: 3,
                ),
                Text(widget.information.expiration, style: valueStyle),
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
              onPressed: () {},
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
                  onPressed: () async {},
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
