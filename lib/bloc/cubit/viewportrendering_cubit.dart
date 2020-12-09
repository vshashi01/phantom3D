import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:phantom3d/data_model/server_message_pack.dart';
import 'package:phantom3d/data_model/viewport_commands.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:phantom3d/multi_platform_libs/websocket/websocket_channel.dart';
import 'package:file_picker/file_picker.dart';

part 'viewportrendering_state.dart';

class ViewportRenderingCubit extends Cubit<ViewportRenderingState> {
  ViewportRenderingCubit() : super(ViewportRenderingInitial());

  WebSocketChannel _renderingSocket;
  StreamSubscription _renderStreamListener;

  bool _isConnected = false;

  final connectHost = "ws://localhost:8000/webg3n?h=800&w=1000";
  bool connect({String url}) {
    try {
      _renderingSocket = getConnection(connectHost);

      _renderStreamListener = _renderingSocket.stream.listen((message) {
        _processRenderStream(message);
      });
      _isConnected = true;
      emit(ViewportRenderingConnected());

      return true;
    } catch (error) {
      print(error);
      _isConnected = false;
      emit(ViewportRenderingDisconnected(null));
      return false;
    }
  }

  bool disconnect({String url}) {
    try {
      _renderingSocket = null;
      _renderStreamListener.cancel();
      _renderStreamListener = null;
      _isConnected = false;
      emit(ViewportRenderingDisconnected(null));
      return true;
    } catch (error) {
      print(error);
      _isConnected = false;
      emit(ViewportRenderingDisconnected(null));
      return false;
    }
  }

  bool isConnected() {
    return _isConnected;
  }

  Future<bool> uploadModel() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['stl', 'gltf'],
        allowMultiple: false);

    if (filePickerResult != null) {
      final file = File(filePickerResult.files.first.path);
      print(filePickerResult.files.first.path);
    }
  }

  void setWindowSize(int width, int height) {
    final sizeCommand = ViewportResizeCommands(width, height);
    _renderingSocket?.sink?.add(sizeCommand.toString());
  }

  void startRotateAction(int xPos, int yPos) {
    final rotateCommand =
        OrbitControlCommands.setOrbitAction(OrbitControls.rotate, xPos, yPos);
    _renderingSocket?.sink?.add(rotateCommand.toString());
  }

  void endAction(int xPos, int yPos) {
    final rotateCommand = OrbitControlCommands.clearOrbitAction(xPos, yPos);
    _renderingSocket?.sink?.add(rotateCommand.toString());
  }

  void rotateViewport(int xPos, int yPos) {
    final rotateCommand = OrbitControlCommands.rotate(xPos, yPos);
    _renderingSocket?.sink?.add(rotateCommand.toString());
  }

  void startPanAction(int xPos, int yPos) {
    final panCommand =
        OrbitControlCommands.setOrbitAction(OrbitControls.pan, xPos, yPos);
    _renderingSocket?.sink?.add(panCommand.toString());
  }

  void panViewport(int xPos, int yPos) {
    final panCommand = OrbitControlCommands.pan(xPos, yPos);
    _renderingSocket?.sink?.add(panCommand.toString());
  }

  void zoomViewport(int xOffset, int yOffset) {
    final zoomCommand = OrbitControlCommands.zoom(xOffset, yOffset);
    _renderingSocket?.sink?.add(zoomCommand.toString());
  }

  void _processRenderStream(message) {
    try {
      Map<String, dynamic> map = jsonDecode(message);
      print(message);

      if (map.containsKey('action') && map.containsKey('value')) {
        _processMap(map);
      }
    } on FormatException {
      _processImageBytes(message);
    } catch (error) {
      print(error);
    }
  }

  void _processImageBytes(String base64String) {
    try {
      final imageBytes = base64Decode(base64String);

      if (imageBytes != null && imageBytes.isNotEmpty) {
        emit(ViewportRenderingUpdate(imageBytes, 'Rendering update'));
      }
    } catch (error) {
      print(error);
    }
  }

  void _processMap(Map<String, dynamic> map) {
    final serverMessage = ServerMessagePack.fromMap(map);
    if (serverMessage != null) {
      emit(ViewportReporting(serverMessage.toString()));
    }
  }
}
