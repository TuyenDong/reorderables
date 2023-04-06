import 'package:flutter/material.dart';

class Utils {
  static Offset offset(BuildContext context) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    return box.localToGlobal(_offset);
  }

  static Offset _offset = Offset.zero;
  static Offset get origin => _offset;

  static void configOffset(Offset value) {
    _offset = value;
  }
}
