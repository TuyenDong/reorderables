import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

class RowExample extends StatefulWidget {
  @override
  _RowExampleState createState() => _RowExampleState();
}

class _RowExampleState extends State<RowExample> {
  late List<String> _columns;

  @override
  void initState() {
    super.initState();
    _columns = [
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
      'assets/river1.jpg',
      'assets/river2.jpg',
      'assets/river3.jpg',
    ];
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        final col = _columns.removeAt(oldIndex);
        _columns.insert(newIndex, col);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
      children: [
        Container(
          color: Colors.amber,
          height: 200,
          child: ReorderableRow(
            crossAxisAlignment: CrossAxisAlignment.start,
            padding: EdgeInsets.only(top: 20),
            children: List.generate(_columns.length, (index) {
              final value = _columns[index];
              return Container(
                key: ValueKey('$index'),
                height: 100,
                padding: EdgeInsets.all(10),
                color: index%2 ==0 ? Colors.red: Colors.green,
                width: 100,
                margin: EdgeInsets.only(right: 10, top: 20),
                child: Image.asset(value, fit: BoxFit.cover,),
              );
            }),
            onReorder: _onReorder,
            // draggingWidgetOpacity: 0,
            // draggedItemBuilder: (context, index) {
            //    final value = _columns[index];
            //   return Container(
            //     key: ValueKey('$index'),
            //     height: 100,
            //     padding: EdgeInsets.all(10),
            //     color: index%2 ==0 ? Colors.red: Colors.green,
            //     width: 100,
            //     margin: EdgeInsets.only(bottom: 20, right: 10),
            //     child: Image.asset(value, fit: BoxFit.cover,),
            //   );
            // },
            needsLongPressDraggable: false,
            oneClickDraggable: true,
            // reorderAnimationDuration: Duration(milliseconds: 1000),
            onNoReorder: (int index) {
              //this callback is optional
              debugPrint(
                  '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
            },
          ),
        ),
        IconButton(
          onPressed: _onPress,
          icon: Icon(Icons.add),
        )
      ],
    ),
    );
  }

  void _onPress() {}
}

class DragModel {
  final String url;
  bool selected = false;

  DragModel(this.url);
}
