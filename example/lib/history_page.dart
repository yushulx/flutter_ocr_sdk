import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk/mrz_result.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isLoaded = false;
  List<MrzResult> _mrzData = List<MrzResult>.empty(growable: true);
  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getStringList('mrz_data');
    if (data != null) {
      for (String json in data) {
        MrzResult mrzResult = MrzResult.fromJson(jsonDecode(json));
        _mrzData.add(mrzResult);
      }
    }
    setState(() {
      _isLoaded = true;
    });
  }

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
            child: Text('History',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xffF5F5F5),
                )),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
              padding: EdgeInsets.only(top: 59, right: 30),
              child: IconButton(
                onPressed: () async {
                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('mrz_data');
                  setState(() {
                    _mrzData.clear();
                  });
                },
                icon: Image.asset(
                  "images/icon-delete.png",
                  width: 26,
                  height: 26,
                  fit: BoxFit.cover,
                ),
              )),
        ),
      ],
    );

    var listView = Expanded(
        child: ListView.builder(
            itemCount: _mrzData.length,
            itemBuilder: (context, index) {
              // return ListTile(
              //   title: Text(_mrzData[index].type!),
              //   subtitle: Text(_mrzData[index].surname!),
              //   trailing: Text(_mrzData[index].passportNumber!),
              // );
              return MyCustomWidget(
                result: _mrzData[index],
              );
            }));
    return Scaffold(
      body: _isLoaded
          ? Column(
              children: [bar, listView],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class MyCustomWidget extends StatelessWidget {
  final MrzResult result;

  const MyCustomWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration:
            BoxDecoration(color: Colors.black), // Set the background color
        child: Padding(
            padding: EdgeInsets.only(top: 18, bottom: 16, left: 84),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.surname!,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      result.passportNumber!,
                      style: TextStyle(color: Color(0xffCCCCCC)),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                Padding(
                  padding: EdgeInsets.only(right: 27),
                  child: IconButton(
                    icon: Icon(Icons.more_vert),
                    color: Colors.white,
                    onPressed: () {
                      Map<String, dynamic> jsonObject = result.toJson();
                      String jsonString = jsonEncode(jsonObject);
                      Share.share(jsonString);
                    },
                  ),
                ),
              ],
            )));
  }
}
