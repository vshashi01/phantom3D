import 'dart:typed_data';
import 'package:dio/dio.dart';

Future<FormData> processFile(
    {String path, Uint8List bytes, String name}) async {
  return await _sendFileOverWeb(bytes, name);
}

Future<FormData> _sendFileOverWeb(Uint8List bytes, String filename) async {
  final formData = FormData.fromMap({
    "filetype": "gltf",
    "file": MultipartFile.fromBytes(bytes, filename: filename)
  });

  return formData;
}
