import 'dart:ui';

import 'package:flutter/material.dart';

import './column_example1.dart';
import './column_example2.dart';
import './nested_wrap_example.dart';
import './row_example.dart';
import './sliver_example.dart';
import './table_example.dart';
import './wrap_example.dart';
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
        PointerDeviceKind.stylus,
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

    TableExample(),
    WrapExample(),
    NestedWrapExample(),
    ColumnExample1(),
    ColumnExample2(),
    SliverExample(),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_on, color: _bottomNavigationColor),
              tooltip: "ReorderableTable",
              label: "Table"),
          BottomNavigationBarItem(
              icon: Icon(Icons.apps, color: _bottomNavigationColor),
              tooltip: "ReorderableWrap",
              label: "Wrap"),
          BottomNavigationBarItem(
              icon: Icon(Icons.view_quilt, color: _bottomNavigationColor),
              tooltip: 'Nested ReroderableWrap',
              label: "Nested"),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_vert, color: _bottomNavigationColor),
              tooltip: "ReorderableColumn 1",
              label: "Column 1"),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_vert, color: _bottomNavigationColor),
              tooltip: "ReroderableColumn 2",
              label: "Column 2"),
          BottomNavigationBarItem(
              icon:
                  Icon(Icons.calendar_view_day, color: _bottomNavigationColor),
              tooltip: "ReroderableSliverList",
              label: "SliverList"),
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
