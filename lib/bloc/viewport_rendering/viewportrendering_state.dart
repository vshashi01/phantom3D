part of 'viewportrendering_cubit.dart';

abstract class ViewportRenderingState extends Equatable {
  const ViewportRenderingState(this.message, this.uuid);

  final String message;
  final String uuid;

  @override
  List<Object> get props => [message, uuid];
}

class ViewportRenderingConnected extends ViewportRenderingState {
  ViewportRenderingConnected(String uuid)
      : super("Established websocket Connection", uuid);
}

class ViewportRenderingDisconnected extends ViewportRenderingState {
  ViewportRenderingDisconnected() : super("Websocket Connection Lost", null);
}

class ViewportRenderingStreaming extends ViewportRenderingState {
  ViewportRenderingStreaming(String uuid, this.videoRenderer)
      : super("Viewport Streaming", uuid);

  @override
  List<Object> get props => [videoRenderer];
  final RTCVideoRenderer videoRenderer;
}

class ViewportRenderingSuspended extends ViewportRenderingState {
  ViewportRenderingSuspended(String uuid)
      : super("Suspending Render Stream", uuid);
}
