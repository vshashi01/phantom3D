import 'package:phantom3d/multi_platform_libs/websocket/websocket_channel_stub.dart'
    if (dart.library.js) 'package:phantom3d/multi_platform_libs/websocket/websocket_channel_html.dart'
    if (dart.library.io) 'package:phantom3d/multi_platform_libs/websocket/websocket_channel_io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel getConnection(String url) {
  try {
    return webSocketChannelConnect(url);
  } catch (error) {
    rethrow;
  }
}
