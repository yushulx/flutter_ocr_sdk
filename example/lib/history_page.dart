import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
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
                onPressed: () async {},
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
    return Scaffold(
      body: Column(
        children: [bar],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.more_vert),
        backgroundColor: Colors.green,
      ),
    );
  }
}
