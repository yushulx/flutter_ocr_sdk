import 'package:flutter/material.dart';

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
    return Scaffold(
        body: Column(
      children: [bar],
    ));
  }
}
