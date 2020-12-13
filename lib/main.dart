import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phantom3d/bloc/upload_model/uploadmodel_cubit.dart';
import 'package:phantom3d/bloc/viewport_rendering/viewportrendering_cubit.dart';
import 'package:phantom3d/widgets/conditional_builder_widget.dart';
import 'package:phantom3d/widgets/file_upload_dialog.dart';
import 'package:phantom3d/widgets/viewport_listener_widget.dart';

void main() async {
  //var channel = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phantom 3D',
      theme: ThemeData(
          //primarySwatch: Color.black,
          accentColor: Colors.grey[800]),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final renderingCubit = ViewportRenderingCubit();
  final uploadModelCubit = UploadmodelCubit();
  //final DragController _dragController = DragController();
  FocusNode _focusNode;

  double _previousMaxWidth;
  double _previousMaxHeight;

  bool _showDragController = false;

  @override
  void initState() {
    //renderingCubit?.connect();
    _focusNode = FocusNode(canRequestFocus: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        shadowColor: Colors.white,
        title: Text("Phantom 3D"),
        actions: [
          //_buildUploaderButton(),
          _buildConnectButton(),
          _buildDisconnectButton(),
        ],
      ),
      body: Container(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (_previousMaxHeight != constraints.maxHeight ||
                _previousMaxWidth != constraints.maxWidth) {
              renderingCubit?.setWindowSize(
                  constraints.maxWidth.toInt(), constraints.maxHeight.toInt());

              _previousMaxWidth = constraints.maxWidth;
              _previousMaxHeight = constraints.maxHeight;
            }

            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Colors.black,
              child: Stack(
                children: [
                  Container(
                    child: BlocBuilder<ViewportRenderingCubit,
                        ViewportRenderingState>(
                      cubit: renderingCubit,
                      buildWhen: (previousState, currentState) {
                        if (previousState == currentState) {
                          return false;
                        } else if (currentState.runtimeType ==
                            ViewportReporting) {
                          return false;
                        }
                        return true;
                      },
                      builder: (context, state) {
                        if (state is ViewportRenderingUpdate) {
                          return Stack(children: [
                            buildViewport(state, constraints),
                          ]);
                        } else {
                          return Container(
                            alignment: Alignment.center,
                            height: constraints.maxHeight / 3,
                            width: constraints.maxWidth / 3,
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  _buildUnzoomAllButton(),
                  _buildUploaderWindow()
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Container buildViewport(
      ViewportRenderingUpdate state, BoxConstraints constraints) {
    return Container(
      child: ViewportInteractionListener(
        child: Image.memory(state.imageBytes,
            scale: 1.0, width: constraints.maxWidth, fit: BoxFit.fill),
        focusNode: _focusNode,
        //pan if P key is pressed
        onPrimaryMouseButtonDown: (xPos, yPos, keyEvent) {
          if (keyEvent != null &&
              keyEvent.logicalKey == LogicalKeyboardKey.keyP) {
            renderingCubit?.startPanAction(xPos, yPos);
          }
        },
        onPrimaryMouseButtonDrag: (xPos, yPos, keyEvent) {
          if (keyEvent != null &&
              keyEvent.logicalKey == LogicalKeyboardKey.keyP) {
            renderingCubit?.panViewport(xPos, yPos);
          }
        },
        onPrimaryMouseButtonDragComplete: (xPos, yPos, keyEvent) {
          renderingCubit?.endAction(xPos, yPos);
        },
        //rotate
        onScrollerButtonDown: (xPos, yPos, keyEvent) {
          renderingCubit?.startRotateAction(xPos, yPos);
        },
        onScrollerButtonDrag: (xPos, yPos, keyEvent) {
          renderingCubit?.rotateViewport(xPos, yPos);
        },
        onScrollerButtonDragComplete: (xPos, yPos, keyEvent) {
          renderingCubit?.endAction(xPos, yPos);
        },
        //zoom
        onScrollerScroll: (xOffset, yOffset, keyEvent) {
          renderingCubit?.zoomViewport(xOffset, yOffset);
        },
      ),
    );
  }

  Widget _buildUnzoomAllButton() {
    final size = 50.0;
    return ConditionalBuilder(
      conditionalStream: renderingCubit.connectionStream,
      child: Positioned(
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
              renderingCubit?.unzoomAll();
            }),
      ),
    );
  }

  Widget _buildDisconnectButton() {
    return ConditionalBuilder(
      conditionalStream: renderingCubit.connectionStream,
      transformBool: false,
      child: IconButton(
        tooltip: "Disconnect Rendering",
        icon: Icon(Icons.cancel),
        onPressed: () {
          renderingCubit?.disconnect();
        },
      ),
    );
  }

  Widget _buildConnectButton() {
    return ConditionalBuilder(
      conditionalStream: renderingCubit.connectionStream,
      transformBool: true,
      child: IconButton(
        tooltip: "Connect Rendering",
        icon: Icon(Icons.web_asset_rounded),
        onPressed: () {
          renderingCubit?.connect();
        },
      ),
    );
  }

  Widget _buildUploaderButton() {
    return ConditionalBuilder(
      conditionalStream: renderingCubit.connectionStream,
      child: IconButton(
        tooltip: "Load Model",
        icon: Icon(Icons.upload_file),
        onPressed: () {
          _showDragController = !_showDragController;

          setState(() {});
        },
      ),
    );
  }

  Widget _buildUploaderWindow() {
    return ConditionalBuilder(
      conditionalStream: renderingCubit.connectionStream,
      child: FileUploadDialog(
        width: 200,
        height: 180,
        uploadmodelCubit: uploadModelCubit,
      ),
    );
  }
}
