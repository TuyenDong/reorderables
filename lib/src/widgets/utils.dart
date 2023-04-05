import 'package:flutter/material.dart';

class Utils {
  static Offset offset(BuildContext context) {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero);
  }

  
}
