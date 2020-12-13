import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

WebSocketChannel webSocketChannelConnect(String url) {
  try {
    return IOWebSocketChannel.connect(url);
  } catch (error) {
    rethrow;
  }
}
