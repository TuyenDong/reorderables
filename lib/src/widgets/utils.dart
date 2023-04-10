import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
static Size measureWidget(Widget widget, [BoxConstraints constraints = const BoxConstraints()]) {
    final PipelineOwner pipelineOwner = PipelineOwner();
    final _MeasurementView rootView = pipelineOwner.rootNode = _MeasurementView(constraints);
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());
    final RenderObjectToWidgetElement<RenderBox> element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: widget,
    ).attachToRenderTree(buildOwner);
    try {
      rootView.scheduleInitialLayout();
      pipelineOwner.flushLayout();
      return rootView.size;
    } finally {
      // Clean up.
      element.update(RenderObjectToWidgetAdapter<RenderBox>(container: rootView));
      buildOwner.finalizeTree();
    }
  }
}

class _MeasurementView extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  final BoxConstraints boxConstraints;
  _MeasurementView(this.boxConstraints);

  @override
  void performLayout() {
    assert(child != null);
    child!.layout(boxConstraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}
