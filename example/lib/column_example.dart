import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

class ColumnExample extends StatefulWidget {
  @override
  _ColumnExampleState createState() => _ColumnExampleState();
}

class _ColumnExampleState extends State<ColumnExample> {
  late List<String> _columns;
  final _controller = ReorderableController();

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
    ];
    _controller.onDragged = _onDragged;
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        final col = _columns.removeAt(oldIndex);
        _columns.insert(newIndex, col);
      });
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.amber,
              alignment: Alignment.center,
              child: ReorderableColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                ignorePrimaryScrollController: true,
                padding: EdgeInsets.only(top: 20),
                controller: _controller,
                children: List.generate(_columns.length, (index) {
                  final value = _columns[index];
                  return Container(
                    key: ValueKey('$index'),
                    height: 50,
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: size.width / 3,
                    margin: EdgeInsets.only(right: 10, top: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        value,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                oneClickDraggable: true,
                // reorderAnimationDuration: Duration(milliseconds: 1000),
              ),
            ),
          ),
          IconButton(
            onPressed: _onPress,
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  void _onPress() {
    _controller.stopReorder();
  }

  void _onDragged(int? value) {
    debugPrint('_onDragged $value top ${value == 0} '
        'bottom ${value == _columns.length - 1}');
  }
}
