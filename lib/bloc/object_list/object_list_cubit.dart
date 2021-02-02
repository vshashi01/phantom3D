import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:phantom3d/bloc/upload_model/uploadmodel_cubit.dart';
import 'package:phantom3d/bloc/viewport_rendering/viewportrendering_cubit.dart';
import 'package:phantom3d/config/server_config.dart';
import 'package:phantom3d/data_model/entity_model.dart';
import 'package:phantom3d/data_model/server_message_pack.dart';

class ObjectlistCubit extends Cubit<EntityCollection> {
  ObjectlistCubit({UploadmodelCubit uploadmodelCubit, this.renderingCubit})
      : super(EntityCollection.empty()) {
    if (uploadmodelCubit != null) {
      _uploadModelSubscription = uploadmodelCubit.listen((state) async {
        if (state is UploadModelCompleted) {
          await update();
        }
      });
    }

    if (renderingCubit != null) {
      _visibilitySubcription = renderingCubit.messageStream.listen((message) {
        _processRenderingState(message);
      });
    }
  }

  final ViewportRenderingCubit renderingCubit;

  StreamSubscription _uploadModelSubscription;
  StreamSubscription _visibilitySubcription;

  List<EntityModel> _lastUpdatedObjectList =
      List<EntityModel>.empty(growable: true);

  @override
  Future close() {
    _uploadModelSubscription?.cancel();
    _visibilitySubcription?.cancel();
    return super.close();
  }

  Future update() async {
    if (renderingCubit.uuid == "") {
      return;
    }

    final dio = Dio();

    final response = await dio.get<Map<String, dynamic>>(
        //"http://localhost:8000/objects",
        getUrltoGetObjectList(renderingCubit.isUseLocalhost),
        queryParameters: {
          "uuid": renderingCubit.uuid,
        });

    if (response.statusCode == 200) {
      final collection = EntityCollection.fromMap(response.data);

      collection.models.removeWhere((element) =>
          (element.name.isEmpty || element.name == "" || element.name == " "));

      _lastUpdatedObjectList = collection.models;

      emit(collection);
    }
  }

  void setVisibility(String name, bool visible) {
    if (visible) {
      renderingCubit.showEntityFromName(name);
    } else {
      renderingCubit.hideEntityFromName(name);
    }
  }

  void _processRenderingState(ServerMessagePack messagePack) {
    if (messagePack != null) {
      if (messagePack.action.toLowerCase() == "hide" ||
          messagePack.action.toLowerCase() == "show") {
        final changedEntityIndex = _lastUpdatedObjectList
            .indexWhere((element) => element.name == messagePack.value);

        if (changedEntityIndex >= 0) {
          final changedEntity =
              _lastUpdatedObjectList.removeAt(changedEntityIndex);

          final changedModel =
              changedEntity.copyWith(visible: (!changedEntity.visible));

          _lastUpdatedObjectList.insert(changedEntityIndex, changedModel);

          emit(EntityCollection(_lastUpdatedObjectList));
        }
      }
    }
  }
}
