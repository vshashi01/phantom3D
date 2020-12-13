import 'package:file_picker/file_picker.dart';
import 'package:phantom3d/multi_platform_libs/process_file/process_file.dart';

Future<Map<String, dynamic>> stubGetAndProcessFilePlatormSpecific() async {
  try {
    final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gltf'],
        withData: true,
        allowMultiple: false);

    if (filePickerResult != null) {
      final file = filePickerResult.files.first;

      final map = Map<String, dynamic>();
      if (file != null) {
        final formData = await processBaseFile(
            path: file.path, bytes: file.bytes, name: file.name);
        //return formData;

        map["path"] = file.path;
        map["filename"] = file.name;
        map["formData"] = formData;
        return map;
      }
    }
    return null;
  } catch (error) {
    print(error);
    return null;
  }
}
