import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:phantom3d/data_model/server_message_pack.dart';
import 'package:phantom3d/data_model/viewport_commands.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:phantom3d/multi_platform_libs/websocket/websocket_channel.dart';

part 'viewportrendering_state.dart';

class ViewportRenderingCubit extends Cubit<ViewportRenderingState> {
  ViewportRenderingCubit() : super(ViewportRenderingInitial()) {
    _isStreamRenderingController = StreamController<bool>.broadcast();
    _isRenderStreamConnected = false;

    _isStreamRenderingController?.add(_isRenderStreamConnected);
  }

  WebSocketChannel _renderingSocket;
  WebSocketChannel _peerConnectionSocket;
  StreamSubscription _renderStreamListener;
  StreamController _isStreamRenderingController;
  bool _isRenderStreamConnected;
  String _uuid = "";
  RTCPeerConnection _peerConnection;
  RTCVideoRenderer _viewportRenderer;

  String get uuid {
    return _uuid;
  }

  Stream<bool> get connectionStream {
    return _isStreamRenderingController?.stream;
  }

  bool get isConnected {
    return _isRenderStreamConnected;
  }

  final connectHost = "ws://localhost:8000/webg3n?h=800&w=1000";
  Future connect({String url}) async {
    try {
      _renderingSocket = getConnection(connectHost);
      _renderingSocket.sink.add(GetUUID().toString());

      _renderStreamListener = _renderingSocket.stream.listen((message) {
        _processMessageStream(message);
      }, onDone: () {
        emit(ViewportReporting(
            ServerMessagePack(action: 'Websocket Closed', value: 'For fun'),
            _uuid));
        emit(ViewportRenderingDisconnected(null));
      });
    } catch (error) {
      print(error);
      emit(ViewportRenderingDisconnected(null));
    }
  }

  bool disconnect({String url}) {
    try {
      _renderingSocket?.sink?.add(CloseRendering().toString());
      _renderingSocket = null;
      _renderStreamListener.cancel();
      _renderStreamListener = null;
      _uuid = "";
      _peerConnection?.close();
      _peerConnection = null;
      _updateRenderStreamState(false);
      emit(ViewportRenderingDisconnected(null));
      return true;
    } catch (error) {
      print(error);
      _updateRenderStreamState(false);
      emit(ViewportRenderingDisconnected(null));
      return false;
    }
  }

  void _updateRenderStreamState(bool state) {
    _isRenderStreamConnected = state;
    _isStreamRenderingController.add(_isRenderStreamConnected);
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

  void unzoomAll() {
    final unzoomCommand = UnzoomAll();
    _renderingSocket?.sink?.add(unzoomCommand.toString());
  }

  void selectEntityFromCoordinate(int xPos, int yPos, bool multiSelection) {
    final selectionCommand =
        SelectEntityCoordinates(xPos, yPos, multiSelect: multiSelection);
    _renderingSocket?.sink?.add(selectionCommand.toString());
  }

  void selectEntityFromName(String name, bool multiSelection) {
    final selectionCommand =
        SelectEntityFromName(name, multiSelect: multiSelection);
    _renderingSocket?.sink?.add(selectionCommand.toString());
  }

  void hideEntityFromName(String name) {
    final hideCommand = HideEntityFromName(name);
    _renderingSocket?.sink?.add(hideCommand.toString());
  }

  void showEntityFromName(String name) {
    final showCommand = UnhideEntityFromName(name);
    _renderingSocket?.sink?.add(showCommand.toString());
  }

  void _processMessageStream(message) {
    try {
      Map<String, dynamic> map = jsonDecode(message);
      print(message);

      if (map.containsKey('action') && map.containsKey('value')) {
        _processPhantomG3nMessage(map);
      }
    } catch (error) {
      print(error);
    }
  }

  void _processPhantomG3nMessage(Map<String, dynamic> map) async {
    final serverMessage = ServerMessagePack.fromMap(map);
    if (serverMessage != null) {
      //all renderer messages are handled here.
      switch (serverMessage.action) {
        case "GetUUID":
          _uuid = serverMessage.value;
          emit(ViewportRenderingConnected(_uuid));
          connectRenderStream();
          break;
      }

      emit(ViewportReporting(serverMessage, uuid));
    }
  }

  Future<void> connectRenderStream() async {
    _peerConnection = await createPeerConnection({}, {});

    _peerConnection.onIceCandidate = (candidate) {
      if (candidate == null) {
        return;
      }

      final value = JsonEncoder().convert({
        'sdpMLineIndex': candidate.sdpMlineIndex,
        'sdpMid': candidate.sdpMid,
        'candidate': candidate.candidate,
      });

      _peerConnectionSocket.sink
          .add(JsonEncoder().convert({"event": "candidate", "data": value}));
    };

    _peerConnection.onTrack = (event) async {
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        _viewportRenderer = RTCVideoRenderer();
        _viewportRenderer.initialize();
        _viewportRenderer.srcObject = event.streams[0];

        emit(ViewportRenderingStreamingStarted(_uuid, _viewportRenderer));
        _updateRenderStreamState(true);
      }
    };

    _peerConnection.onRemoveStream = (stream) {
      emit(ViewportRenderingStreamingStopped(_uuid));
      _updateRenderStreamState(false);
    };

    _peerConnectionSocket =
        getConnection('ws://localhost:8000/rtcwebg3n?uuid=$uuid');
    _peerConnectionSocket?.stream?.listen((raw) async {
      Map<String, dynamic> msg = jsonDecode(raw);

      if (msg != null) {
        switch (msg['event']) {
          case 'candidate':
            Map<String, dynamic> parsed = jsonDecode(msg['data']);
            _peerConnection
                .addCandidate(RTCIceCandidate(parsed['candidate'], null, 0));
            return;
          case 'offer':
            Map<String, dynamic> offer = jsonDecode(msg['data']);

            // SetRemoteDescription and create answer
            await _peerConnection.setRemoteDescription(
                RTCSessionDescription(offer['sdp'], offer['type']));
            RTCSessionDescription answer =
                await _peerConnection.createAnswer({});
            await _peerConnection.setLocalDescription(answer);

            final value =
                JsonEncoder().convert({'type': answer.type, 'sdp': answer.sdp});
            // Send answer over WebSocket
            _peerConnectionSocket.sink
                .add(JsonEncoder().convert({'event': 'answer', 'data': value}));
            return;
        }
      }
    }, onDone: () {
      print('Closed by server!');
      emit(ViewportRenderingStreamingStopped(_uuid));
      _updateRenderStreamState(false);
    });
  }
}
