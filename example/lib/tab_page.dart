import 'package:flutter/material.dart';
import 'package:flutter_ocr_sdk_example/history_page.dart';

import 'about_page.dart';
import 'home_page.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CustomTab> myTabs = <CustomTab>[
    CustomTab(
        text: 'Home',
        icon: 'images/icon-home-gray.png',
        selectedIcon: 'images/icon-home-orange.png'),
    CustomTab(
        text: 'History',
        icon: 'images/icon-history-gray.png',
        selectedIcon: 'images/icon-history-orange.png'),
    CustomTab(
        text: 'About',
        icon: 'images/icon-about-gray.png',
        selectedIcon: 'images/icon-about-orange.png'),
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: TabBarView(
          controller: _tabController,
          children: [
            HomePage(),
            HistoryPage(),
            AboutPage(),
          ],
        ),
        bottomNavigationBar: Container(
          height: 83,
          child: TabBar(
            labelColor: Colors.blue,
            controller: _tabController,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            tabs: myTabs.map((CustomTab tab) {
              return MyTab(
                  tab: tab, isSelected: myTabs.indexOf(tab) == selectedIndex);
            }).toList(),
          ),
        ));
  }
}

class MyTab extends StatelessWidget {
  final CustomTab tab;
  final bool isSelected;

  MyTab({required this.tab, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            isSelected ? tab.selectedIcon : tab.icon,
            width: 48,
            height: 32,
          ),
          Text(
            tab.text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 9,
                color: isSelected ? Color(0xffFE8E14) : Color(0xff757575)),
          )
        ],
      ),
    );
  }
}

class CustomTab {
  final String text;
  final String icon;
  final String selectedIcon;

  CustomTab(
      {required this.text, required this.icon, required this.selectedIcon});
}
