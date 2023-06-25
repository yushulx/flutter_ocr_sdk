import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        Container(
            padding: EdgeInsets.only(
              top: 30,
              left: 33,
            ),
            child: Text('MRZ SCANNER',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                )))
      ],
    );

    final description = Row(
      children: [
        Container(
            padding: EdgeInsets.only(top: 6, left: 33, bottom: 44),
            child: SizedBox(
              width: 271,
              child: Text(
                  'Recognizes MRZ code & extracts data from 1D-codes, passports, and visas.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
            ))
      ],
    );

    final buttons = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: Container(
              width: 150,
              height: 125,
              decoration: BoxDecoration(
                color: Color(0xFFfe8e14),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/icon-camera.png",
                    width: 90,
                    height: 60,
                  ),
                  Text(
                    "Camera Scan",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
            )),
        GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: Container(
              width: 150,
              height: 125,
              decoration: BoxDecoration(
                color: Color(0xFF323234),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "images/icon-image.png",
                    width: 90,
                    height: 60,
                  ),
                  Text(
                    "Image Scan",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  )
                ],
              ),
            ))
      ],
    );
    final image = Expanded(
        child: Image.asset(
      "images/image-mrz.png",
      fit: BoxFit.cover,
    ));
    return Scaffold(
      body: Column(
        children: [
          title,
          description,
          buttons,
          SizedBox(
            height: 34,
          ),
          image
        ],
      ),
    );
  }
}
