// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import './passthrough_overlay.dart';
import './reorderable_mixin.dart';
import './typedefs.dart';
import 'convert_drag_to_tap.dart';
import 'utils.dart';

/// Reorderable (drag and drop) version of [Flex], a widget that displays its
/// draggable children in a one-dimensional array.
///
/// The [ReorderableFlex] widget has allows you to control the axis along which
/// the children are placed (horizontal or vertical). This is referred to as the
/// [direction]. If you know the main axis in advance, then consider using
/// a [ReorderableRow] (if it's horizontal) or [ReorderableColumn] (if it's
/// vertical) instead, because that will be less verbose.
///
/// In addition to other parameters in [Flex]'s constructor, this widget also
/// has [header] and [footer] for placing non-reorderable widgets at the
/// top/left and bottom/right of the widget. If further control is needed, you
/// can use [buildItemsContainer] to customize how each item is contained, or
/// use [buildDraggableFeedback] to customize the [feedback] of the internal
/// [LongPressDraggable]. Consider using [ReorderableRow] or [ReorderableColumn]
/// instead using this widget directly.
///
/// All [children] must have a key.
///
/// See also:
///
///  * [ReorderableRow], for a version of this widget that is always horizontal.
///  * [ReorderableColumn], for a version of this widget that is always vertical.
class ReorderableFlex extends StatefulWidget {
  /// Creates a reorderable list.
  ReorderableFlex({
    Key? key,
    this.header,
    this.footer,
    this.extendItemTop,
    this.extendItemBottom,
    required this.children,
    required this.onReorder,
    required this.direction,
    this.marginLeftDragingItem,
    this.maringBottomDragingItem,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.buildItemsContainer,
    this.buildDraggableFeedback,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.onNoReorder,
    this.onReorderStarted,
    this.scrollController,
    this.draggingWidgetOpacity = 0.2,
    this.reorderAnimationDuration,
    this.scrollAnimationDuration,
    this.draggedItemBuilder,
    this.ignorePrimaryScrollController = false,
    this.physics,
    this.controller,
  })  : assert(
          children.every((Widget w) => w.key != null),
          'All children of this widget must have a key.',
        ),
        super(key: key);
  final ReorderableController? controller;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// A non-reorderable header widget to show before the list.
  ///
  /// If null, no header will appear at the top/left of the widget.
  final Widget? header;

  final Widget Function(BuildContext context, int index)? draggedItemBuilder;

  /// A non-reorderable footer widget to show after the list.
  ///
  /// If null, no footer will appear at the bottom/right of the widget.
  final Widget? footer;

  // only for vertical
  final Widget? extendItemTop;
  // only for vertical
  final Widget? extendItemBottom;
  // only for vertical
  final double? marginLeftDragingItem;
  // only for horizontal
  final double? maringBottomDragingItem;

  /// The widgets to display.
  final List<Widget> children;

  /// The [Axis] along which the list scrolls.
  ///
  /// List [children] can only drag along this [Axis].
  final Axis direction;
  final Axis scrollDirection;
  final ScrollController? scrollController;

  /// The amount of space by which to inset the [children].
  final EdgeInsets? padding;

  /// Called when a child is dropped into a new position to shuffle the
  /// children.
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;

  /// Called when the draggable starts being dragged.
  final ReorderStartedCallback? onReorderStarted;

  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;

  final MainAxisAlignment mainAxisAlignment;

  final double draggingWidgetOpacity;

  final Duration? reorderAnimationDuration;
  final Duration? scrollAnimationDuration;
  final bool ignorePrimaryScrollController;

  @override
  State<ReorderableFlex> createState() => _ReorderableFlexState();
}

// This top-level state manages an Overlay that contains the list and
// also any Draggables it creates.
//
// _ReorderableListContent manages the list itself and reorder operations.
//
// The Overlay doesn't properly keep state by building new overlay entries,
// and so we cache a single OverlayEntry for use as the list layer.
// That overlay entry then builds a _ReorderableListContent which may
// insert Draggables into the Overlay above itself.
class _ReorderableFlexState extends State<ReorderableFlex> {
  // We use an inner overlay so that the dragging list item doesn't draw outside of the list itself.
  final GlobalKey _overlayKey =
      GlobalKey(debugLabel: '$ReorderableFlex overlay key');

  // This entry contains the scrolling list itself.
  late PassthroughOverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = PassthroughOverlayEntry(
      opaque: false,
      builder: (BuildContext context) {
        return _ReorderableFlexContent(
          header: widget.header,
          footer: widget.footer,
          direction: widget.direction,
          scrollDirection: widget.scrollDirection,
          onReorder: widget.onReorder,
          onNoReorder: widget.onNoReorder,
          onReorderStarted: widget.onReorderStarted,
          padding: widget.padding,
          extendItemTop: widget.extendItemTop,
          extendItemBottom: widget.extendItemBottom,
          buildItemsContainer: widget.buildItemsContainer,
          buildDraggableFeedback: widget.buildDraggableFeedback,
          mainAxisAlignment: widget.mainAxisAlignment,
          scrollController: widget.scrollController,
          draggingWidgetOpacity: widget.draggingWidgetOpacity,
          physics: widget.physics,
          controller: widget.controller,
          draggedItemBuilder: widget.draggedItemBuilder,
          marginLeftDragingItem: widget.marginLeftDragingItem,
          maringBottomDragingItem: widget.maringBottomDragingItem,
          reorderAnimationDuration: widget.reorderAnimationDuration ??
              const Duration(milliseconds: 200),
          scrollAnimationDuration: widget.scrollAnimationDuration ??
              const Duration(milliseconds: 200),
          children: widget.children,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final PassthroughOverlay passthroughOverlay = PassthroughOverlay(
        key: _overlayKey,
        initialEntries: <PassthroughOverlayEntry>[
          _listOverlayEntry,
        ]);
    return widget.ignorePrimaryScrollController
        ? PrimaryScrollController.none(child: passthroughOverlay)
        : passthroughOverlay;
  }
}

// This widget is responsible for the inside of the Overlay in the
// ReorderableFlex.
class _ReorderableFlexContent extends StatefulWidget {
  const _ReorderableFlexContent({
    this.header,
    this.footer,
    this.extendItemTop,
    this.extendItemBottom,
    required this.children,
    required this.direction,
    required this.scrollDirection,
    required this.onReorder,
    required this.onNoReorder,
    required this.onReorderStarted,
    required this.mainAxisAlignment,
    required this.scrollController,
    required this.draggingWidgetOpacity,
    required this.buildItemsContainer,
    required this.buildDraggableFeedback,
    required this.padding,
    this.draggedItemBuilder,
    this.reorderAnimationDuration = const Duration(milliseconds: 100),
    this.scrollAnimationDuration = const Duration(milliseconds: 100),
    this.physics,
    this.controller,
    this.marginLeftDragingItem,
    this.maringBottomDragingItem,
  });

  final Widget? header;
  final Widget? footer;
  final Widget? extendItemTop;
  final Widget? extendItemBottom;
  final List<Widget> children;
  final Axis direction;
  final Axis scrollDirection;
  final ReorderCallback onReorder;
  final NoReorderCallback? onNoReorder;
  final ReorderStartedCallback? onReorderStarted;
  final BuildItemsContainer? buildItemsContainer;
  final BuildDraggableFeedback? buildDraggableFeedback;
  final ScrollController? scrollController;
  final EdgeInsets? padding;
  final Widget Function(BuildContext context, int index)? draggedItemBuilder;

  final MainAxisAlignment mainAxisAlignment;
  final double draggingWidgetOpacity;
  final Duration reorderAnimationDuration;
  final Duration scrollAnimationDuration;
  final ScrollPhysics? physics;
  final ReorderableController? controller;
  // only for vertical
  final double? marginLeftDragingItem;
  // only for horizontal
  final double? maringBottomDragingItem;

  @override
  _ReorderableFlexContentState createState() => _ReorderableFlexContentState();
}

class _ReorderableFlexContentState extends State<_ReorderableFlexContent>
    with TickerProviderStateMixin<_ReorderableFlexContent>, ReorderableMixin {
  // The extent along the [widget.scrollDirection] axis to allow a child to
  // drop into when the user reorders list children.
  //
  // This value is used when the extents haven't yet been calculated from
  // the currently dragging widget, such as when it first builds.
//  static const double _defaultDropAreaExtent = 1.0;

  // The additional margin to place around a computed drop area.
  static const double _dropAreaMargin = 0.0;

  // How long an animation to reorder an element in the list takes.
  late Duration _reorderAnimationDuration;

  // How long an animation to scroll to an off-screen element in the
  // list takes.
  late Duration _scrollAnimationDuration;

  // Controls scrolls and measures scroll progress.
  late ScrollController _scrollController;
  ScrollPosition? _attachedScrollPosition;

  // This controls the entrance of the dragging widget into a new place.
  late AnimationController _entranceController;

  // This controls the 'ghost' of the dragging widget, which is left behind
  // where the widget used to be.
  late AnimationController _ghostController;

  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
  Widget? _draggingWidget;

  // The last computed size of the feedback widget being dragged.
  Size? _draggingFeedbackSize = const Size(0, 0);

  // The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = -1;

  // The index that the dragging widget most recently left.
  // This is used to show an animation of the widget's position.
  int _ghostIndex = -1;

  // The index that the dragging widget currently occupies.
  int _currentIndex = -1;

  // The widget to move the dragging widget too after the current index.
  int _nextIndex = 0;

  // Whether or not we are currently scrolling this view to show a widget.
  bool _scrolling = false;

//  final GlobalKey _contentKey = GlobalKey(debugLabel: '$ReorderableFlex content key');

  Size get _dropAreaSize {
    if (_draggingFeedbackSize == null) {
      return const Size(0, 0);
    }
    return _draggingFeedbackSize! +
        const Offset(_dropAreaMargin, _dropAreaMargin);
//    double dropAreaWithoutMargin;
//    switch (widget.direction) {
//      case Axis.horizontal:
//        dropAreaWithoutMargin = _draggingFeedbackSize.width;
//        break;
//      case Axis.vertical:
//      default:
//        dropAreaWithoutMargin = _draggingFeedbackSize.height;
//        break;
//    }
//    return dropAreaWithoutMargin + _dropAreaMargin;
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.stopReorder = stopReorder;
    _reorderAnimationDuration = widget.reorderAnimationDuration;
    _scrollAnimationDuration = widget.scrollAnimationDuration;
    _entranceController = AnimationController(
        value: 1.0, vsync: this, duration: _reorderAnimationDuration);
    _ghostController = AnimationController(
        value: 0, vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);
  }

  @override
  void didChangeDependencies() {
    if (_attachedScrollPosition != null) {
      _scrollController.detach(_attachedScrollPosition!);
      _attachedScrollPosition = null;
    }

    _scrollController = widget.scrollController ??
        PrimaryScrollController.maybeOf(context) ??
        ScrollController();

    if (_scrollController.hasClients) {
      _attachedScrollPosition = Scrollable.maybeOf(context)?.position;
    } else {
      _attachedScrollPosition = null;
    }

    if (_attachedScrollPosition != null) {
      _scrollController.attach(_attachedScrollPosition!);
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (_attachedScrollPosition != null) {
      _scrollController.detach(_attachedScrollPosition!);
      _attachedScrollPosition = null;
    }
    _entranceController.dispose();
    _ghostController.dispose();
    stopReorder();
    super.dispose();
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex({bool isAcceptingNewTarget = false}) {
//    debugPrint('${DateTime.now().toString().substring(5, 22)} reorderable_flex.dart(285) $this._requestAnimationToNextIndex: '
//      '_dragStartIndex:$_dragStartIndex _ghostIndex:$_ghostIndex _currentIndex:$_currentIndex _nextIndex:$_nextIndex isAcceptingNewTarget:$isAcceptingNewTarget isCompleted:${_entranceController.isCompleted}');

    if (_entranceController.isCompleted) {
      _ghostIndex = _currentIndex;
      if (!isAcceptingNewTarget && _nextIndex == _currentIndex) {
        // && _dragStartIndex == _ghostIndex
        return;
      }

      _currentIndex = _nextIndex;
      _ghostController.reverse(from: 1.0);
      _entranceController.forward(from: 0.0);
    }
  }

  // Requests animation to the latest next index if it changes during an animation.
  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _requestAnimationToNextIndex();
      });
    }
  }

  // Scrolls to a target context if that context is not on the screen.
  void _scrollTo(BuildContext context) async {
    if (_scrolling) return;
    final RenderObject contextObject = context.findRenderObject()!;
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(contextObject);
    // If and only if the current scroll offset falls in-between the offsets
    // necessary to reveal the selected context at the top or bottom of the
    // screen, then it is already on-screen.
    final double margin = widget.direction == Axis.horizontal
        ? _dropAreaSize.width
        : _dropAreaSize.height;
    if (_scrollController.hasClients) {
      final double scrollOffset = _scrollController.offset;
      final double topOffset = max(
        _scrollController.position.minScrollExtent,
        viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
      );
      final double bottomOffset = min(
        _scrollController.position.maxScrollExtent,
        viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
      );
      final bool onScreen =
          scrollOffset <= topOffset && scrollOffset >= bottomOffset;

      // If the context is off screen, then we request a scroll to make it visible.
      if (!onScreen) {
        _scrolling = true;
        final ofset = scrollOffset < bottomOffset ? bottomOffset : topOffset;
        _scrollController.position
            .animateTo(
          ofset,
          duration: _scrollAnimationDuration,
          curve: Curves.easeInOut,
        )
            .then((void value) {
          if (_currentDrag != null) {
            _currentDrag!.updateOfset(ofset - scrollOffset);
          }
          setState(() {
            _scrolling = false;
          });
        });
      }
    }
  }

  void stopReorder() {
    _currentDrag?.enDrag();
    _currentDrag = null;
    _indexDraging = null;
  }

  // Wraps children in Row or Column, so that the children flow in
  // the widget's scrollDirection.
  Widget _buildContainerForMainAxis({required List<Widget> children}) {
    switch (widget.direction) {
      case Axis.horizontal:
        return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.mainAxisAlignment,
            children: children);
      case Axis.vertical:
      default:
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: widget.mainAxisAlignment,
            children: children);
    }
  }

  // Wraps one of the widget's children in a DragTarget and Draggable.
  // Handles up the logic for dragging and reordering items in the list.
  Widget _wrap(Widget toWrap, int index) {
    assert(toWrap.key != null);
    final GlobalObjectKey keyIndexGlobalKey = GlobalObjectKey(toWrap.key!);
    // We pass the toWrapWithGlobalKey into the Draggable so that when a list
    // item gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.

    final draggedItem =
        widget.draggedItemBuilder?.call(context, index) ?? toWrap;

    // Starts dragging toWrap.

    // Places the value from startIndex one space before the element at endIndex.
    void reorderIndex(int startIndex, int endIndex) {
//      debugPrint('startIndex:$startIndex endIndex:$endIndex');
      if (startIndex != endIndex) {
        widget.onReorder(startIndex, endIndex);
      } else if (widget.onNoReorder != null) {
        widget.onNoReorder!(startIndex);
      }
      // Animates leftover space in the drop area closed.
      // (djshuckerow): bring the animation in line with the Material
      // specifications.
      _ghostController.reverse(from: 0.1);
      _entranceController.reverse(from: 0);
    }

    void reorder(int startIndex, int endIndex) {
//      debugPrint('startIndex:$startIndex endIndex:$endIndex');
      setState(() {
        reorderIndex(startIndex, endIndex);
      });
    }

    // Drops toWrap into the last position it was hovering over.
    void onDragEnded() {
//      reorder(_dragStartIndex, _currentIndex);
      if (widget.controller?.notifyDrag != null) {
        widget.controller?.notifyDrag(false);
      }

      setState(() {
        reorderIndex(_dragStartIndex, _currentIndex);
        _dragStartIndex = -1;
        _ghostIndex = -1;
        _currentIndex = -1;
        _draggingWidget = null;
      });
    }

    void onDragStarted() {
      if (widget.controller?.notifyDrag != null) {
        widget.controller?.notifyDrag(true);
      }
      setState(() {
        _draggingWidget = GestureDetector(
          onTap: stopReorder,
          child: draggedItem,
        );
        _dragStartIndex = index;
        _ghostIndex = index;
        _currentIndex = index;
        _entranceController.value = 1.0;
        _draggingFeedbackSize = keyIndexGlobalKey.currentContext?.size;
      });

      widget.onReorderStarted?.call(index);
    }

    Widget wrapWithSemantics() {
      // First, determine which semantics actions apply.
      final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
          <CustomSemanticsAction, VoidCallback>{};

      // Create the appropriate semantics actions.
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length - 1);
      void moveBefore() => reorder(index, index - 1);
      // To move after, we go to index+2 because we are moving it to the space
      // before index+2, which is after the space at index+1.
      void moveAfter() => reorder(index, index + 2);

      final MaterialLocalizations localizations =
          MaterialLocalizations.of(context);

      if (index > 0) {
        semanticsActions[CustomSemanticsAction(
            label: localizations.reorderItemToStart)] = moveToStart;
        String reorderItemBefore = localizations.reorderItemUp;
        if (widget.direction == Axis.horizontal) {
          reorderItemBefore = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemLeft
              : localizations.reorderItemRight;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
            moveBefore;
      }

      // If the item can move to after its current position in the list.
      if (index < widget.children.length - 1) {
        String reorderItemAfter = localizations.reorderItemDown;
        if (widget.direction == Axis.horizontal) {
          reorderItemAfter = Directionality.of(context) == TextDirection.ltr
              ? localizations.reorderItemRight
              : localizations.reorderItemLeft;
        }
        semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
            moveAfter;
        semanticsActions[
                CustomSemanticsAction(label: localizations.reorderItemToEnd)] =
            moveToEnd;
      }

      // We pass toWrap with a GlobalKey into the Draggable so that when a list
      // item gets dragged, the accessibility framework can preserve the selected
      // state of the dragging item.
      //
      // We also apply the relevant custom accessibility actions for moving the item
      // up, down, to the start, and to the end of the list.
      return MergeSemantics(
        child: Semantics(
          customSemanticsActions: semanticsActions,
          child: toWrap,
        ),
      );
//      return KeyedSubtree(
//        key: keyIndexGlobalKey,
//        child: MergeSemantics(
//          child: Semantics(
//            customSemanticsActions: semanticsActions,
//            child: toWrap,
//          ),
//        ),
//      );
    }

    Widget appearingWidget(Widget child) {
      return makeAppearingWidget(
        child,
        _entranceController,
        _draggingFeedbackSize,
        widget.direction,
      );
    }

    Widget disappearingWidget(Widget child) {
      return makeDisappearingWidget(
        child,
        _ghostController,
        _draggingFeedbackSize,
        widget.direction,
      );
    }

    Widget buildDragTarget(BuildContext context, List<int?> acceptedCandidates,
        List<dynamic> rejectedCandidates) {
      final Widget toWrapWithSemantics = wrapWithSemantics();

      Widget feedbackBuilder = Builder(builder: (BuildContext context) {
        BoxConstraints contentSizeConstraints =
            BoxConstraints.loose(_draggingFeedbackSize!);
        return (widget.buildDraggableFeedback ?? defaultBuildDraggableFeedback)(
            context, contentSizeConstraints, draggedItem);
      });

      // We build the draggable inside of a layout builder so that we can
      // constrain the size of the feedback dragging widget.

      Widget child = DraggableByMouse<int>(
        maxSimultaneousDrags: 1,
        axis: widget.direction,
        data: index,
        dataMax: widget.children.length - 1,
        ignoringFeedbackSemantics: false,
        extendItemBottom: widget.extendItemBottom,
        extendItemTop: widget.extendItemTop,
        marginLeftDragingItem: widget.marginLeftDragingItem,
        maringBottomDragingItem: widget.maringBottomDragingItem,
        feedback: feedbackBuilder,
        currentDrag: _currentDrag,
        indexDraging: _indexDraging,
        onChange: (value, indexV) {
          setState(() {
            value!.setMaxMin(topValue: _top, bottomValue: _bottom);
            _currentDrag = value;
            _indexDraging = indexV;
          });
        },
        childWhenDragging: IgnorePointer(
          ignoring: true,
          child: Opacity(
            opacity: 0,
            child: SizedBox(
              width: 0,
              height: 0,
              child: toWrap,
            ),
          ),
        ),
        onDragStarted: onDragStarted,
        // dragAnchorStrategy: childDragAnchorStrategy,
        // When the drag ends inside a DragTarget widget, the drag
        // succeeds, and we reorder the widget into position appropriately.
        onDragCompleted: onDragEnded,
        // When the drag does not end inside a DragTarget widget, the
        // drag fails, but we still reorder the widget to the last position it
        // had been dragged to.
        onDraggableCanceled: (Velocity velocity, Offset offset) =>
            onDragEnded(),
        // Wrap toWrapWithSemantics with a widget that supports HitTestBehavior
        // to make sure the whole toWrapWithSemantics responds to pointer events, i.e. dragging
        child: MetaData(
          behavior: HitTestBehavior.opaque,
          child: toWrapWithSemantics,
        ),
      );

      // The target for dropping at the end of the list doesn't need to be
      // draggable.
      if (index >= widget.children.length) {
        child = toWrap;
      }
      return child;
    }

    // We wrap the drag target in a Builder so that we can scroll to its specific context.
    return Builder(builder: (BuildContext context) {
      Widget dragTarget = DragTargetMouse<int>(
        builder: buildDragTarget,
        onWillAccept: (int? toAccept) {
          if (_moveByKey) {
            _scrollTo(context);
            _moveByKey = false;
          }
          bool willAccept = _dragStartIndex == toAccept && toAccept != index;

          setState(() {
            if (willAccept) {
              int shiftedIndex = index;
              if (index == _dragStartIndex) {
                shiftedIndex = _ghostIndex;
              } else if (index > _dragStartIndex && index <= _ghostIndex) {
                shiftedIndex--;
              } else if (index < _dragStartIndex && index >= _ghostIndex) {
                shiftedIndex++;
              }
              _nextIndex = shiftedIndex;
            } else {
              _nextIndex = index;
            }
            _requestAnimationToNextIndex(isAcceptingNewTarget: true);
          });

          // If the target is not the original starting point, then we will accept the drop.
          debugPrint('willAccept $willAccept');
          return willAccept; //_dragging == toAccept && toAccept != toWrap.key;
        },
        onAccept: (int accepted) {
          debugPrint('onAccept $accepted');
        },
        onLeave: (Object? leaving) {
          debugPrint('onLeave $leaving');
        },
      );

      dragTarget = KeyedSubtree(key: keyIndexGlobalKey, child: dragTarget);

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing = _draggingWidget == null
          ? SizedBox.fromSize(size: _dropAreaSize)
          : Opacity(
              opacity: widget.draggingWidgetOpacity, child: _draggingWidget);
//      Widget spacing = SizedBox.fromSize(
//        size: _dropAreaSize,
//        child: _draggingWidget != null ? Opacity(opacity: 0.2, child: _draggingWidget) : null,
//      );
      // We open up a space under where the dragging widget currently is to
      // show it can be dropped.
      int shiftedIndex = index;
      if (_currentIndex != _ghostIndex) {
        if (index == _dragStartIndex) {
          shiftedIndex = _ghostIndex;
        } else if (index > _dragStartIndex && index <= _ghostIndex) {
          shiftedIndex--;
        } else if (index < _dragStartIndex && index >= _ghostIndex) {
          shiftedIndex++;
        }
      }

      if (shiftedIndex == _currentIndex || index == _ghostIndex) {
        Widget entranceSpacing = appearingWidget(spacing);
        Widget ghostSpacing = disappearingWidget(spacing);

        if (_dragStartIndex == -1) {
          return _buildContainerForMainAxis(children: [dragTarget]);
        } else if (_currentIndex > _ghostIndex) {
          //the ghost is moving down, i.e. the tile below the ghost is moving up
//          debugPrint('index:$index item moving up / ghost moving down');
          if (shiftedIndex == _currentIndex && index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: [ghostSpacing, dragTarget, entranceSpacing]);
          } else if (shiftedIndex == _currentIndex) {
            return _buildContainerForMainAxis(
                children: [dragTarget, entranceSpacing]);
          } else if (index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: shiftedIndex <= index
                    ? [dragTarget, ghostSpacing]
                    : [ghostSpacing, dragTarget]);
          }
        } else if (_currentIndex < _ghostIndex) {
          //the ghost is moving up, i.e. the tile above the ghost is moving down
//          debugPrint('index:$index item moving down / ghost moving up');
          if (shiftedIndex == _currentIndex && index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: [entranceSpacing, dragTarget, ghostSpacing]);
          } else if (shiftedIndex == _currentIndex) {
            return _buildContainerForMainAxis(
                children: [entranceSpacing, dragTarget]);
          } else if (index == _ghostIndex) {
            return _buildContainerForMainAxis(
                children: shiftedIndex >= index
                    ? [ghostSpacing, dragTarget]
                    : [dragTarget, ghostSpacing]);
          }
        } else {
          return _buildContainerForMainAxis(
              children: _dragStartIndex < _currentIndex
                  ? [dragTarget, entranceSpacing]
                  : [entranceSpacing, dragTarget]);
        }
      }

      //we still wrap dragTarget with a container so that widget's depths are the same and it prevent's layout alignment issue
      return _buildContainerForMainAxis(children: [dragTarget]);
    });
  }

  DragAvatar<Object>? _currentDrag;
  int? _indexDraging;

  @override
  Widget build(BuildContext context) {
    final List<Widget> wrappedChildren = <Widget>[];
    if (widget.header != null) {
      wrappedChildren.add(widget.header!);
    }
    for (int i = 0; i < widget.children.length; i += 1) {
      wrappedChildren.add(_wrap(widget.children[i], i));
    }
    if (widget.footer != null) {
      wrappedChildren.add(widget.footer!);
    }

    late Widget child;

    if (widget.scrollController != null &&
        PrimaryScrollController.maybeOf(context) == null) {
      child = (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
          context, widget.direction, wrappedChildren);
    } else {
      child = SingleChildScrollView(
        scrollDirection: widget.scrollDirection,
        physics: const NeverScrollableScrollPhysics(),
        padding: widget.padding,
        controller: _scrollController,
        child: (widget.buildItemsContainer ?? defaultBuildItemsContainer)(
            context, widget.direction, wrappedChildren),
      );
    }

    return RawKeyboardListener(
      autofocus: true,
      focusNode: _forcus,
      onKey: _onKey,
      child: MouseRegion(
        onHover: _onHover,
        onExit: _onExit,
        child: LayoutBuilder(builder: (context, constraint) {
          _maxHeight = constraint.maxHeight;
          _maxWidth = constraint.maxWidth;
          return child;
        }),
      ),
    );
  }

  bool _moveByKey = false;

  Size get _footerSize {
    if (widget.footer == null) {
      return const Size(0, 0);
    }
    return Utils.measureWidget(widget.footer!);
  }

  Size get _headerSize {
    if (widget.header == null) {
      return const Size(0, 0);
    }
    return Utils.measureWidget(widget.header!);
  }

  Size get _contentSize {
    final RenderBox box = context.findRenderObject()! as RenderBox;
    return box.size;
  }

  Offset get _offset => Utils.offset(context);

  Offset get _top => Offset(
        _offset.dx,
        _offset.dy,
      );

  Offset get _bottom {
    debugPrint('_offset $_offset');
    return Offset(
      _offset.dx + _contentSize.width,
      _offset.dy + _contentSize.height,
    );
  }

  void _onKey(RawKeyEvent event) async {
    if (_currentDrag != null) {
      _moveByKey = true;
      if (horizontal) {
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final offset = Utils.offset(context);
        if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          _currentDrag!.onNext(
            min: offset.dx + _headerSize.width,
            max: box.size.width + offset.dx - _footerSize.width,
            footer: _footerSize,
            header: _headerSize,
          );
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          _currentDrag!.onPre(
            min: offset.dx + _headerSize.width,
            max: box.size.width + offset.dx - _footerSize.width,
            footer: _footerSize,
            header: _headerSize,
          );
        }
      } else {
        final RenderBox box = context.findRenderObject()! as RenderBox;
        final offset = Utils.offset(context);
        if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          _currentDrag!.onNext(
            min: offset.dy + _headerSize.height,
            max: box.size.height + offset.dy - _footerSize.height,
            footer: _footerSize,
            header: _headerSize,
          );
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          _currentDrag!.onPre(
            min: offset.dy + _headerSize.height,
            max: box.size.height + offset.dy - _footerSize.height,
            footer: _footerSize,
            header: _headerSize,
          );
        }
      }
    }
  }

  late double _maxHeight;
  late double _maxWidth;
  final _forcus = FocusNode();
  bool get horizontal => widget.direction == Axis.horizontal;

  void _onHover(PointerHoverEvent event) {
    // return;
    if (_scrollController.hasClients) {
      final double scrollOffset = _scrollController.offset;
      final double topOffset = _scrollController.position.minScrollExtent;
      final double bottomOffset = _scrollController.position.maxScrollExtent;

      if (widget.direction == Axis.vertical) {
        final dx = event.localPosition.dy;
        final delta = event.delta.dy;
        // delta < 0 => move left, delta > 0 move right
        if (dx <= _scrollZoneHeight() &&
            scrollOffset > topOffset &&
            delta <= 0) {
          if (!_scrolling) {
            _scrollToLeft();
          }
        } else if (dx >= _maxHeight - _scrollZoneHeight() &&
            scrollOffset < bottomOffset &&
            delta >= 0) {
          if (!_scrolling) {
            _scrollToRight();
          }
        } else {
          _stopScroll();
        }
      } else {
        final dx = event.localPosition.dx;
        final delta = event.delta.dx;
        // delta < 0 => move left, delta > 0 move right
        if (dx <= _scrollZoneWidth() &&
            scrollOffset > topOffset &&
            delta <= 0) {
          if (!_scrolling) {
            _scrollToLeft();
          }
        } else if (dx >= _maxWidth - _scrollZoneWidth() &&
            scrollOffset < bottomOffset &&
            delta >= 0) {
          if (!_scrolling) {
            _scrollToRight();
          }
        } else {
          _stopScroll();
        }
      }
    }
  }

  double _scrollZoneWidth() => max(_maxWidth / 13, 40);
  double _scrollZoneHeight() => max(_maxHeight / 20, 40);

  void _scrollToLeft() async {
    if (_scrolling) return;
    _scrolling = true;
    final double scrollOffset = _scrollController.offset;
    final double topOffset = _scrollController.position.minScrollExtent;
    _scrollController
        .animateTo(
      topOffset,
      duration: Duration(milliseconds: (scrollOffset - topOffset).toInt()),
      curve: Curves.linear,
    )
        .then((value) {
      _scrolling = false;
    });
  }

  void _scrollToRight() async {
    if (_scrolling) return;
    _scrolling = true;
    final double scrollOffset = _scrollController.offset;
    final double bottomOffset = _scrollController.position.maxScrollExtent;
    _scrollController
        .animateTo(
      bottomOffset,
      duration: Duration(milliseconds: (bottomOffset - scrollOffset).toInt()),
      curve: Curves.linear,
    )
        .then((value) {
      _scrolling = false;
    });
  }

  void _stopScroll() {
    if (_scrolling) {
      _scrollController
          .animateTo(_scrollController.offset,
              duration: Duration.zero, curve: Curves.linear)
          .then((value) {
        _scrolling = false;
        // if (_currentDrag != null) {
        //   _requestAnimationToNextIndex(isAcceptingNewTarget: true);
        // }
      });
    }
  }

  void _onExit(PointerExitEvent event) {
    debugPrint('_onExitParent');
    _stopScroll();
  }

  Widget defaultBuildItemsContainer(
      BuildContext context, Axis direction, List<Widget> children) {
    switch (direction) {
      case Axis.horizontal:
        return Row(children: children);
      case Axis.vertical:
      default:
        return Column(children: children);
    }
  }

  Widget defaultBuildDraggableFeedback(
      BuildContext context, BoxConstraints constraints, Widget child) {
    return Transform(
      transform: Matrix4.rotationZ(0),
      alignment: FractionalOffset.topLeft,
      child: ConstrainedBox(
        constraints: constraints,
        child: child,
      ),
    );
  }
}

/// Reorderable (drag and drop) version of [Row], a widget that displays its
/// draggable children in horizontally.
///
/// In addition to other parameters in [Row]'s constructor, this widget also
/// has [header] and [footer] for placing non-reorderable widgets at the top and
/// bottom of the widget, and [buildDraggableFeedback] to customize the
/// [feedback] widget of the internal [LongPressDraggable].
///
/// The [onReorder] function must be defined. A typical onReorder function looks
/// like the following:
///
/// ``` dart
/// void _onReorder(int oldIndex, int newIndex) {
///   setState(() {
///     Widget row = _rows.removeAt(oldIndex);
///     _rows.insert(newIndex, row);
///   });
/// }
/// ```
///
/// All [children] must have a key.
///
/// See also:
///
///  * [ReorderableColumn], for a version of this widget that is always vertical.
class ReorderableRow extends ReorderableFlex {
  ReorderableRow({
    required ReorderCallback onReorder,
    Key? key,
    Widget? header,
    Widget? footer,
    EdgeInsets? padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
    BuildDraggableFeedback? buildDraggableFeedback,
    NoReorderCallback? onNoReorder,
    ReorderStartedCallback? onReorderStarted,
    ScrollController? scrollController,
    ScrollPhysics? physics,
    double draggingWidgetOpacity = 0.2,
    Duration? reorderAnimationDuration,
    ReorderableController? controller,
    Duration? scrollAnimationDuration,
    Widget Function(BuildContext context, int index)? draggedItemBuilder,
    bool ignorePrimaryScrollController = false,
    double maringBottomDragingItem = 50,
    Widget? extendItemLeft,
    Widget? extendItemRight,
  }) : super(
            key: key,
            header: header,
            footer: footer,
            children: children,
            onReorder: onReorder,
            onNoReorder: onNoReorder,
            onReorderStarted: onReorderStarted,
            direction: Axis.horizontal,
            scrollDirection: Axis.horizontal,
            padding: padding,
            draggedItemBuilder: draggedItemBuilder,
            buildItemsContainer:
                (BuildContext context, Axis direction, List<Widget> children) {
              return Flex(
                  direction: direction,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: mainAxisSize,
                  crossAxisAlignment: crossAxisAlignment,
                  textDirection: textDirection,
                  verticalDirection: verticalDirection,
                  textBaseline: textBaseline,
                  children: children);
            },
            buildDraggableFeedback: buildDraggableFeedback,
            mainAxisAlignment: mainAxisAlignment,
            scrollController: scrollController,
            draggingWidgetOpacity: draggingWidgetOpacity,
            reorderAnimationDuration: reorderAnimationDuration,
            scrollAnimationDuration: scrollAnimationDuration,
            maringBottomDragingItem: maringBottomDragingItem,
            extendItemTop: extendItemLeft,
            extendItemBottom: extendItemRight,
            physics: physics,
            controller: controller,
            ignorePrimaryScrollController: ignorePrimaryScrollController);
}

/// Reorderable (drag and drop) version of [Column], a widget that displays its
/// draggable children in horizontally.
///
/// In addition to other parameters in [Column]'s constructor, this widget also
/// has [header] and [footer] for placing non-reorderable widgets at the left and
/// right of the widget, and [buildDraggableFeedback] to customize the
/// [feedback] widget of the internal [LongPressDraggable].
///
/// The [onReorder] function must be defined. A typical onReorder function looks
/// like the following:
///
/// ``` dart
/// void _onReorder(int oldIndex, int newIndex) {
///   setState(() {
///     Widget row = _rows.removeAt(oldIndex);
///     _rows.insert(newIndex, row);
///   });
/// }
/// ```
///
/// All [children] must have a key.
///
/// See also:
///
///  * [ReorderableRow], for a version of this widget that is always horizontal.
class ReorderableColumn extends ReorderableFlex {
  ReorderableColumn({
    required ReorderCallback onReorder,
    Key? key,
    Widget? extendItemTop,
    Widget? extendItemBottom,
    EdgeInsets? padding,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
    List<Widget> children = const <Widget>[],
    BuildDraggableFeedback? buildDraggableFeedback,
    NoReorderCallback? onNoReorder,
    ReorderStartedCallback? onReorderStarted,
    ScrollController? scrollController,
    ScrollPhysics? physics,
    double draggingWidgetOpacity = 0.2,
    Duration? reorderAnimationDuration,
    Duration? scrollAnimationDuration,
    ReorderableController? controller,
    Widget Function(BuildContext context, int index)? draggedItemBuilder,
    bool ignorePrimaryScrollController = false,
    double marginLeftDragingItem = 80,
  }) : super(
            key: key,
            children: children,
            onReorder: onReorder,
            onNoReorder: onNoReorder,
            onReorderStarted: onReorderStarted,
            direction: Axis.vertical,
            padding: padding,
            buildItemsContainer:
                (BuildContext context, Axis direction, List<Widget> children) {
              return Flex(
                  direction: direction,
                  mainAxisAlignment: mainAxisAlignment,
                  mainAxisSize: mainAxisSize,
                  crossAxisAlignment: crossAxisAlignment,
                  textDirection: textDirection,
                  verticalDirection: verticalDirection,
                  textBaseline: textBaseline,
                  children: children);
            },
            buildDraggableFeedback: buildDraggableFeedback,
            mainAxisAlignment: mainAxisAlignment,
            scrollController: scrollController,
            draggingWidgetOpacity: draggingWidgetOpacity,
            reorderAnimationDuration: reorderAnimationDuration,
            scrollAnimationDuration: scrollAnimationDuration,
            physics: physics,
            extendItemTop: extendItemTop,
            extendItemBottom: extendItemBottom,
            marginLeftDragingItem: marginLeftDragingItem,
            controller: controller,
            draggedItemBuilder: draggedItemBuilder,
            ignorePrimaryScrollController: ignorePrimaryScrollController);
}

class ReorderableController {
  late void Function() stopReorder;
  final List<ValueChanged<bool>> _listeners = [];
  bool isDraging = false;

  void addListener(ValueChanged<bool> value) {
    if (!_listeners.contains(value)) {
      _listeners.add(value);
    }
  }

  void removeListener(ValueChanged<bool> value) {
    if (_listeners.contains(value)) {
      _listeners.remove(value);
    }
  }

  void notifyDrag(bool value) {
    isDraging = value;
    for (var element in _listeners) {
      element(value);
    }
  }

  // update new coordinates. only for widgetbook evironment
  static void setCoordinates(Offset value) {
    Utils.configOffset(value);
  }
}
