import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';

class DraggableDialog extends StatefulWidget {
  const DraggableDialog({Key key, this.child, this.initialPosition})
      : super(key: key);

  final Widget child;
  final AnchoringPosition initialPosition;

  @override
  _DraggableDialogState createState() => _DraggableDialogState();
}

class _DraggableDialogState extends State<DraggableDialog> {
  DragController _controller = DragController();

  @override
  Widget build(BuildContext context) {
    return DraggableWidget(
      bottomMargin: 100,
      topMargin: 100,
      intialVisibility: true,
      horizontalSapce: 20,
      shadowBorderRadius: 0,
      dragAnimationScale: 1.0,
      statusBarHeight: 50,
      child: widget.child,
      initialPosition: widget.initialPosition,
      dragController: _controller,
    );
  }
}
