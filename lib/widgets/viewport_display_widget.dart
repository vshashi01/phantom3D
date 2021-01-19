import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:phantom3d/bloc/viewport_rendering/viewportrendering_cubit.dart';
import 'package:phantom3d/bloc/viewport_rtc_rendering/viewport_rtc_rendering_cubit.dart';

class ViewportDisplay extends StatefulWidget {
  const ViewportDisplay({Key key, this.uuid}) : super(key: key);

  final String uuid;

  @override
  _ViewportDisplayState createState() => _ViewportDisplayState();
}

class _ViewportDisplayState extends State<ViewportDisplay> {
  ViewportRTCRenderingCubit renderingCubit;

  @override
  void initState() {
    if (widget.uuid == null) {
      final tempCubit = context.read<ViewportRenderingCubit>();
      renderingCubit = ViewportRTCRenderingCubit(tempCubit.uuid);
    } else {
      renderingCubit = ViewportRTCRenderingCubit(widget.uuid);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ViewportRTCRenderingCubit, ViewportRTCRenderingState>(
      cubit: renderingCubit,
      builder: (context, state) {
        if (state is ViewportRTCRenderingConnected) {
          return Container(
            child: RTCVideoView(state.videoRenderer),
          );
        }

        return Container(
          child: Center(
            child: ElevatedButton(
              child: Text("Connect go crazy"),
              onPressed: () async {
                await renderingCubit?.connect();
              },
            ),
          ),
        );
      },
    );
  }
}
