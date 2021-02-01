import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:phantom3d/bloc/keyboard_listener/keyboard_listener_cubit.dart';
import 'package:phantom3d/bloc/object_list/object_list_cubit.dart';
import 'package:phantom3d/bloc/upload_model/uploadmodel_cubit.dart';
import 'package:phantom3d/bloc/viewport_rendering/viewportrendering_cubit.dart';
import 'package:phantom3d/data_model/scene_tab_container.dart';
import 'package:phantom3d/widgets/file_upload_dialog.dart';
import 'package:phantom3d/widgets/object_list_dialog.dart';
import 'package:phantom3d/widgets/viewport_listener_widget.dart';

class MainViewportTabContainer implements SceneTabContainer {
  final String name;
  final bool closable;
  ViewportRenderingCubit _renderingCubit;
  ObjectlistCubit _objectlistCubit;
  UploadmodelCubit _uploadmodelCubit;

  MainViewportTabContainer(this.name, {this.closable = false});

  @override
  Future close() async {
    _renderingCubit.disconnect();
  }

  @override
  Widget getWidget() {
    return MainViewportScene(
      key: Key(name),
      renderingCubit: _renderingCubit,
      objectlistCubit: _objectlistCubit,
      uploadmodelCubit: _uploadmodelCubit,
    );
  }

  @override
  Future init() async {
    _renderingCubit = ViewportRenderingCubit();
    _uploadmodelCubit = UploadmodelCubit();
    _objectlistCubit = ObjectlistCubit(
        renderingCubit: _renderingCubit, uploadmodelCubit: _uploadmodelCubit);
  }

  @override
  String title() {
    return name;
  }

  @override
  bool canClose() {
    return closable;
  }
}

class MainViewportScene extends StatefulWidget {
  final ViewportRenderingCubit renderingCubit;
  final UploadmodelCubit uploadmodelCubit;
  final ObjectlistCubit objectlistCubit;

  const MainViewportScene(
      {Key key,
      this.renderingCubit,
      this.uploadmodelCubit,
      this.objectlistCubit})
      : super(key: key);

  @override
  _MainViewportSceneState createState() => _MainViewportSceneState();
}

class _MainViewportSceneState extends State<MainViewportScene> {
  KeyboardListenerCubit _keyboardListenerCubit;
  double _previousMaxWidth;
  double _previousMaxHeight;
  FocusNode _focusNode;
  bool _useLocalHost = true;

  @override
  void initState() {
    _focusNode = FocusNode(canRequestFocus: true);
    _keyboardListenerCubit = KeyboardListenerCubit();

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _keyboardListenerCubit.close();

    widget.renderingCubit.suspendRenderStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (_previousMaxHeight != constraints.maxHeight ||
            _previousMaxWidth != constraints.maxWidth) {
          // renderingCubit?.setWindowSize(constraints.maxWidth.toInt(),
          //     constraints.maxHeight.toInt());

          _previousMaxWidth = constraints.maxWidth;
          _previousMaxHeight = constraints.maxHeight;
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider<KeyboardListenerCubit>.value(
              value: _keyboardListenerCubit,
            ),
            BlocProvider<ObjectlistCubit>.value(
              value: widget.objectlistCubit,
            ),
            BlocProvider<UploadmodelCubit>.value(
              value: widget.uploadmodelCubit,
            ),
            BlocProvider<ViewportRenderingCubit>.value(
              value: widget.renderingCubit,
            )
          ],
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              toolbarOpacity: 1.0,
              actions: [
                _buildLocalhostCheckbox(),
                _buildDisconnectButton(),
                Container(width: 20, height: 20, color: Colors.black)
              ],
            ),
            body: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.black,
              child: Stack(
                children: [
                  Container(
                    child: BlocBuilder<ViewportRenderingCubit,
                        ViewportRenderingState>(
                      cubit: widget.renderingCubit,
                      builder: (context, state) {
                        if (state is ViewportRenderingStreaming) {
                          //these cubits should ideally listen to each other. Gonna be an idiot and pass it in the UI for now.
                          widget.uploadmodelCubit.uuid = state.uuid;
                          return Stack(children: [
                            buildViewport(state),
                          ]);
                        } else if (state is ViewportRenderingDisconnected) {
                          return connectToServerButton();
                        } else if (state is ViewportRenderingSuspended) {
                          return renewRenderStreamButton();
                        }

                        widget.uploadmodelCubit.uuid = "";
                        return Container(
                          alignment: Alignment.center,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                  _buildUnzoomAllButton(),
                  _buildUploaderWindow(),
                  _buildObjectListWindow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget connectToServerButton() {
    return Center(
      child: IconButton(
        tooltip: "Connect to Server",
        icon: Icon(
          Icons.web_asset_rounded,
          color: Colors.white,
        ),
        iconSize: 50,
        onPressed: () {
          widget.renderingCubit?.connect(_useLocalHost);
        },
      ),
    );
  }

  Widget renewRenderStreamButton() {
    return Center(
      child: IconButton(
        tooltip: "Connect to Server",
        icon: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        iconSize: 50,
        onPressed: () {
          widget.renderingCubit?.connectRenderStream();
        },
      ),
    );
  }

  Container buildViewport(ViewportRenderingStreaming state) {
    return Container(
      color: Colors.white,
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (rawKeyEvent) {
          _keyboardListenerCubit.add(rawKeyEvent);
        },
        child: BlocProvider<KeyboardListenerCubit>.value(
          value: _keyboardListenerCubit,
          child: ViewportInteractionListener(
            child: RTCVideoView(state.videoRenderer),
            focusNode: _focusNode,
            //pan if P key is pressed
            onPrimaryMouseButtonDown: (xPos, yPos, keyEvent) {
              if (keyEvent != null &&
                  keyEvent.logicalKey == LogicalKeyboardKey.keyP) {
                widget.renderingCubit?.startPanAction(xPos, yPos);
              } else {
                widget.renderingCubit?.selectEntityFromCoordinate(xPos, yPos,
                    (keyEvent != null && keyEvent.isControlPressed));
              }
            },
            onPrimaryMouseButtonDrag: (xPos, yPos, keyEvent) {
              if (keyEvent != null &&
                  keyEvent.logicalKey == LogicalKeyboardKey.keyP) {
                widget.renderingCubit?.panViewport(xPos, yPos);
              }
            },
            onPrimaryMouseButtonDragComplete: (xPos, yPos, keyEvent) {
              widget.renderingCubit?.endAction(xPos, yPos);
            },
            //rotate
            onScrollerButtonDown: (xPos, yPos, keyEvent) {
              widget.renderingCubit?.startRotateAction(xPos, yPos);
            },
            onScrollerButtonDrag: (xPos, yPos, keyEvent) {
              widget.renderingCubit?.rotateViewport(xPos, yPos);
            },
            onScrollerButtonDragComplete: (xPos, yPos, keyEvent) {
              widget.renderingCubit?.endAction(xPos, yPos);
            },
            //zoom
            onScrollerScroll: (xOffset, yOffset, keyEvent) {
              widget.renderingCubit?.zoomViewport(xOffset, yOffset);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUnzoomAllButton() {
    final size = 50.0;
    return BlocBuilder<ViewportRenderingCubit, ViewportRenderingState>(
        builder: (context, state) {
      if (state is ViewportRenderingStreaming) {
        return Positioned(
          bottom: 20,
          right: 20,
          width: size,
          height: size,
          child: IconButton(
              iconSize: size,
              tooltip: "Unzoom All",
              icon: Icon(
                Icons.zoom_out,
                color: Colors.white,
              ),
              onPressed: () {
                widget.renderingCubit?.unzoomAll();
              }),
        );
      }

      return Container();
    });
  }

  Widget _buildDisconnectButton() {
    return BlocBuilder<ViewportRenderingCubit, ViewportRenderingState>(
        builder: (context, state) {
      if (state is ViewportRenderingStreaming) {
        return IconButton(
          tooltip: "Disconnect Rendering",
          icon: Icon(Icons.cancel),
          onPressed: () {
            widget.renderingCubit?.disconnect();
          },
        );
      }

      return Container();
    });
  }

  Widget _buildLocalhostCheckbox() {
    return BlocBuilder<ViewportRenderingCubit, ViewportRenderingState>(
        builder: (context, state) {
      if (state is ViewportRenderingDisconnected) {
        return Container(
          width: 200,
          height: 50,
          child: CheckboxListTile(
            tileColor: Colors.white54,
            checkColor: Colors.white,
            value: _useLocalHost,
            onChanged: (value) {
              _useLocalHost = value;
              setState(() {});
            },
            title: Text('Use Localhost', style: TextStyle(color: Colors.white)),
          ),
        );
      }

      return Container();
    });
  }

  Widget _buildUploaderWindow() {
    return BlocBuilder<ViewportRenderingCubit, ViewportRenderingState>(
        builder: (context, state) {
      if (state is ViewportRenderingStreaming) {
        return FileUploadDialog(
          width: 200,
          height: 180,
          uploadmodelCubit: widget.uploadmodelCubit,
        );
      }

      return Container();
    });
  }

  Widget _buildObjectListWindow() {
    return BlocBuilder<ViewportRenderingCubit, ViewportRenderingState>(
        builder: (context, state) {
      if (state is ViewportRenderingStreaming) {
        return ObjectListDialog(
          width: 300,
          maxHeight: 500,
          objectlistCubit: widget.objectlistCubit,
          renderingCubit: widget.renderingCubit,
        );
      }

      return Container();
    });
  }
}
