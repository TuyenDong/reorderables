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
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      debugPrint('_onReorder oldIndex $oldIndex newIndex $newIndex');
      setState(() {
        final col = _columns.removeAt(oldIndex);
        _columns.insert(newIndex, col);
      });
    }

    const dx = 40.0;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.amber,
              alignment: Alignment.center,
              child: ReorderableColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                ignorePrimaryScrollController: true,
                controller: _controller,
                children: List.generate(_columns.length, (index) {
                  final value = _columns[index];
                  return _item(index: index, value: value);
                }),
                onReorder: _onReorder,
                extendItemTop: Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Transform.translate(
                      offset: const Offset(0, -dx + 20),
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        size: 32,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                extendItemBottom: Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Transform.translate(
                      offset: Offset(0, dx),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 32,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: _onPress,
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onPress() {
    _controller.stopReorder();
  }

  Widget _item({required int index, required String value}) {
    final size = MediaQuery.of(context).size;
    return Container(
      key: ValueKey('$index'),
      height: 50,
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.red : Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      width: size.width / 3,
      margin: EdgeInsets.only(top: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          value,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

 
}
