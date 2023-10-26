import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';


class SaveImageResponse {
  bool isSuccess;
  String message;
  SaveImageResponse(this.isSuccess, this.message);
}

class ImageSaver {
  Future<SaveImageResponse> saveImage(imageUrl) async {

    var directory;
    String? folderPath;

    if(Platform.isAndroid){
      directory = await getExternalStorageDirectory();
      folderPath = '${directory.path}/ArDraw';
    }else{
      directory = await getApplicationDocumentsDirectory();
      folderPath = '${directory.path}/ArDraw';
    }

    await Directory(folderPath).create(recursive: true);

    final response = await imageUrl;

    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final filePath = '$folderPath/$fileName';

    final result = await File(filePath).writeAsBytes(response);

    await ImageGallerySaver.saveFile(filePath);

    if (result != null) {
      return SaveImageResponse(true, 'Image saved successfully');
    } else {
      return SaveImageResponse(false, 'Error saving the image');
    }
  }
}

/*import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

Future<void> saveScreenshot(Uint8List screenshotBytes, String folderName) async {
  try {
    imageNumber++;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("imageNumber", imageNumber);
    log("imageNumber :- $imageNumber");
    final directory = await getExternalStorageDirectory();

    final rootPath = directory!.path;

    /// Create the full folder path
    final folderPath = path.join(rootPath, folderName);

    /// Create the folder if it doesn't exist
    final folder = Directory(folderPath);
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }

    /// Create a file name
    final fileName = 'SaveImage$imageNumber.png';
    final filePath = path.join(folderPath, fileName);

    /// Compress and save the image
    final compressedBytes = await FlutterImageCompress.compressWithList(
      screenshotBytes,
      minHeight: 1920, // Optional: Set the desired height
      minWidth: 1080, // Optional: Set the desired width
      quality: 90, // Optional: Set the desired quality (0-100)
    );

    /// Write the compressed image bytes to the file
    final file = File(filePath);
    await file.writeAsBytes(compressedBytes);

    log('Screenshot saved at: $filePath');

    // Save the image to the gallery
    final result = await ImageGallerySaver.saveFile(filePath);
    log('Image saved to gallery: $result');

    // Notify the media scanner about the new image
    await MethodChannel('plugins.flutter.io/image_gallery_saver')
        .invokeMethod('saveImage', {'file_path': filePath});

    moveFolder(
      "/storage/emulated/0/Android/data/com.example.geo_location_app/files/geoStamp/",
      "/storage/emulated/0/Download/geoStamp/",
    );
  } catch (e) {
    log('Error saving screenshot: $e');
  }
}*/

