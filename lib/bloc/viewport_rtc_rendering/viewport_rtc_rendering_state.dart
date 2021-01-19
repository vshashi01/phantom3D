part of 'viewport_rtc_rendering_cubit.dart';

abstract class ViewportRTCRenderingState extends Equatable {
  const ViewportRTCRenderingState();

  @override
  List<Object> get props => [];
}

class ViewportRTCRenderingIdle extends ViewportRTCRenderingState {}

class ViewportRTCRenderingConnected extends ViewportRTCRenderingState {
  ViewportRTCRenderingConnected(this.videoRenderer);

  final RTCVideoRenderer videoRenderer;
}
