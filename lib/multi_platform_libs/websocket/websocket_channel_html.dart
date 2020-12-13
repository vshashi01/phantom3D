import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel webSocketChannelConnect(String url) {
  try {
    return HtmlWebSocketChannel.connect(url);
  } catch (error) {
    rethrow;
  }
}
