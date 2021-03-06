import 'dart:convert';

import 'package:equatable/equatable.dart';

class RenderingCommandMessage extends Equatable {
  final int xPos;
  final int yPos;
  final String command;
  final String value;
  final bool moved;
  final bool ctrlPressed;

  static final leftButton = 0;
  static final scrollerButton = 1;
  static final rightButton = 1;

  RenderingCommandMessage(
      {this.xPos = 0,
      this.yPos = 0,
      this.command = "",
      this.value = "",
      this.moved = false,
      this.ctrlPressed = false});

  @override
  List<Object> get props => [xPos, yPos, command, value, moved, ctrlPressed];

  Map<String, dynamic> toMap() {
    return {
      'x': xPos,
      'y': yPos,
      'cmd': command,
      'val': value,
      'moved': moved,
      'ctrl': ctrlPressed
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}

class CloseRendering extends RenderingCommandMessage {
  CloseRendering() : super(command: 'Close');
}

class GetUUID extends RenderingCommandMessage {
  GetUUID() : super(command: 'GetUUID');
}

class SimpleCommandAndValue extends RenderingCommandMessage {
  SimpleCommandAndValue(String command, String value)
      : super(command: command, value: value);
}

enum OrbitControls { rotate, zoom, pan }

class OrbitControlCommands extends RenderingCommandMessage {
  OrbitControlCommands._(int xPos, int yPos, String command, String value,
      {bool moved = false, bool ctrlPressed = false})
      : super(
            xPos: xPos,
            yPos: yPos,
            command: command,
            value: value,
            ctrlPressed: ctrlPressed,
            moved: moved);

  factory OrbitControlCommands.setOrbitAction(
      OrbitControls control, int xPos, int yPos) {
    final controlString = mapOrbitControls(control);
    return OrbitControlCommands._(xPos, yPos, "Setorbitaction", controlString);
  }

  factory OrbitControlCommands.clearOrbitAction(int xPos, int yPos) {
    return OrbitControlCommands._(xPos, yPos, "ClearOrbitAction", "");
  }

  factory OrbitControlCommands.zoom(int xOffset, int yOffset) {
    final controlString = mapOrbitControls(OrbitControls.zoom);
    return OrbitControlCommands._(
        xOffset, yOffset, controlString, controlString,
        moved: true);
  }

  factory OrbitControlCommands.pan(int xPos, int yPos) {
    final controlString = mapOrbitControls(OrbitControls.pan);
    return OrbitControlCommands._(xPos, yPos, controlString, controlString,
        moved: true);
  }

  factory OrbitControlCommands.rotate(int xPos, int yPos) {
    final controlString = mapOrbitControls(OrbitControls.rotate);
    return OrbitControlCommands._(xPos, yPos, controlString, controlString,
        moved: true);
  }

  static String mapOrbitControls(OrbitControls control) {
    var controlString = "Pan";
    switch (control) {
      case OrbitControls.rotate:
        controlString = "Rotate";
        break;
      case OrbitControls.zoom:
        controlString = "Zoom";
        break;
      case OrbitControls.pan:
        controlString = "Pan";
        break;
    }

    return controlString;
  }
}

class ViewportResizeCommands extends RenderingCommandMessage {
  ViewportResizeCommands(int width, int height)
      : super(xPos: width, yPos: height, command: "ResizeWindow");
}

class UnzoomAll extends RenderingCommandMessage {
  UnzoomAll() : super(command: "ZoomExtent");
}

class SelectEntityCoordinates extends RenderingCommandMessage {
  SelectEntityCoordinates(int xPos, int yPos, {bool multiSelect = false})
      : super(
            xPos: xPos,
            yPos: yPos,
            command: "SelectEntityCoordinates",
            ctrlPressed: multiSelect);
}

class SelectEntityFromName extends RenderingCommandMessage {
  SelectEntityFromName(String name, {bool multiSelect = false})
      : super(
            command: "SelectEntityFromName",
            value: name,
            ctrlPressed: multiSelect);
}

class HideEntityFromName extends RenderingCommandMessage {
  HideEntityFromName(String name)
      : super(command: "HideEntityFromName", value: name);
}

class UnhideEntityFromName extends RenderingCommandMessage {
  UnhideEntityFromName(String name)
      : super(command: "UnhideEntityFromName", value: name);
}
