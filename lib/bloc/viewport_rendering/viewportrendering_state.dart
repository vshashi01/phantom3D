part of 'viewportrendering_cubit.dart';

abstract class ViewportRenderingState extends Equatable {
  const ViewportRenderingState(
      this.connected, this.imageBytes, this.message, this.uuid);

  final bool connected;
  final Uint8List imageBytes;
  final String message;
  final String uuid;

  @override
  List<Object> get props => [connected, imageBytes, message, uuid];
}

class ViewportRenderingInitial extends ViewportRenderingState {
  ViewportRenderingInitial() : super(false, null, "Initial state", "");
}

class ViewportRenderingConnected extends ViewportRenderingState {
  ViewportRenderingConnected(String uuid, {Uint8List imageBytes})
      : super(true, imageBytes, "Established Connection", uuid);
}

class ViewportRenderingDisconnected extends ViewportRenderingState {
  ViewportRenderingDisconnected(Uint8List imageBytes)
      : super(false, imageBytes, "Connection Lost", "");
}

class ViewportRenderingStreamingStarted extends ViewportRenderingState {
  ViewportRenderingStreamingStarted(String uuid, this.videoRenderer)
      : super(true, null, "Viewport Streaming Started", uuid);

  @override
  List<Object> get props => [videoRenderer];
  final RTCVideoRenderer videoRenderer;
}

class ViewportRenderingStreamingStopped extends ViewportRenderingState {
  ViewportRenderingStreamingStopped(String uuid)
      : super(true, null, "Viewport Streaming Stopped", uuid);
}

class ViewportLoading extends ViewportRenderingState {
  ViewportLoading(String message) : super(true, null, message, "");
}

class ViewportReporting extends ViewportRenderingState {
  ViewportReporting(this.messagePack, String uuid)
      : super(true, null, messagePack.toString(), uuid);

  final ServerMessagePack messagePack;
}
