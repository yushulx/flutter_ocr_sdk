import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bar = Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.only(
              top: 64,
              bottom: 15,
            ),
            child: Text('About',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xffF5F5F5),
                )),
          ),
        ),
      ],
    );

    final title = Container(
      padding: EdgeInsets.only(top: 50, left: 39, bottom: 5, right: 39),
      child: Row(
        children: [
          Image.asset(
            "images/logo-dlr.png",
            width: MediaQuery.of(context).size.width - 80,
          ),
        ],
      ),
    );

    final version = Container(
      height: 40,
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Text(
        'App Version 2.2.20',
        style: TextStyle(color: Color(0xff888888)),
      ),
    );

    final description = Container(
        padding: EdgeInsets.only(left: 44, right: 39),
        child: Center(
          child: Text(
            'Recognizes MRZ code & extracts data from 1D-codes, passports, and visas. Supports TD-1, TD-2, TD-3, MRV-A, and MRV-B standards.',
            style: TextStyle(color: Colors.white, wordSpacing: 2),
            textAlign: TextAlign.center,
          ),
        ));

    final button = Container(
      padding: EdgeInsets.only(top: 48, left: 91, right: 91, bottom: 69),
      child: MaterialButton(
        minWidth: 208,
        height: 44,
        color: Color(0xffFE8E14),
        onPressed: () {
          launchUrlString('https://www.dynamsoft.com/downloads/');
        },
        child: Text(
          'GET FREE TRIAL SDK',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );

    final links = Container(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      decoration: BoxDecoration(color: Colors.black),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 13, bottom: 15),
            child: InkWell(
                onTap: () {
                  launchUrlString(
                      'https://www.dynamsoft.com/label-recognition/overview/');
                },
                child: Text(
                  'Dynamsoft Label Recognizer overview >',
                  style: TextStyle(color: Color(0xffFE8E14)),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(top: 13, bottom: 15),
            child: InkWell(
                onTap: () {
                  launchUrlString('https://www.dynamsoft.com/company/about/');
                },
                child: Text(
                  'Contact us >',
                  style: TextStyle(color: Color(0xffFE8E14)),
                )),
          ),
        ],
      ),
    );

    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [
        bar,
        title,
        version,
        description,
        button,
        links,
      ],
    )));
  }
}
