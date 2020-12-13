//import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

Future<FormData> processFile(
    {String path, Uint8List bytes, String name}) async {
  return await _sendIOFile(path, name);
}

Future<FormData> _sendIOFile(String filepath, String filename) async {
  final formData = FormData.fromMap({
    "filetype": "gltf",
    "file": await MultipartFile.fromFile(filepath, filename: filename),
  });

  return formData;
}
