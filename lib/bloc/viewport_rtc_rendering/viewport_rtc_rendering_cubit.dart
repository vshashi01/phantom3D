import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:phantom3d/multi_platform_libs/websocket/websocket_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'viewport_rtc_rendering_state.dart';

class ViewportRTCRenderingCubit extends Cubit<ViewportRTCRenderingState> {
  ViewportRTCRenderingCubit(this.uuid) : super(ViewportRTCRenderingIdle());

  WebSocketChannel _socket;
  RTCPeerConnection _peerConnection;
  RTCVideoRenderer _viewportRenderer;
  String uuid;

  Future<void> connect() async {
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

        emit(ViewportRTCRenderingConnected(_viewportRenderer));
      }
    };

    _peerConnection.onRemoveStream = (stream) {
      _viewportRenderer = null;

      emit(ViewportRTCRenderingIdle());
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
}
