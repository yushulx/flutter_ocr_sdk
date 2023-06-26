import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk_example/tab_page.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'global.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<SharedPreferences> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await initMRZSDK();
    return prefs;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamsoft MRZ Detection',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff1D1B20),
      ),
      home: FutureBuilder<SharedPreferences>(
        future: loadData(),
        builder:
            (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(); // Loading indicator
          }
          Future.microtask(() {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => TabPage()));
          });
          return Container();
        },
      ),
    );
  }
}
