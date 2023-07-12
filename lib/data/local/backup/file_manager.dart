import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileManager {
  Future<String?> get _directoryPath async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  Future<File> get _jsonFile async {
    final path = await _directoryPath;
    return File('$path/budgetup_data_export.json');
  }

  readJsonFile() async {
    String fileContent = "";

    File? file;
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['.json'],
      type: FileType.custom,
    );
    if (result != null && result.files.single.path != null) {
      file = File(result.files.single.path!);
    }

    if (file != null && await file.exists()) {
      try {
        fileContent = await file.readAsString();
      } catch (e) {
        print(e);
      }
    }

    return jsonDecode(fileContent);
  }

  Future<bool> writeJsonFile(String jsonData) async {
    File file = await _jsonFile;
    final newFile = await file.writeAsString(jsonData);
    final saved = await Share.shareXFiles(
      [
        XFile(
          newFile.path,
          mimeType: "application/json",
        )
      ],
    );
    return saved.status == ShareResultStatus.success;
  }
}
