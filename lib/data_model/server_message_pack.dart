import 'package:equatable/equatable.dart';

class ServerMessagePack implements Equatable {
  ServerMessagePack({this.action, this.value});

  factory ServerMessagePack.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('action') && map.containsKey('value')) {
      return ServerMessagePack(action: map['action'], value: map['value']);
    } else
      return null;
  }

  final String action;
  final String value;

  @override
  List<Object> get props => [action, value];

  @override
  bool get stringify => true;

  @override
  String toString() {
    return "${action.toString()}:${value.toString()}";
  }
}
