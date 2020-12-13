import 'package:dio/dio.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:phantom3d/multi_platform_libs/process_file/process_file.dart';

Future<Map<String, dynamic>> stubGetAndProcessFilePlatormSpecific() async {
  try {
    final file = OpenFilePicker()
      ..filterSpecification = {
        'GLTF Object (*.gltf)': '*.gltf',
        //'All Files': '*.*'
      }
      ..defaultFilterIndex = 0
      ..defaultExtension = 'gltf'
      ..title = 'Select a model';

    final result = file.getFile();
    if (result != null) {
      final map = Map<String, dynamic>();

      final path = result.path;
      final filename = path.split("\\").last;
      FormData data = await processBaseFile(path: path, name: filename);

      map["path"] = path;
      map["filename"] = filename;
      map["formData"] = data;
      return map;
    }

    return null;
  } catch (error) {
    return null;
  }
}
