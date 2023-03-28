import 'package:flutter/material.dart';

import 'package:reorderables/reorderables.dart';

class ColumnExample extends StatefulWidget {
  @override
  _ColumnExampleState createState() => _ColumnExampleState();
}

class _ColumnExampleState extends State<ColumnExample> {
  late List<String> _columns;
  final ReorderableController controller = ReorderableController();

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
                controller: controller,
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
}

class DragModel {
  final String url;
  bool selected = false;

  DragModel(this.url);
}
