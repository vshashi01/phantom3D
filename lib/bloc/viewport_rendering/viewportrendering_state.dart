part of 'viewportrendering_cubit.dart';

abstract class ViewportRenderingState extends Equatable {
  const ViewportRenderingState(this.connected, this.imageBytes, this.message);

  final bool connected;
  final Uint8List imageBytes;
  final String message;

  @override
  List<Object> get props => [connected, imageBytes, message];
}

class ViewportRenderingInitial extends ViewportRenderingState {
  ViewportRenderingInitial() : super(false, null, "Initial state");
}

class ViewportRenderingConnected extends ViewportRenderingState {
  ViewportRenderingConnected() : super(true, null, "Established Connection");
}

class ViewportRenderingDisconnected extends ViewportRenderingState {
  ViewportRenderingDisconnected(Uint8List imageBytes)
      : super(false, imageBytes, "Connection Lost");
}

class ViewportRenderingUpdate extends ViewportRenderingState {
  ViewportRenderingUpdate(Uint8List imageBytes, String message)
      : super(true, imageBytes, message);
}

class ViewportLoading extends ViewportRenderingState {
  ViewportLoading(String message) : super(true, null, message);
}

class ViewportReporting extends ViewportRenderingState {
  ViewportReporting(this.messagePack)
      : super(true, null, messagePack.toString());

  final ServerMessagePack messagePack;
}
