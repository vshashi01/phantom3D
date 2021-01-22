import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:phantom3d/multi_platform_libs/upload_file/upload_file.dart';

part 'uploadmodel_state.dart';

class UploadmodelCubit extends Cubit<UploadModelState> {
  UploadmodelCubit() : super(UploadModelIdle());

  String _uuid = "";

  set uuid(String id) {
    _uuid = id;
  }

  Future upload() async {
    await _upload();
  }

  Future _upload() async {
    try {
      if (_uuid == "") {
        return;
      }

      final info = await getAndProcessFilePlatormSpecific();

      if (info.containsKey("formData")) {
        final formData = info["formData"];
        final path = info["path"] ?? info["filename"];

        emit(UploadModelInProgress(filepath: path, progress: 0.0));

        if (formData != null) {
          await _putFile(formData, path);
          emit(UploadModelCompleted());
        }
      }

      emit(UploadModelIdle());
    } catch (error) {
      emit(UploadModelFailed());
      emit(UploadModelIdle());
    }
  }

  Future _putFile(FormData formData, String filepath) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = 50000000;
      dio.options.receiveTimeout = 50000000;
      await dio.put("http://localhost:8000/loadModel",
          data: formData, queryParameters: {"uuid": _uuid},
          onSendProgress: (sent, total) async* {
        _updateProgress(sent.toDouble(), total.toDouble(), filepath);
      });
    } catch (error) {
      print(error);
    }
  }

  void _updateProgress(double sentBytes, double totalBytes, String filepath) {
    final progress = (sentBytes / totalBytes);

    emit(UploadModelInProgress(progress: progress, filepath: filepath));
  }
}
