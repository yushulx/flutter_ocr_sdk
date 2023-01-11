import 'package:flutter/material.dart';
import 'dart:async';

import 'mobile.dart';

Future<void> main() async {
  runApp(
    MaterialApp(
      title: 'MRZ OCR',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("MRZ OCR"),
        ),
        body: Mobile(),
      ),
    ),
  );
}
