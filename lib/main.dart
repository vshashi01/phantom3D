import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phantom3d/bloc/cubit/viewportrendering_cubit.dart';
import 'package:phantom3d/widgets/viewport_listener_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  //var channel = null;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.socketChannel}) : super(key: key);

  final String title;
  final WebSocketChannel socketChannel;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final renderingCubit = ViewportRenderingCubit();
  FocusNode _focusNode;

  double _previousMaxWidth;
  double _previousMaxHeight;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    renderingCubit?.connect();
    _focusNode = FocusNode(canRequestFocus: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var goCrazy = socketChannel.stream;
    return Scaffold(
      appBar: AppBar(
        title: Text("WebApp"),
        actions: [
          IconButton(
            icon: Icon(Icons.web),
            onPressed: () {
              renderingCubit?.connect();
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              renderingCubit?.disconnect();
            },
          )
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

            return Stack(children: [
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.blue[800],
                child:
                    BlocBuilder<ViewportRenderingCubit, ViewportRenderingState>(
                  cubit: renderingCubit,
                  buildWhen: (previousState, currentState) {
                    if (previousState == currentState) {
                      return false;
                    }
                    return true;
                  },
                  builder: (context, state) {
                    if (state is ViewportRenderingUpdate) {
                      return ViewportInteractionListener(
                        child: Container(
                          child: Image.memory(state.imageBytes,
                              scale: 1.0, fit: BoxFit.fill),
                        ),
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
                        onPrimaryMouseButtonDragComplete:
                            (xPos, yPos, keyEvent) {
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
                      );
                    } else {
                      return Container(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              )
            ]);
          },
        ),
      ),
    );
  }
}
