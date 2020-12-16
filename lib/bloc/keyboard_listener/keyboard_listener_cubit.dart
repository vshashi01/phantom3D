import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class KeyboardListenerCubit extends Cubit<RawKeyEvent> {
  KeyboardListenerCubit() : super(null);

  void add(RawKeyEvent keyEvent) {
    emit(keyEvent);
  }
}
