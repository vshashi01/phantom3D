import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phantom3d/bloc/upload_model/uploadmodel_cubit.dart';
import 'package:phantom3d/widgets/draggable_dialog.dart';

class FileUploadDialog extends StatefulWidget {
  const FileUploadDialog(
      {Key key,
      this.uploadmodelCubit,
      this.height,
      this.width,
      this.useLocalHost = false})
      : super(key: key);
  final double height;
  final double width;
  final UploadmodelCubit uploadmodelCubit;
  final bool useLocalHost;

  @override
  _FileUploadDialogState createState() => _FileUploadDialogState();
}

class _FileUploadDialogState extends State<FileUploadDialog> {
  @override
  Widget build(BuildContext context) {
    return DraggableDialog(
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, color: Colors.white.withOpacity(0.2)),
        width: widget.width,
        height: widget.height,
        child: Column(children: [
          Text(
            'Upload Model',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
          _getButton(),
          _getFilename(),
          _getProgressBar(),
        ]),
      ),
      initialPosition: AnchoringPosition.topRight,
    );
  }

  Widget _getButton() {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: BlocBuilder<UploadmodelCubit, UploadModelState>(
          cubit: widget.uploadmodelCubit,
          builder: (context, state) {
            var buttonActive = false;
            if (state is UploadModelIdle) {
              buttonActive = true;
            }
            return ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: Row(children: [
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.folder_open_rounded,
                    color: Colors.white,
                  ),
                ),
                Text('Select file', style: TextStyle(color: Colors.white))
              ]),
              onPressed: buttonActive
                  ? () async {
                      await widget.uploadmodelCubit.upload(widget.useLocalHost);
                    }
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _getFilename() {
    return Expanded(
      flex: 2,
      child: BlocBuilder<UploadmodelCubit, UploadModelState>(
        cubit: widget.uploadmodelCubit,
        buildWhen: (previousState, currentState) {
          if (previousState.runtimeType == currentState.runtimeType) {
            return false;
          }

          return true;
        },
        builder: (context, state) {
          var text = "No file selected";

          if (state is UploadModelInProgress) {
            text = "Uploading: " + state.filepath;
          }

          return Text(
            text,
            style: TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _getProgressBar() {
    return Expanded(
      flex: 3,
      child: Container(
        child: BlocBuilder<UploadmodelCubit, UploadModelState>(
          cubit: widget.uploadmodelCubit,
          buildWhen: (previousState, currenState) {
            return true;
          },
          builder: (context, state) {
            if (state is UploadModelInProgress) {
              final fraction = state.progress;
              final value = fraction * 100;

              return Row(children: [
                Expanded(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white70,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 5,
                    value: fraction,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    "$value%",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ]);
            }
            return Container();
          },
        ),
      ),
    );
  }
}
