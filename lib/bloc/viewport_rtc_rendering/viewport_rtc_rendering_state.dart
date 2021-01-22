part of 'viewport_rtc_rendering_cubit.dart';

abstract class FollowRTCState extends Equatable {
  const FollowRTCState();

  @override
  List<Object> get props => [];
}

class FollowRTCIdle extends FollowRTCState {}

class FollowRTCClientList extends FollowRTCState {
  final ClientList clientList;

  FollowRTCClientList(this.clientList);

  @override
  List<Object> get props => [...clientList.clients];
}

class FollowRTCConnected extends FollowRTCState {
  FollowRTCConnected(this.videoRenderer, this.uuid);

  final RTCVideoRenderer videoRenderer;
  final String uuid;
}

class FollowRTCSuspended extends FollowRTCState {
  FollowRTCSuspended(this.uuid);

  final String uuid;

  @override
  List<Object> get props => [uuid];
}
