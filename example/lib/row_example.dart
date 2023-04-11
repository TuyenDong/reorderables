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

    const dx = 20.0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.amber,
              alignment: Alignment.center,
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
                  child: Text('Edit', textDirection: TextDirection.ltr,),
                ),
                header: Container(
                  height: 100,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(right: 10),
                  color: Colors.green,
                  alignment: Alignment.center,
                  width: 100,
                  child: Text('Edit', textDirection: TextDirection.ltr,),
                ),
                onReorder: _onReorder,
                extendItemLeft: Positioned.fill(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Transform.translate(
                      offset: const Offset(-dx - 10, 0),
                      child: const Icon(
                        Icons.keyboard_arrow_left,
                        size: 32,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                extendItemRight: Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: Offset(dx, 0),
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                        size: 32,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                // draggingWidgetOpacity: 0,
                // maringBottomDragingItem: 70,
                // draggedItemBuilder: (context, index) {
                //   final value = _columns[index];
                //   return SizedBox(
                //     height: 500,
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.only(right: 10, bottom: 10),
                //           child: GestureDetector(
                //             onTap: _onPress,
                //             child: Container(
                //               color: Colors.transparent,
                //               child: const Icon(
                //                 Icons.add,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ),
                //         ),
                //         Container(
                //           key: ValueKey('$index'),
                //           height: 100,
                //           padding: const EdgeInsets.all(10),
                //           color: index % 2 == 0 ? Colors.red : Colors.green,
                //           width: 100,
                //           margin: const EdgeInsets.only(right: 10),
                //           child: Image.asset(
                //             value,
                //             fit: BoxFit.cover,
                //           ),
                //         ),
                //       ],
                //     ),
                //   );
                // },
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
