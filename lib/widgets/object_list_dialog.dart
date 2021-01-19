import 'package:draggable_widget/model/anchor_docker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:phantom3d/bloc/keyboard_listener/keyboard_listener_cubit.dart';
import 'package:phantom3d/bloc/object_list/object_list_cubit.dart';
import 'package:phantom3d/bloc/selected_entity/selected_entity_cubit.dart';
import 'package:phantom3d/bloc/viewport_rendering/viewportrendering_cubit.dart';
import 'package:phantom3d/data_model/entity_model.dart';
import 'package:phantom3d/widgets/draggable_dialog.dart';

class ObjectListDialog extends StatefulWidget {
  final double width;
  final double minHeight;
  final double maxHeight;
  final ObjectlistCubit objectlistCubit;
  final ViewportRenderingCubit renderingCubit;

  const ObjectListDialog(
      {Key key,
      this.objectlistCubit,
      this.renderingCubit,
      this.width,
      this.minHeight,
      this.maxHeight})
      : super(key: key);

  @override
  _ObjectListDialogState createState() => _ObjectListDialogState();
}

class _ObjectListDialogState extends State<ObjectListDialog> {
  final TreeController _treeController =
      TreeController(allNodesExpanded: false);

  @override
  void initState() {
    //widget.objectlistCubit?.update();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableDialog(
      initialPosition: AnchoringPosition.topLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, color: Colors.white.withOpacity(0.2)),
        width: widget.width,
        height: widget.maxHeight,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Object List', style: TextStyle(color: Colors.white)),
                  IconButton(
                    icon: Icon(Icons.double_arrow),
                    color: Colors.white,
                    onPressed: () => widget.objectlistCubit.update(),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 12,
              child: SingleChildScrollView(
                child: Container(
                  width: widget.width,
                  color: Colors.black.withOpacity(0.5),
                  child: MultiBlocProvider(
                    providers: [
                      BlocProvider<ObjectlistCubit>.value(
                          value: widget.objectlistCubit),
                      BlocProvider<SelectedEntityCubit>(
                          create: (context) =>
                              SelectedEntityCubit(widget.renderingCubit))
                    ],
                    child: BlocBuilder<ObjectlistCubit, EntityCollection>(
                        cubit: widget.objectlistCubit,
                        builder: (context, state) => buildTree(state)),
                  ),
                ),
                scrollDirection: Axis.horizontal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTree(EntityCollection collection) {
    try {
      return TreeView(
        indent: 2,
        nodes: toTreeNodes(collection),
        treeController: _treeController,
      );
    } on FormatException catch (e) {
      return Text(e.message);
    }
  }

  List<TreeNode> toTreeNodes(EntityCollection collection) {
    if (!collection.isEmpty) {
      final items = collection.models
          .map((e) => TreeNode(
              content: ObjectTreeItem(
                model: e,
                width: widget.width - 100,
              ),
              children: null))
          .toList();

      return [
        TreeNode(
            content: Text("Models", style: TextStyle(color: Colors.white)),
            children: items)
      ];
    } else {
      return [
        TreeNode(content: Text('Models', style: TextStyle(color: Colors.white)))
      ];
    }
  }
}

class ObjectTreeItem extends StatefulWidget {
  const ObjectTreeItem({
    Key key,
    this.model,
    this.width,
  }) : super(key: key);

  final EntityModel model;
  final double width;

  @override
  _ObjectTreeItemState createState() => _ObjectTreeItemState();
}

class _ObjectTreeItemState extends State<ObjectTreeItem> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedEntityCubit, EntityCollection>(
        buildWhen: (_, __) => true,
        builder: (context, collection) {
          var isSelected = false;

          if (!collection.isEmpty) {
            isSelected = collection.models
                .any((element) => element.name == widget.model.name);
          }

          return Container(
            width: widget.width,
            child: Row(children: [
              _getHeaderIcon(isSelected),
              _getSelectableName(isSelected),
              _getVisibilityButton(isSelected)
            ]),
          );
        });
  }

  Widget _getHeaderIcon(bool isCurrentlySelected) {
    Color iconColor = Colors.grey;

    if (isCurrentlySelected) {
      iconColor = Colors.white;
    }
    return Expanded(
      child: Icon(
        Icons.cloud_circle,
        color: iconColor,
      ),
      flex: 1,
    );
  }

  Widget _getSelectableName(bool isCurrentlySelected) {
    Color containerColor = Colors.transparent;
    Color textColor = Colors.white;

    if (isCurrentlySelected) {
      containerColor = Colors.white;
      textColor = Colors.black;
    }
    return BlocBuilder<KeyboardListenerCubit, RawKeyEvent>(
      builder: (context, state) {
        return Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              //only selectable if visible
              if (!isCurrentlySelected && widget.model.visible) {
                BlocProvider.of<SelectedEntityCubit>(context)
                    .select(widget.model.name);
              }
            },
            child: Container(
              color: containerColor,
              child: Text(widget.model.name + " " + widget.model.id.toString(),
                  style: TextStyle(color: textColor)),
            ),
          ),
        );
      },
    );
  }

  Widget _getVisibilityButton(bool isCurrentlySelected) {
    Color iconColor = Colors.grey;

    if (isCurrentlySelected) {
      iconColor = Colors.white;
    }

    var icon = Icons.visibility_outlined;

    if (!widget.model.visible) {
      icon = Icons.visibility_off_outlined;
    }

    return Expanded(
        flex: 1,
        child: IconButton(
          icon: Icon(
            icon,
            color: iconColor,
          ),
          onPressed: () {
            //_isVisible = !_isVisible;
            BlocProvider.of<ObjectlistCubit>(context)
                .setVisibility(widget.model.name, !widget.model.visible);

            //setState(() {});
          },
        ));
  }
}
