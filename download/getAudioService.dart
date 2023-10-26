import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GetAudioService {
  static Future<List<File>> getAudioFiles() async {
    var directory;
    String? folderPath;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      folderPath = '${directory.path}/Ringtone';
    } else {
      directory = await getApplicationDocumentsDirectory();
      folderPath = '${directory.path}/Ringtone';
    }

    final folder = await Directory(folderPath).create(recursive: true);

    if (await folder.exists()) {final audiolist = await _getAudioInFolder(folder);

    audiolist.sort((a, b) {
      return b.lastModifiedSync().compareTo(a.lastModifiedSync());
    });

    return audiolist;
    } else {
      return [];
    }
  }

  static Future<bool> deleteAudio(File audioFile) async {
    try {
      await audioFile.delete();
      return true;
    } catch (e) {
      print('Error deleting audio file: $e');
      return false;
    }
  }

  static Future<List<File>> _getAudioInFolder(Directory directory) async {
    final audioFiles = <File>[];
    final list = directory.list();
    await for (final entity in list) {
      if (entity is File && _isAudioFile(entity)) {
        audioFiles.add(entity);
      } else if (entity is Directory) {
        final subdirectoryAudio = await _getAudioInFolder(entity);
        audioFiles.addAll(subdirectoryAudio);
      }
    }

    return audioFiles;
  }

  static bool _isAudioFile(File file) {
    final extensions = ['.mp3'];
    final extension = file.path.toLowerCase();
    return extensions.any((ext) => extension.endsWith(ext));
  }
}
