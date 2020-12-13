part of 'uploadmodel_cubit.dart';

abstract class UploadModelState extends Equatable {
  const UploadModelState();

  @override
  List<Object> get props => [];
}

class UploadModelIdle extends UploadModelState {}

class UploadModelInProgress extends UploadModelState {
  UploadModelInProgress({this.progress, this.filepath});
  final double progress;
  final String filepath;

  @override
  List<Object> get props => [progress, filepath];
}

class UploadModelCompleted extends UploadModelState {}

class UploadModelFailed extends UploadModelState {}
