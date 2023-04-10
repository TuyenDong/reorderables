import 'package:flutter/widgets.dart';

class ReorderableWidget extends StatelessWidget implements ReorderableItem {
  final Widget child;
  @override
  final bool reorderable;

  const ReorderableWidget({
    required this.child,
    required this.reorderable,
    required Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

abstract class ReorderableItem extends Widget {
  final bool reorderable;

  const ReorderableItem({Key? key, required this.reorderable})
      : super(key: key);
}
