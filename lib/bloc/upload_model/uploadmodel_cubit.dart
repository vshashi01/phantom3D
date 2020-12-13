import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:phantom3d/multi_platform_libs/upload_file/upload_file.dart';

part 'uploadmodel_state.dart';

class UploadmodelCubit extends Cubit<UploadModelState> {
  UploadmodelCubit() : super(UploadModelIdle());

  Future upload() async {
    //add(Upload());
    await _upload("");
  }

  Future _upload(String url) async {
    try {
      final info = await getAndProcessFilePlatormSpecific();

      if (info.containsKey("formData")) {
        final formData = info["formData"];
        final path = info["path"] ?? info["filename"];

        emit(UploadModelInProgress(filepath: path, progress: 0.0));
        // yield (UploadModelInProgress(
        //     filepath: path, sentBytes: 0.0, totalBytes: 1.0));

        if (formData != null) {
          await _putFile(formData, path);

          //yield UploadModelCompleted();
          emit(UploadModelCompleted());
        }
      }

      //yield UploadModelIdle();
      emit(UploadModelIdle());
    } catch (error) {
      // yield UploadModelFailed();
      // yield UploadModelIdle();
      emit(UploadModelFailed());
      emit(UploadModelIdle());
    }
  }

  Future _putFile(FormData formData, String filepath) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = 50000000;
      dio.options.receiveTimeout = 50000000;
      await dio.put("http://localhost:8000/loadModel", data: formData,
          onSendProgress: (sent, total) async* {
        // emit(UploadModelInProgress(
        //     sentBytes: sent.toDouble(),
        //     totalBytes: total.toDouble(),
        //     filepath: filepath));
        //yield UploadModelInProgress(
        //    sentBytes: sent.toDouble(),
        //    totalBytes: total.toDouble(),
        //    filepath: filepath);

        _updateProgress(sent.toDouble(), total.toDouble(), filepath);
      });
      // emit(UploadModelCompleted());
      // emit(UploadModelIdle());

    } catch (error) {
      // emit(UploadModelFailed());
      // emit(UploadModelIdle());
      print(error);
    }
  }

  void _updateProgress(double sentBytes, double totalBytes, String filepath) {
    final progress = (sentBytes / totalBytes);

    emit(UploadModelInProgress(progress: progress, filepath: filepath));
  }

  // @override
  // Stream<UploadModelState> mapEventToState(event) async* {
  //   if (event is Upload) {
  //     yield* _upload("");
  //   }
  // }
}
