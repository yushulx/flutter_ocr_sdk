import 'package:flutter/material.dart';
import 'tab_page.dart';
import 'dart:async';
import 'global.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<int> loadData() async {
    return await initSDK();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamsoft MRZ Detection',
      theme: ThemeData(
        scaffoldBackgroundColor: colorMainTheme,
      ),
      home: FutureBuilder<int>(
        future: loadData(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator(); // Loading indicator
          }
          Future.microtask(() {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const TabPage()));
          });
          return Container();
        },
      ),
    );
  }
}
