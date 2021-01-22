import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:phantom3d/bloc/viewport_rendering/viewportrendering_cubit.dart';
import 'package:phantom3d/data_model/entity_model.dart';
import 'package:phantom3d/data_model/server_message_pack.dart';

class SelectedEntityCubit extends Cubit<EntityCollection> {
  SelectedEntityCubit(this.renderingCubit) : super(EntityCollection.empty()) {
    if (renderingCubit != null) {
      _renderingCubitListener = renderingCubit.messageStream.listen((message) {
        _readReport(message);
      });
    }

    _selectedEntities = List<EntityModel>();
  }

  final ViewportRenderingCubit renderingCubit;
  StreamSubscription _renderingCubitListener;

  List<EntityModel> _selectedEntities;

  Future close() {
    _renderingCubitListener?.cancel();
    return super.close();
  }

  void select(String name) {
    renderingCubit?.selectEntityFromName(name, false);
  }

  void _readReport(ServerMessagePack message) {
    if (message.action == "selected") {
      if (message.value == "") {
        _selectedEntities.clear();
      } else {
        if (_selectedEntities.isNotEmpty) {
          final alreadySelected = _selectedEntities
              .any((element) => message.value.contains(element.name));

          if (alreadySelected) {
            return;
          }
        }
        final newSelectedEntity = EntityModel(name: message.value);
        _selectedEntities.add(newSelectedEntity);
      }

      emit(EntityCollection(_selectedEntities));
    }
  }
}
