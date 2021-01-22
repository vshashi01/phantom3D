import 'package:flutter/material.dart';

abstract class SceneTabContainer {
  String title();
  Future init();
  Widget getWidget();
  Future close();
  bool canClose();
}
