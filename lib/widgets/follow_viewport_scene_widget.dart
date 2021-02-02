import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:phantom3d/bloc/viewport_rtc_rendering/viewport_rtc_rendering_cubit.dart';
import 'package:phantom3d/data_model/scene_tab_container.dart';

class FollowViewportTabContainer implements SceneTabContainer {
  final String name;
  final bool closable;
  FollowRTCCubit rtcCubit;

  FollowViewportTabContainer(this.name, {this.closable = false});

  @override
  Future close() async {
    //nothing for now
  }

  @override
  Widget getWidget() {
    return FollowViewportScene(
      key: Key(name),
      rtcCubit: rtcCubit,
    );
  }

  @override
  Future init() async {
    rtcCubit = FollowRTCCubit();
  }

  @override
  String title() {
    return name;
  }

  @override
  bool canClose() {
    return closable;
  }
}

class FollowViewportScene extends StatefulWidget {
  const FollowViewportScene({Key key, this.rtcCubit}) : super(key: key);

  final FollowRTCCubit rtcCubit;

  @override
  _FollowViewportSceneState createState() => _FollowViewportSceneState();
}

class _FollowViewportSceneState extends State<FollowViewportScene> {
  var _useLocalHost = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    widget.rtcCubit.suspend();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FollowRTCCubit>.value(
      value: widget.rtcCubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarOpacity: 1.0,
          actions: [
            _buildLocalhostCheckbox(),
            _buildRefreshClientListButton(),
            _buildDisconnectButton()
          ],
        ),
        body: Container(
          color: Colors.black,
          child: BlocBuilder<FollowRTCCubit, FollowRTCState>(
            cubit: widget.rtcCubit,
            builder: (context, state) {
              if (state is FollowRTCConnected) {
                return Container(
                  child: RTCVideoView(state.videoRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
                );
              } else if (state is FollowRTCSuspended) {
                widget.rtcCubit.connect(state.uuid);
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is FollowRTCClientList) {
                return _drawClientList(state);
              }

              return Container(
                child: Center(
                  child: IconButton(
                    icon: Icon(
                      Icons.list,
                      color: Colors.white,
                    ),
                    iconSize: 50,
                    tooltip: "Get clients",
                    onPressed: () async {
                      await widget.rtcCubit.getAllClients(_useLocalHost);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _drawClientList(FollowRTCClientList state) {
    return Container(
      color: Colors.black,
      child: Center(
        child: ListView.builder(
          itemCount:
              state.clientList.isEmpty ? 1 : state.clientList.clients.length,
          itemBuilder: (context, index) {
            if (state.clientList.isEmpty) {
              return ListTile(
                leading: Icon(
                  Icons.no_cell_rounded,
                  color: Colors.white,
                ),
                title: Text("No clients available",
                    style: TextStyle(color: Colors.white)),
              );
            }

            return ListTile(
              leading: Icon(Icons.connect_without_contact, color: Colors.white),
              title: Text(state.clientList.clients[index],
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                await widget.rtcCubit?.connect(state.clientList.clients[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDisconnectButton() {
    return BlocBuilder<FollowRTCCubit, FollowRTCState>(
        builder: (context, state) {
      if (state is FollowRTCConnected) {
        return IconButton(
          tooltip: "Disconnect Follow Client",
          icon: Icon(Icons.cancel),
          onPressed: () {
            widget.rtcCubit?.disconnect();
          },
        );
      }

      return Container();
    });
  }

  Widget _buildRefreshClientListButton() {
    return BlocBuilder<FollowRTCCubit, FollowRTCState>(
        builder: (context, state) {
      if (state is FollowRTCClientList) {
        return IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          tooltip: "Refresh Client list",
          onPressed: () {
            widget.rtcCubit.getAllClients(_useLocalHost);
          },
        );
      }

      return Container();
    });
  }

  Widget _buildLocalhostCheckbox() {
    return BlocBuilder<FollowRTCCubit, FollowRTCState>(
        builder: (context, state) {
      if (state is FollowRTCIdle) {
        return Container(
          width: 200,
          height: 40,
          child: CheckboxListTile(
            tileColor: Colors.white54,
            checkColor: Colors.white,
            value: _useLocalHost,
            onChanged: (value) {
              _useLocalHost = value;
              setState(() {});
            },
            title: Text('Use Localhost', style: TextStyle(color: Colors.white)),
          ),
        );
      }

      return Container();
    });
  }
}
