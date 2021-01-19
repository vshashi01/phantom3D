import 'package:equatable/equatable.dart';

class EntityModel extends Equatable {
  const EntityModel({this.name, this.id, this.visible});

  final String name;
  final int id;
  final bool visible;

  factory EntityModel.fromMap(Map<String, dynamic> map) {
    return EntityModel(
        name: map['name'] ?? "Model",
        id: map['id'] ?? 0,
        visible: map['visible'] ?? false);
  }

  EntityModel copyWith({String name, int id, bool visible}) {
    return EntityModel(
        name: name ?? this.name,
        id: id ?? this.id,
        visible: visible ?? this.visible);
  }

  @override
  List<Object> get props => [name, id];
}

class EntityCollection extends Equatable {
  const EntityCollection(this.models);

  final List<EntityModel> models;

  bool get isEmpty {
    if (models != null && models.isNotEmpty) {
      return false;
    }

    return true;
  }

  factory EntityCollection.fromMap(Map<String, dynamic> map) {
    var _models = List<EntityModel>();

    final _modelMaps = (map['collection'] as List);
    print(_modelMaps);

    for (final modelMap in _modelMaps) {
      final _entity = EntityModel.fromMap(modelMap);

      _models.add(_entity);
    }

    return EntityCollection(_models);
  }

  factory EntityCollection.empty() {
    return EntityCollection(<EntityModel>[]);
  }

  @override
  List<Object> get props => [models];
}
