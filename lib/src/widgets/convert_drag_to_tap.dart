// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Signature for determining whether the given data will be accepted by a [DragTargetMouse].
///
/// Used by [DragTargetMouse.onWillAccept].
typedef DragTargetWillAccept<T> = bool Function(T? data);

/// Signature for causing a [DragTargetMouse] to accept the given data.
///
/// Used by [DragTargetMouse.onAccept].
typedef DragTargetAccept<T> = void Function(T data);

/// Signature for determining information about the acceptance by a [DragTargetMouse].
///
/// Used by [DragTargetMouse.onAcceptWithDetails].
typedef DragTargetAcceptWithDetails<T> = void Function(
    DragTargetDetails<T> details);

/// Signature for building children of a [DragTargetMouse].
///
/// The `candidateData` argument contains the list of drag data that is hovering
/// over this [DragTargetMouse] and that has passed [DragTargetMouse.onWillAccept]. The
/// `rejectedData` argument contains the list of drag data that is hovering over
/// this [DragTargetMouse] and that will not be accepted by the [DragTargetMouse].
///
/// Used by [DragTargetMouse.builder].
typedef DragTargetBuilder<T> = Widget Function(
    BuildContext context, List<T?> candidateData, List<dynamic> rejectedData);

/// Signature for when a [DraggableByMouse] is dragged across the screen.
///
/// Used by [DraggableByMouse.onDragUpdate].
typedef DragUpdateCallback = void Function(DragUpdateDetails details);

/// Signature for when a [DraggableByMouse] is dropped without being accepted by a [DragTargetMouse].
///
/// Used by [DraggableByMouse.onDraggableCanceled].
typedef DraggableCanceledCallback = void Function(
    Velocity velocity, Offset offset);

/// Signature for when the draggable is dropped.
///
/// The velocity and offset at which the pointer was moving when the draggable
/// was dropped is available in the [DraggableDetails]. Also included in the
/// `details` is whether the draggable's [DragTargetMouse] accepted it.
///
/// Used by [DraggableByMouse.onDragEnd].
typedef DragEndCallback = void Function(DraggableDetails details);

/// Signature for when a [DraggableByMouse] leaves a [DragTargetMouse].
///
/// Used by [DragTargetMouse.onLeave].
typedef DragTargetLeave<T> = void Function(T? data);

/// Signature for when a [DraggableByMouse] moves within a [DragTargetMouse].
///
/// Used by [DragTargetMouse.onMove].
typedef DragTargetMove<T> = void Function(DragTargetDetails<T> details);

/// Signature for the strategy that determines the drag start point of a [DraggableByMouse].
///
/// Used by [DraggableByMouse.dragAnchorStrategy].
///
/// There are two built-in strategies:
///
///  * [childDragAnchorStrategy], which displays the feedback anchored at the
///    position of the original child.
///
///  * [pointerDragAnchorStrategy], which displays the feedback anchored at the
///    position of the touch that started the drag.
typedef DragAnchorStrategy = Offset Function(
    DraggableByMouse<Object> draggable, BuildContext context, Offset position);

/// Display the feedback anchored at the position of the original child.
///
/// If feedback is identical to the child, then this means the feedback will
/// exactly overlap the original child when the drag starts.
///
/// This is the default [DragAnchorStrategy].
///
/// See also:
///
///  * [DragAnchorStrategy], the typedef that this function implements.
///  * [DraggableByMouse.dragAnchorStrategy], for which this is a built-in value.
Offset childDragAnchorStrategy(
    DraggableByMouse<Object> draggable, BuildContext context, Offset position) {
  final RenderBox renderObject = context.findRenderObject()! as RenderBox;
  return renderObject.globalToLocal(position);
}

/// Display the feedback anchored at the position of the touch that started
/// the drag.
///
/// If feedback is identical to the child, then this means the top left of the
/// feedback will be under the finger when the drag starts. This will likely not
/// exactly overlap the original child, e.g. if the child is big and the touch
/// was not centered. This mode is useful when the feedback is transformed so as
/// to move the feedback to the left by half its width, and up by half its width
/// plus the height of the finger, since then it appears as if putting the
/// finger down makes the touch feedback appear above the finger. (It feels
/// weird for it to appear offset from the original child if it's anchored to
/// the child and not the finger.)
///
/// See also:
///
///  * [DragAnchorStrategy], the typedef that this function implements.
///  * [DraggableByMouse.dragAnchorStrategy], for which this is a built-in value.
Offset pointerDragAnchorStrategy(
    DraggableByMouse<Object> draggable, BuildContext context, Offset position) {
  return Offset.zero;
}

/// A widget that can be dragged from to a [DragTargetMouse].
///
/// When a draggable widget recognizes the start of a drag gesture, it displays
/// a [feedback] widget that tracks the user's finger across the screen. If the
/// user lifts their finger while on top of a [DragTargetMouse], that target is given
/// the opportunity to accept the [data] carried by the draggable.
///
/// The [ignoringFeedbackPointer] defaults to true, which means that
/// the [feedback] widget ignores the pointer during hit testing. Similarly,
/// [ignoringFeedbackSemantics] defaults to true, and the [feedback] also ignores
/// semantics when building the semantics tree.
///
/// On multitouch devices, multiple drags can occur simultaneously because there
/// can be multiple pointers in contact with the device at once. To limit the
/// number of simultaneous drags, use the [maxSimultaneousDrags] property. The
/// default is to allow an unlimited number of simultaneous drags.
///
/// This widget displays [child] when zero drags are under way. If
/// [childWhenDragging] is non-null, this widget instead displays
/// [childWhenDragging] when one or more drags are underway. Otherwise, this
/// widget always displays [child].
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=QzA4c4QHZCY}
///
/// {@tool dartpad}
/// The following example has a [DraggableByMouse] widget along with a [DragTargetMouse]
/// in a row demonstrating an incremented `acceptedData` integer value when
/// you drag the element to the target.
///
/// ** See code in examples/api/lib/widgets/drag_target/draggable.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [DragTargetMouse]
///  * [LongPressDraggable]
class DraggableByMouse<T extends Object> extends StatefulWidget {
  /// Creates a widget that can be dragged to a [DragTargetMouse].
  ///
  /// The [child] and [feedback] arguments must not be null. If
  /// [maxSimultaneousDrags] is non-null, it must be non-negative.
  const DraggableByMouse({
    Key? key,
    required this.child,
    required this.feedback,
    this.data,
    this.dataMax,
    this.axis,
    this.childWhenDragging,
    this.extendItemTop,
    this.extendItemBottom,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = childDragAnchorStrategy,
    this.affinity,
    this.maxSimultaneousDrags,
    this.onDragStarted,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.ignoringFeedbackSemantics = true,
    this.ignoringFeedbackPointer = true,
    this.rootOverlay = false,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    required this.onChange,
    this.currentDrag,
    required this.indexDraging,
  });
  final Function(DragAvatar?, T?) onChange;

  final DragAvatar<Object>? currentDrag;
  final int? indexDraging;

  /// The data that will be dropped by this draggable.
  final T? data;
  final T? dataMax;

  /// The [Axis] to restrict this draggable's movement, if specified.
  ///
  /// When axis is set to [Axis.horizontal], this widget can only be dragged
  /// horizontally. Behavior is similar for [Axis.vertical].
  ///
  /// Defaults to allowing drag on both [Axis.horizontal] and [Axis.vertical].
  ///
  /// When null, allows drag on both [Axis.horizontal] and [Axis.vertical].
  ///
  /// For the direction of gestures this widget competes with to start a drag
  /// event, see [DraggableByMouse.affinity].
  final Axis? axis;

  /// The widget below this widget in the tree.
  ///
  /// This widget displays [child] when zero drags are under way. If
  /// [childWhenDragging] is non-null, this widget instead displays
  /// [childWhenDragging] when one or more drags are underway. Otherwise, this
  /// widget always displays [child].
  ///
  /// The [feedback] widget is shown under the pointer when a drag is under way.
  ///
  /// To limit the number of simultaneous drags on multitouch devices, see
  /// [maxSimultaneousDrags].
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  /// The widget to display instead of [child] when one or more drags are under way.
  ///
  /// If this is null, then this widget will always display [child] (and so the
  /// drag source representation will not change while a drag is under
  /// way).
  ///
  /// The [feedback] widget is shown under the pointer when a drag is under way.
  ///
  /// To limit the number of simultaneous drags on multitouch devices, see
  /// [maxSimultaneousDrags].
  final Widget? childWhenDragging;
  final Widget? extendItemTop;
  final Widget? extendItemBottom;

  /// The widget to show under the pointer when a drag is under way.
  ///
  /// See [child] and [childWhenDragging] for information about what is shown
  /// at the location of the [DraggableByMouse] itself when a drag is under way.
  final Widget feedback;

  /// The feedbackOffset can be used to set the hit test target point for the
  /// purposes of finding a drag target. It is especially useful if the feedback
  /// is transformed compared to the child.
  final Offset feedbackOffset;

  /// A strategy that is used by this draggable to get the anchor offset when it
  /// is dragged.
  ///
  /// The anchor offset refers to the distance between the users' fingers and
  /// the [feedback] widget when this draggable is dragged.
  ///
  /// This property's value is a function that implements [DragAnchorStrategy].
  /// There are two built-in functions that can be used:
  ///
  ///  * [childDragAnchorStrategy], which displays the feedback anchored at the
  ///    position of the original child.
  ///
  ///  * [pointerDragAnchorStrategy], which displays the feedback anchored at the
  ///    position of the touch that started the drag.
  ///
  /// Defaults to [childDragAnchorStrategy].
  final DragAnchorStrategy dragAnchorStrategy;

  /// Whether the semantics of the [feedback] widget is ignored when building
  /// the semantics tree.
  ///
  /// This value should be set to false when the [feedback] widget is intended
  /// to be the same object as the [child]. Placing a [GlobalKey] on this
  /// widget will ensure semantic focus is kept on the element as it moves in
  /// and out of the feedback position.
  ///
  /// Defaults to true.
  final bool ignoringFeedbackSemantics;

  /// Whether the [feedback] widget is ignored during hit testing.
  ///
  /// Regardless of whether this widget is ignored during hit testing, it will
  /// still consume space during layout and be visible during painting.
  ///
  /// Defaults to true.
  final bool ignoringFeedbackPointer;

  /// Controls how this widget competes with other gestures to initiate a drag.
  ///
  /// If affinity is null, this widget initiates a drag as soon as it recognizes
  /// a tap down gesture, regardless of any directionality. If affinity is
  /// horizontal (or vertical), then this widget will compete with other
  /// horizontal (or vertical, respectively) gestures.
  ///
  /// For example, if this widget is placed in a vertically scrolling region and
  /// has horizontal affinity, pointer motion in the vertical direction will
  /// result in a scroll and pointer motion in the horizontal direction will
  /// result in a drag. Conversely, if the widget has a null or vertical
  /// affinity, pointer motion in any direction will result in a drag rather
  /// than in a scroll because the draggable widget, being the more specific
  /// widget, will out-compete the [Scrollable] for vertical gestures.
  ///
  /// For the directions this widget can be dragged in after the drag event
  /// starts, see [DraggableByMouse.axis].
  final Axis? affinity;

  /// How many simultaneous drags to support.
  ///
  /// When null, no limit is applied. Set this to 1 if you want to only allow
  /// the drag source to have one item dragged at a time. Set this to 0 if you
  /// want to prevent the draggable from actually being dragged.
  ///
  /// If you set this property to 1, consider supplying an "empty" widget for
  /// [childWhenDragging] to create the illusion of actually moving [child].
  final int? maxSimultaneousDrags;

  /// Called when the draggable starts being dragged.
  final VoidCallback? onDragStarted;

  /// Called when the draggable is dragged.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true), and if this widget has actually moved.

  /// Called when the draggable is dropped without being accepted by a [DragTargetMouse].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up being canceled, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final DraggableCanceledCallback? onDraggableCanceled;

  /// Called when the draggable is dropped and accepted by a [DragTargetMouse].
  ///
  /// This function might be called after this widget has been removed from the
  /// tree. For example, if a drag was in progress when this widget was removed
  /// from the tree and the drag ended up completing, this callback will
  /// still be called. For this reason, implementations of this callback might
  /// need to check [State.mounted] to check whether the state receiving the
  /// callback is still in the tree.
  final VoidCallback? onDragCompleted;

  /// Called when the draggable is dropped.
  ///
  /// The velocity and offset at which the pointer was moving when it was
  /// dropped is available in the [DraggableDetails]. Also included in the
  /// `details` is whether the draggable's [DragTargetMouse] accepted it.
  ///
  /// This function will only be called while this widget is still mounted to
  /// the tree (i.e. [State.mounted] is true).
  final DragEndCallback? onDragEnd;

  /// Whether the feedback widget will be put on the root [Overlay].
  ///
  /// When false, the feedback widget will be put on the closest [Overlay]. When
  /// true, the [feedback] widget will be put on the farthest (aka root)
  /// [Overlay].
  ///
  /// Defaults to false.
  final bool rootOverlay;

  /// How to behave during hit test.
  ///
  /// Defaults to [HitTestBehavior.deferToChild].
  final HitTestBehavior hitTestBehavior;

  /// Creates a gesture recognizer that recognizes the start of the drag.
  ///
  /// Subclasses can override this function to customize when they start
  /// recognizing a drag.
  @protected
  MultiDragGestureRecognizer createRecognizer(
      GestureMultiDragStartCallback onStart) {
    switch (affinity) {
      case Axis.horizontal:
        return HorizontalMultiDragGestureRecognizer()..onStart = onStart;
      case Axis.vertical:
        return VerticalMultiDragGestureRecognizer()..onStart = onStart;
      case null:
        return ImmediateMultiDragGestureRecognizer()..onStart = onStart;
    }
  }

  @override
  State<DraggableByMouse<T>> createState() => _DraggableByMouseState<T>();
}

class _DraggableByMouseState<T extends Object>
    extends State<DraggableByMouse<T>> {
  bool get horizontal => widget.axis == Axis.horizontal;
  // This gesture recognizer has an unusual lifetime. We want to support the use
  // case of removing the Draggable from the tree in the middle of a drag. That
  // means we need to keep this recognizer alive after this state object has
  // been disposed because it's the one listening to the pointer events that are
  // driving the drag.
  //
  // We achieve that by keeping count of the number of active drags and only
  // disposing the gesture recognizer after (a) this state object has been
  // disposed and (b) there are no more active drags.
  // GestureRecognizer? _recognizer;
  int _activeCount = 0;

  void _disposeRecognizerIfInactive() {
    if (_activeCount > 0) {
      return;
    }
    // _recognizer!.dispose();
    // _recognizer = null;
  }

  DragAvatar<T>? _avatar;

  DragAvatar<T>? _startDrag(Offset position) {
    if (widget.maxSimultaneousDrags != null &&
        _activeCount >= widget.maxSimultaneousDrags!) {
      return null;
    }

    final Offset dragStartPoint;
    dragStartPoint = widget.dragAnchorStrategy(widget, context, position);
    setState(() {
      _activeCount += 1;
    });
    final DragAvatar<T> avatar = DragAvatar<T>(
      overlayState: Overlay.of(context,
          debugRequiredFor: widget, rootOverlay: widget.rootOverlay),
      data: widget.data,
      dataMax: widget.dataMax,
      axis: widget.axis,
      size: (context.findRenderObject()! as RenderBox).size,
      initialPosition: position,
      dragStartPoint: dragStartPoint,
      feedback: widget.feedback,
      extendItemTop: widget.extendItemTop,
      extendItemBottom: widget.extendItemBottom,
      feedbackOffset: widget.feedbackOffset,
      ignoringFeedbackSemantics: widget.ignoringFeedbackSemantics,
      ignoringFeedbackPointer: widget.ignoringFeedbackPointer,
      onDragEnd: (Velocity velocity, Offset offset, bool wasAccepted) {
        if (mounted) {
          setState(() {
            _activeCount -= 1;
          });
        } else {
          _activeCount -= 1;
          _disposeRecognizerIfInactive();
        }
        if (mounted && widget.onDragEnd != null) {
          widget.onDragEnd!(DraggableDetails(
            wasAccepted: wasAccepted,
            velocity: velocity,
            offset: offset,
          ));
        }
        if (wasAccepted && widget.onDragCompleted != null) {
          widget.onDragCompleted!();
        }
        if (!wasAccepted && widget.onDraggableCanceled != null) {
          widget.onDraggableCanceled!(velocity, offset);
        }
      },
    );
    widget.onDragStarted?.call();
    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    final bool canDrag = widget.indexDraging != null &&
        widget.indexDraging != widget.data &&
        widget.currentDrag != null;
    final bool showChild =
        _activeCount == 0 || widget.childWhenDragging == null;
    if (canDrag) {
      return MouseRegion(
        onEnter: (event) {
          widget.currentDrag!.updatePos(context, widget.data);
        },
        child: showChild ? widget.child : widget.childWhenDragging,
      );
    }
    return GestureDetector(
      onTap: () {
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final Offset overlayTopLeft = box.localToGlobal(Offset.zero);
        _avatar = _startDrag(overlayTopLeft);
        widget.onChange(_avatar, widget.data);
      },
      child: showChild ? widget.child : widget.childWhenDragging,
    );
  }
}

/// Represents the details when a specific pointer event occurred on
/// the [DraggableByMouse].
///
/// This includes the [Velocity] at which the pointer was moving and [Offset]
/// when the draggable event occurred, and whether its [DragTargetMouse] accepted it.
///
/// Also, this is the details object for callbacks that use [DragEndCallback].
class DraggableDetails {
  /// Creates details for a [DraggableDetails].
  ///
  /// If [wasAccepted] is not specified, it will default to `false`.
  ///
  /// The [velocity] or [offset] arguments must not be `null`.
  DraggableDetails({
    this.wasAccepted = false,
    required this.velocity,
    required this.offset,
  });

  /// Determines whether the [DragTargetMouse] accepted this draggable.
  final bool wasAccepted;

  /// The velocity at which the pointer was moving when the specific pointer
  /// event occurred on the draggable.
  final Velocity velocity;

  /// The global position when the specific pointer event occurred on
  /// the draggable.
  final Offset offset;
}

/// Represents the details when a pointer event occurred on the [DragTargetMouse].
class DragTargetDetails<T> {
  /// Creates details for a [DragTargetMouse] callback.
  ///
  /// The [offset] must not be null.
  DragTargetDetails({required this.data, required this.offset});

  /// The data that was dropped onto this [DragTargetMouse].
  final T data;

  /// The global position when the specific pointer event occurred on
  /// the draggable.
  final Offset offset;
}

/// A widget that receives data when a [DraggableByMouse] widget is dropped.
///
/// When a draggable is dragged on top of a drag target, the drag target is
/// asked whether it will accept the data the draggable is carrying. If the user
/// does drop the draggable on top of the drag target (and the drag target has
/// indicated that it will accept the draggable's data), then the drag target is
/// asked to accept the draggable's data.
///
/// See also:
///
///  * [DraggableByMouse]
///  * [LongPressDraggable]
class DragTargetMouse<T extends Object> extends StatefulWidget {
  /// Creates a widget that receives drags.
  ///
  /// The [builder] argument must not be null.
  const DragTargetMouse({
    Key? key,
    required this.builder,
    this.onWillAccept,
    this.onAccept,
    this.onAcceptWithDetails,
    this.onLeave,
    this.onMove,
    this.hitTestBehavior = HitTestBehavior.translucent,
  }) : super(key: key);

  /// Called to build the contents of this widget.
  ///
  /// The builder can build different widgets depending on what is being dragged
  /// into this drag target.
  final DragTargetBuilder<T> builder;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  final DragTargetWillAccept<T>? onWillAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAcceptWithDetails], but only includes the data.
  final DragTargetAccept<T>? onAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  ///
  /// Equivalent to [onAccept], but with information, including the data, in a
  /// [DragTargetDetails].
  final DragTargetAcceptWithDetails<T>? onAcceptWithDetails;

  /// Called when a given piece of data being dragged over this target leaves
  /// the target.
  final DragTargetLeave<T>? onLeave;

  /// Called when a [DraggableByMouse] moves within this [DragTargetMouse].
  ///
  /// Note that this includes entering and leaving the target.
  final DragTargetMove<T>? onMove;

  /// How to behave during hit testing.
  ///
  /// Defaults to [HitTestBehavior.translucent].
  final HitTestBehavior hitTestBehavior;

  @override
  State<DragTargetMouse<T>> createState() => _DragTargetMouseState<T>();
}

List<T?> _mapAvatarsToData<T extends Object>(List<DragAvatar<Object>> avatars) {
  return avatars
      .map<T?>((DragAvatar<Object> avatar) => avatar.data as T?)
      .toList();
}

class _DragTargetMouseState<T extends Object>
    extends State<DragTargetMouse<T>> {
  final List<DragAvatar<Object>> _candidateAvatars = <DragAvatar<Object>>[];
  final List<DragAvatar<Object>> _rejectedAvatars = <DragAvatar<Object>>[];

  // On non-web platforms, checks if data Object is equal to type[T] or subtype of [T].
  // On web, it does the same, but requires a check for ints and doubles
  // because dart doubles and ints are backed by the same kind of object on web.
  // JavaScript does not support integers.
  bool isExpectedDataType(Object? data, Type type) {
    if (((type == int && T == double) || (type == double && T == int))) {
      return false;
    }
    return data is T?;
  }

  bool didEnter(DragAvatar<Object> avatar) {
    assert(!_candidateAvatars.contains(avatar));
    assert(!_rejectedAvatars.contains(avatar));
    if (widget.onWillAccept == null ||
        widget.onWillAccept!(avatar.data as T?)) {
      setState(() {
        _candidateAvatars.add(avatar);
      });
      return true;
    } else {
      setState(() {
        _rejectedAvatars.add(avatar);
      });
      return false;
    }
  }

  void didLeave(DragAvatar<Object> avatar) {
    assert(_candidateAvatars.contains(avatar) ||
        _rejectedAvatars.contains(avatar));
    if (!mounted) {
      return;
    }
    setState(() {
      _candidateAvatars.remove(avatar);
      _rejectedAvatars.remove(avatar);
    });
    widget.onLeave?.call(avatar.data as T?);
  }

  void didDrop(DragAvatar<Object> avatar) {
    assert(_candidateAvatars.contains(avatar));
    if (!mounted) {
      return;
    }
    setState(() {
      _candidateAvatars.remove(avatar);
    });
    widget.onAccept?.call(avatar.data! as T);
    widget.onAcceptWithDetails?.call(DragTargetDetails<T>(
        data: avatar.data! as T, offset: avatar._lastOffset!));
  }

  void didMove(DragAvatar<Object> avatar) {
    if (!mounted) {
      return;
    }
    widget.onMove?.call(DragTargetDetails<T>(
        data: avatar.data! as T, offset: avatar._lastOffset!));
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      behavior: widget.hitTestBehavior,
      child: widget.builder(context, _mapAvatarsToData<T>(_candidateAvatars),
          _mapAvatarsToData<Object>(_rejectedAvatars)),
    );
  }
}

enum _DragEndKind { dropped, canceled }

typedef _OnDragEnd = void Function(
    Velocity velocity, Offset offset, bool wasAccepted);

// The lifetime of this object is a little dubious right now. Specifically, it
// lives as long as the pointer is down. Arguably it should self-immolate if the
// overlay goes away. _DraggableState has some delicate logic to continue
// needing this object pointer events even after it has been disposed.
class DragAvatar<T extends Object> {
  DragAvatar({
    required this.overlayState,
    this.data,
    this.dataMax,
    this.axis,
    required this.size,
    required Offset initialPosition,
    this.dragStartPoint = Offset.zero,
    this.feedback,
    this.extendItemTop,
    this.extendItemBottom,
    this.feedbackOffset = Offset.zero,
    this.onDragEnd,
    required this.ignoringFeedbackSemantics,
    required this.ignoringFeedbackPointer,
  })  : _position = initialPosition,
        _prePosition = initialPosition {
    _entry = OverlayEntry(builder: _build);
    overlayState.insert(_entry!);
    _updateDrag(initialPosition);
  }

  final T? data;
  final T? dataMax;
  T? _current;
  T? _currentByKey;
  final Axis? axis;
  final Size size;
  final Offset dragStartPoint;
  final Widget? feedback;
  final Widget? extendItemTop;
  final Widget? extendItemBottom;
  final Offset feedbackOffset;
  final _OnDragEnd? onDragEnd;
  final OverlayState overlayState;
  final bool ignoringFeedbackSemantics;
  final bool ignoringFeedbackPointer;

  _DragTargetMouseState<Object>? _activeTarget;
  final List<_DragTargetMouseState<Object>> _enteredTargets =
      <_DragTargetMouseState<Object>>[];
  Offset _position;
  Offset _prePosition;
  Offset? _lastOffset;
  OverlayEntry? _entry;
  bool _isDraging = false;

  // update new position of draging item
  // bool get _isDrapUp => _prePosition.dy > _position.dy;
  void _update(Offset newPosistion) {
    _prePosition = _position;
    _position = newPosistion;
    _updateDrag(_position);
  }

  void end(DragEndDetails details) {
    finishDrag(_DragEndKind.dropped, _restrictVelocityAxis(details.velocity));
  }

  void enDrag() {
    finishDrag(_DragEndKind.dropped);
  }

  void cancel() {
    finishDrag(_DragEndKind.canceled);
  }

  void _updateDrag(Offset globalPosition) {
    _lastOffset = globalPosition - dragStartPoint;
    _entry!.markNeedsBuild();
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTest(result, globalPosition + feedbackOffset);

    final List<_DragTargetMouseState<Object>> targets =
        _getDragTargets(result.path).toList();

    // Leave old targets.
    _leaveAllEntered();

    // Enter new targets.
    final _DragTargetMouseState<Object>? newTarget =
        targets.cast<_DragTargetMouseState<Object>?>().firstWhere(
      (_DragTargetMouseState<Object>? target) {
        if (target == null) {
          return false;
        }
        _enteredTargets.add(target);
        return target.didEnter(this);
      },
      orElse: () => null,
    );

    // Report moves to the targets.
    for (final _DragTargetMouseState<Object> target in _enteredTargets) {
      target.didMove(this);
    }

    _activeTarget = newTarget;
    _isDraging = false;
  }

  Iterable<_DragTargetMouseState<Object>> _getDragTargets(
      Iterable<HitTestEntry> path) {
    // Look for the RenderBoxes that corresponds to the hit target (the hit target
    // widgets build RenderMetaData boxes for us for this purpose).
    final List<_DragTargetMouseState<Object>> targets =
        <_DragTargetMouseState<Object>>[];
    for (final HitTestEntry entry in path) {
      final HitTestTarget target = entry.target;
      if (target is RenderMetaData) {
        final dynamic metaData = target.metaData;
        if (metaData is _DragTargetMouseState &&
            metaData.isExpectedDataType(data, T)) {
          targets.add(metaData);
        }
      }
    }
    return targets;
  }

  void _leaveAllEntered() {
    for (int i = 0; i < _enteredTargets.length; i += 1) {
      _enteredTargets[i].didLeave(this);
    }
    _enteredTargets.clear();
  }

  void finishDrag(_DragEndKind endKind, [Velocity? velocity]) {
    bool wasAccepted = false;
    if (endKind == _DragEndKind.dropped && _activeTarget != null) {
      _activeTarget!.didDrop(this);
      wasAccepted = true;
      _enteredTargets.remove(_activeTarget);
    }
    _leaveAllEntered();
    _activeTarget = null;
    _entry!.remove();
    _entry = null;
    // (ianh): consider passing _entry as well so the client can perform an animation.
    onDragEnd?.call(velocity ?? Velocity.zero, _lastOffset!, wasAccepted);
  }

  // cần cập nhật chính xác vị trí của item mới
  Widget _build(BuildContext context) {
    if (horizontal) {
      return Positioned(
        left: horizontal ? _position.dx : _position.dx + 50,
        top: horizontal ? _position.dy - 50 : _position.dy,
        child: IgnorePointer(
          ignoring: ignoringFeedbackPointer,
          ignoringSemantics: ignoringFeedbackSemantics,
          child: feedback,
        ),
      );
    }
    return Positioned(
      left: horizontal ? _position.dx : _position.dx + 50,
      top: horizontal ? _position.dy - 50 : _position.dy,
      child: IgnorePointer(
        ignoring: ignoringFeedbackPointer,
        ignoringSemantics: ignoringFeedbackSemantics,
        child: Stack(
          children: [
            if (feedback != null) feedback!,
            if (_extendItemTop != null) _extendItemTop!,
            if (_extendItemBottom != null) _extendItemBottom!
          ],
        ),
      ),
    );
  }

  bool get _isDrapUp => _prePosition.dy > _position.dy;

  //  2 case:
  //  1. handle by mouse => check _current index
  //  2. handle by keyboard arrow => check _currentByKey
  Widget? get _extendItemTop {
    if (extendItemTop != null) {
      if (_currentByKey != null) {
        if (_currentByKey != 0) {
          return extendItemTop;
        }
      } else {
        if (data == 0) {
          if (_current == null || _current == 0) {
            return null;
          } else if (_current == 1 && !_isDrapUp) {
            return extendItemTop;
          } else if (_current != 1) {
            return extendItemTop;
          }
        } else if (data != 0) {
          if (_current == 0) {
            if (_isDrapUp) {
              return null;
            }
            return extendItemTop;
          }
          return extendItemTop;
        } else if (data == dataMax) {
          if (_current == null) {
            return extendItemTop;
          } else if (_current == ((dataMax! as int) - 1) && _isDrapUp) {
            return extendItemTop;
          } else if (_current != ((dataMax! as int) - 1)) {
            return extendItemTop;
          }
        }
      }
    }
    return null;
  }

  //  2 case:
  //  1. handle by mouse => check _current index
  //  2. handle by keyboard arrow => check _currentByKey
  Widget? get _extendItemBottom {
    if (extendItemBottom != null) {
      if (_currentByKey != null) {
        if (_currentByKey != dataMax) {
          return extendItemBottom;
        }
      } else {
        if (data == dataMax) {
          if (_current == null) {
            return null;
          } else if (_current == ((dataMax! as int) - 1) && !_isDrapUp) {
            return null;
          } else {
            return extendItemBottom;
          }
        } else if (data != 0) {
          if (_current == dataMax && !_isDrapUp) {
            return null;
          } else if (_current == 0) {
            return extendItemBottom;
          }
          return extendItemBottom;
        } else if (data == 0) {
          if (_current == null) {
            return extendItemBottom;
          } else if (_current == dataMax && _isDrapUp) {
            return extendItemBottom;
          } else if (_current != dataMax) {
            return extendItemBottom;
          }
        }
      }
    }
    return null;
  }

  Velocity _restrictVelocityAxis(Velocity velocity) {
    if (axis == null) {
      return velocity;
    }
    return Velocity(
      pixelsPerSecond: _restrictAxis(velocity.pixelsPerSecond),
    );
  }

  bool get horizontal => axis == Axis.horizontal;

  Offset _restrictAxis(Offset offset) {
    if (axis == null) {
      return offset;
    }
    if (axis == Axis.horizontal) {
      return Offset(offset.dx, 0.0);
    }
    return Offset(0.0, offset.dy);
  }

  // handle update new positon by mouse
  // reset _currentByKey
  // update _current = current index
  void updatePos(BuildContext context, T? pos) {
    if (!_isDraging) {
      _isDraging = true;
      _current = pos;
      _currentByKey = null;
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final Offset overlayTopLeft = box.localToGlobal(Offset.zero);
      _update(overlayTopLeft);
    }
  }

//handle keyboard arrowDown
  void onNext(double max) {
    if (horizontal) {
      if ((_position.dx + size.width * 2) <= max) {
        if (!_isDraging) {
          _isDraging = true;
          _update(Offset(_position.dx + size.width, _position.dy));
        }
      }
    } else {
      if ((_position.dy + size.height * 2) <= max) {
        if (!_isDraging) {
          _isDraging = true;
          if (_currentByKey == null) {
            _currentByKey = ((data as int) + 1) as T?;
          } else {
            _currentByKey = ((_currentByKey as int) + 1) as T?;
          }
          final newPos = Offset(_position.dx, _position.dy + size.height);
          _update(newPos);
        }
      }
    }
  }

//handle keyboardarrowUp
  void onPre(BuildContext context) {
    if (horizontal) {
      if (_position.dx >= size.width) {
        if (!_isDraging) {
          _isDraging = true;
          _update(Offset(_position.dx - size.width, _position.dy));
        }
      }
    } else {
      final RenderBox box = context.findRenderObject()! as RenderBox;
      final Offset offsetParent = box.localToGlobal(Offset.zero);
      if (_position.dy >= size.height && _position.dy > offsetParent.dy) {
        if (!_isDraging) {
          _isDraging = true;
          if (_currentByKey == null) {
            _currentByKey = ((data as int) - 1) as T?;
          } else {
            _currentByKey = ((_currentByKey as int) - 1) as T?;
          }
          final newPos = Offset(_position.dx, _position.dy - size.height);
          _update(newPos);
        }
      }
    }
  }

  // update position when auto scroll
  void updateOfset(double ofset) {
    if (horizontal) {
      _update(Offset(_position.dx - ofset, _position.dy));
    } else {
      _update(Offset(_position.dx, _position.dy - ofset));
    }
  }
}
