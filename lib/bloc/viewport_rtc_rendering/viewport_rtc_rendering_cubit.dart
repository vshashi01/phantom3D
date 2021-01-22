import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:phantom3d/data_model/client_list_model.dart';
import 'package:phantom3d/multi_platform_libs/websocket/websocket_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'viewport_rtc_rendering_state.dart';

class FollowRTCCubit extends Cubit<FollowRTCState> {
  FollowRTCCubit() : super(FollowRTCIdle()) {
    _connectionStreamController = StreamController<bool>.broadcast();
    _connectionStreamController.add(false);
  }

  WebSocketChannel _socket;
  RTCPeerConnection _peerConnection;
  RTCVideoRenderer _viewportRenderer;
  StreamController<bool> _connectionStreamController;

  Stream<bool> get connectionStream {
    return _connectionStreamController.stream;
  }

  Future<void> getAllClients() async {
    if (state is FollowRTCConnected) {
      return;
    }

    final dio = Dio();

    final response =
        await dio.get<Map<String, dynamic>>("http://localhost:8000/allclients");

    if (response.statusCode == 200) {
      final clientList = ClientList.fromMap(response.data);
      emit(FollowRTCClientList(clientList));
    }
  }

  Future<void> connect(String uuid) async {
    _peerConnection = await createPeerConnection({}, {});

    _peerConnection.onIceCandidate = (candidate) {
      if (candidate == null) {
        return;
      }

      _socket.sink.add(JsonEncoder().convert({
        "event": "candidate",
        "data": JsonEncoder().convert({
          'sdpMLineIndex': candidate.sdpMlineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        })
      }));
    };

    _peerConnection.onTrack = (event) async {
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        _viewportRenderer = RTCVideoRenderer();
        _viewportRenderer.initialize();
        _viewportRenderer.srcObject = event.streams[0];

        emit(FollowRTCConnected(_viewportRenderer, uuid));
        _connectionStreamController.add(true);
      }
    };

    _peerConnection.onRemoveStream = (stream) async {
      await disconnect();
    };

    _socket = getConnection('ws://localhost:8000/rtcwebg3n?uuid=$uuid');
    _socket.stream.listen((raw) async {
      Map<String, dynamic> msg = jsonDecode(raw);

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
          RTCSessionDescription answer = await _peerConnection.createAnswer({});
          await _peerConnection.setLocalDescription(answer);

          // Send answer over WebSocket
          _socket.sink.add(JsonEncoder().convert({
            'event': 'answer',
            'data':
                JsonEncoder().convert({'type': answer.type, 'sdp': answer.sdp})
          }));
          return;
      }
    }, onDone: () {
      print('Closed by server!');
    });
  }

  Future<void> disconnect() async {
    _peerConnection?.close();
    _peerConnection = null;
    _viewportRenderer = null;
    _socket = null;

    _connectionStreamController.add(false);
    emit(FollowRTCIdle());
    await getAllClients();
  }

  Future<void> suspend() async {
    final currentState = state;
    if (currentState is FollowRTCConnected) {
      _peerConnection?.close();
      _peerConnection = null;
      _viewportRenderer = null;
      _socket = null;
      _connectionStreamController.add(false);
      emit(FollowRTCSuspended(currentState.uuid));
    }
  }
}
