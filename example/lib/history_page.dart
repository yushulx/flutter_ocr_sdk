import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';
import 'package:flutter_ocr_sdk/ocr_line.dart';
import 'package:flutter_ocr_sdk/vin_result.dart';
import 'global.dart';
import 'result_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoaded = false;
  final List<OcrLine> _ocrHistory = List<OcrLine>.empty(growable: true);
  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    _ocrHistory.clear();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getStringList('mrz_data');
    if (data != null) {
      for (String json in data) {
        MrzResult mrzResult = MrzResult.fromJson(jsonDecode(json));
        OcrLine ocrLine = OcrLine();
        ocrLine.mrzResult = mrzResult;
        _ocrHistory.add(ocrLine);
      }
    }

    data = prefs.getStringList('vin_data');
    if (data != null) {
      for (String json in data) {
        VinResult vinResult = VinResult.fromJson(jsonDecode(json));
        OcrLine ocrLine = OcrLine();
        ocrLine.vinResult = vinResult;
        _ocrHistory.add(ocrLine);
      }
    }

    setState(() {
      _isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var listView = Expanded(
        child: ListView.builder(
            itemCount: _ocrHistory.length,
            itemBuilder: (context, index) {
              return MyCustomWidget(
                  result: _ocrHistory[index],
                  cbDeleted: () async {
                    _ocrHistory.removeAt(index);
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    List<String> data =
                        prefs.getStringList('mrz_data') as List<String>;
                    data.removeAt(index);
                    prefs.setStringList('mrz_data', data);
                    setState(() {});
                  },
                  cbOpenResultPage: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultPage(
                            information: _ocrHistory[index],
                            isViewOnly: true,
                          ),
                        ));
                  });
            }));
    return Scaffold(
      appBar: AppBar(
        title: Text('History',
            style: TextStyle(
              fontSize: 22,
              color: colorTitle,
            )),
        centerTitle: true,
        backgroundColor: colorMainTheme,
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 30),
              child: IconButton(
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('mrz_data');
                  setState(() {
                    _ocrHistory.clear();
                  });
                },
                icon: Image.asset(
                  "images/icon-delete.png",
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                ),
              ))
        ],
      ),
      body: _isLoaded
          ? Column(
              children: [listView],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class MyCustomWidget extends StatelessWidget {
  final OcrLine result;
  final Function cbDeleted;
  final Function cbOpenResultPage;

  const MyCustomWidget({
    super.key,
    required this.result,
    required this.cbDeleted,
    required this.cbOpenResultPage,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: const BoxDecoration(color: Colors.black),
        child: Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 16, left: 84),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                Padding(
                  padding: const EdgeInsets.only(right: 27),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    color: Colors.white,
                    onPressed: () async {
                      final RenderBox button =
                          context.findRenderObject() as RenderBox;

                      final RelativeRect position = RelativeRect.fromLTRB(
                        100,
                        button.localToGlobal(Offset.zero).dy,
                        40,
                        0,
                      );

                      final selected = await showMenu(
                        context: context,
                        position: position,
                        color: colorBackground,
                        items: [
                          const PopupMenuItem<int>(
                              value: 0,
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              )),
                          const PopupMenuItem<int>(
                              value: 1,
                              child: Text(
                                'Share',
                                style: TextStyle(color: Colors.white),
                              )),
                          const PopupMenuItem<int>(
                              value: 2,
                              child: Text(
                                'View',
                                style: TextStyle(color: Colors.white),
                              )),
                        ],
                      );

                      if (selected != null) {
                        if (selected == 0) {
                          // delete
                          cbDeleted();
                        } else if (selected == 1) {
                          // share
                          Map<String, dynamic> jsonObject =
                              result.mrzResult == null
                                  ? result.vinResult == null
                                      ? {}
                                      : result.vinResult!.toJson()
                                  : result.mrzResult!.toJson();
                          String jsonString = jsonEncode(jsonObject);
                          Share.share(jsonString);
                        } else {
                          // view
                          cbOpenResultPage();
                        }
                      }
                    },
                  ),
                ),
              ],
            )));
  }
}
