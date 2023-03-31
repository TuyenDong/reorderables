import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

class RowExample extends StatefulWidget {
  @override
  _RowExampleState createState() => _RowExampleState();
}

class _RowExampleState extends State<RowExample> {
  late List<String> _columns;
  final ReorderableController controller = ReorderableController();

  @override
  void initState() {
    super.initState();
    controller.notifyDrag = _notifyDrag;
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
          Expanded(
            child: Center(
              child: ReorderableRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                ignorePrimaryScrollController: true,
                controller: controller,
                padding: EdgeInsets.only(left: 10, right: 10),
                children: List.generate(_columns.length, (index) {
                  final value = _columns[index];
                  return Container(
                    key: ValueKey('$index'),
                    height: 100,
                    padding: EdgeInsets.all(10),
                    color: index % 2 == 0 ? Colors.red : Colors.green,
                    width: 100,
                    margin: EdgeInsets.only(right: 10),
                    child: Image.asset(
                      value,
                      fit: BoxFit.cover,
                    ),
                  );
                }),
                footer: Container(
                  height: 100,
                  padding: EdgeInsets.all(10),
                  color: Colors.green,
                  alignment: Alignment.center,
                  width: 100,
                  child: Text('Edit'),
                ),
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
                onNoReorder: (int index) {
                  //this callback is optional
                  debugPrint(
                      '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
                },
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
    controller.stopReorder();
  }

  void _notifyDrag(bool isDraging) {
    debugPrint('isDraging $isDraging');
  }
}
