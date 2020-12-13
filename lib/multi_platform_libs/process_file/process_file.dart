import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:phantom3d/multi_platform_libs/process_file/process_file_stub.dart'
    if (dart.library.io) 'package:phantom3d/multi_platform_libs/process_file/process_file_io.dart'
    if (dart.library.html) 'package:phantom3d/multi_platform_libs/process_file/process_file_html.dart';

Future<FormData> processBaseFile(
    {String path, Uint8List bytes, String name}) async {
  return await processFile(path: path, bytes: bytes, name: name);
}
