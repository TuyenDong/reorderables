import 'dart:ui';

import 'package:flutter/material.dart';

import './row_example.dart';
import 'column_example.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reorderables Demo',
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
      home: MyHomePage(),
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _examples = [
    RowExample(),
    ColumnExample(),
  ];
  final _bottomNavigationColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _examples[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: _bottomNavigationColor,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        // this will be set when a new tab is tapped
//        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz, color: _bottomNavigationColor),
              tooltip: "ReorderableRow",
              label: "Row"),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_vert, color: _bottomNavigationColor),
              tooltip: "ReorderableColumn",
              label: "Column"),
        ],
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
