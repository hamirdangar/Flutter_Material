import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../constant.dart';

class SaveImageResponse {
  bool isSuccess;
  String message;
  SaveImageResponse(this.isSuccess,this.message);
}

ValueNotifier<bool> isDownloading = ValueNotifier(false);
bool  isDownload = false;

class ImageSaver {
  static Future<SaveImageResponse> saveNetworkVideo(String imageUrl,BuildContext context,String folderName) async {
    try {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return const CupertinoAlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoActivityIndicator(),
                Text('Downloading...'),
              ],
            ),
          );
        },
      );
      isDownloading.value = true;
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/$folderName';
      await Directory(folderPath).create(recursive: true);
      final response = await HttpClient().getUrl(Uri.parse(imageUrl));
      final httpClientResponse = await response.close();
      final Uint8List bytes = await consolidateHttpClientResponseBytes(httpClientResponse);
      final fileName = 'ai_video_animate_anime_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final filePath = '$folderPath/$fileName';
      await File(filePath).writeAsBytes(bytes);
      final result = await ImageGallerySaverPlus.saveFile(filePath);
      if (result['isSuccess']) {
        isDownloading.value = false;
        isDownload = true;
        Navigator.pop(context);
        showToast();
        return SaveImageResponse(true, 'Image saved successfully');
      } else {
        Navigator.pop(context);
        isDownloading.value = false;
        showToastError();
        return SaveImageResponse(false, 'Error saving the image');
      }
    } catch (e) {
      print('Error: $e');
      isDownloading.value = false;
      Navigator.pop(context);
      showToastError();
      return SaveImageResponse(false, 'Error saving the image');
    }
  }

  static Future<SaveImageResponse> saveUint8ListNetworkImage(Uint8List imageData,BuildContext context) async {
    try {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return const CupertinoAlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoActivityIndicator(),
                Text('Downloading...'),
              ],
            ),
          );
        },
      );
      isDownloading.value = true;
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/creation';

      await Directory(folderPath).create(recursive: true);

      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '$folderPath/$fileName';

      await File(filePath).writeAsBytes(imageData);

      final result = await ImageGallerySaverPlus.saveFile(filePath);

      if (result['isSuccess']) {
        isDownloading.value = false;
        showToast();
        isDownload = true;
        Navigator.pop(context);
        return SaveImageResponse(true, 'Image saved successfully');
      } else {
        isDownloading.value = false;
        showToastError();
        Navigator.pop(context);
        return SaveImageResponse(false, 'Error saving the image');
      }
    } catch (e) {
      isDownloading.value = false;
      print('Error: $e');
      showToastError();
      Navigator.pop(context);
      return SaveImageResponse(false, 'Error saving the image');
    }
  }

  static Future<SaveImageResponse> saveNetworkGif(String imageUrl,BuildContext context,String folderName) async {
    try {
      isDownloading.value = true;
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return const CupertinoAlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoActivityIndicator(),
                Text('Downloading...'),
              ],
            ),
          );
        },
      );
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/$folderName';
      await Directory(folderPath).create(recursive: true);
      final response = await HttpClient().getUrl(Uri.parse(imageUrl));
      final httpClientResponse = await response.close();
      final Uint8List bytes = await consolidateHttpClientResponseBytes(httpClientResponse);

      final fileName = 'faceswap_${DateTime.now().millisecondsSinceEpoch}.gif';

      final filePath = '$folderPath/$fileName';

      await File(filePath).writeAsBytes(bytes);

      final result = await ImageGallerySaverPlus.saveFile(filePath, isReturnPathOfIOS: true);

      if (result['isSuccess']) {
        isDownloading.value = false;
        isDownload = true;
        Navigator.pop(context);
        showToast();
        return SaveImageResponse(true, 'video saved successfully');
      } else {
        showToastError();
        isDownloading.value = false;
        Navigator.pop(context);
        return SaveImageResponse(false, 'video saving the image');
      }
    } catch (e) {
      Navigator.pop(context);
      isDownloading.value = false;
      showToastError();
      print('Error: $e');
      return SaveImageResponse(false, 'Error saving the video');
    }
  }

  static Future<SaveImageResponse> saveNetworkImage(String imageUrl,BuildContext context) async {
    try {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return const CupertinoAlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoActivityIndicator(),
                Text('Downloading...'),
              ],
            ),
          );
        },
      );
      isDownloading.value = true;
      final directory = await getApplicationDocumentsDirectory();
      final folderPath = '${directory.path}/creation';
      await Directory(folderPath).create(recursive: true);
      final response = await HttpClient().getUrl(Uri.parse(imageUrl));
      final httpClientResponse = await response.close();
      final Uint8List bytes = await consolidateHttpClientResponseBytes(httpClientResponse);

      final fileName = 'faceswap_${DateTime.now().millisecondsSinceEpoch}.png';

      final filePath = '$folderPath/$fileName';

      await File(filePath).writeAsBytes(bytes);

      final result = await ImageGallerySaverPlus.saveFile(filePath);

      if (result['isSuccess']) {
        isDownloading.value = false;
        showToast();
        isDownload = true;
        Navigator.maybePop(context);
        return SaveImageResponse(true, 'Image saved successfully');
      } else {
        isDownloading.value = false;
        showToastError();
        Navigator.maybePop(context);
        return SaveImageResponse(false, 'Error saving the image');
      }
    } catch (e) {
      print('Error: $e');
      isDownloading.value = false;
      showToastError();
      Navigator.maybePop(context);
      return SaveImageResponse(false, 'Error saving the image');
    }
  }

  static Future<bool?> showToastError() => Fluttertoast.showToast(msg: 'Error saving the Image please try aging', backgroundColor: backgroundColor, textColor: textColor);

  static Future<bool?> showToast() => Fluttertoast.showToast(msg: 'Image saved successfully', backgroundColor: backgroundColor, textColor: textColor);
}














// Future<SaveImageResponse> saveImage(String imageUrl) async {
//     final response = await Dio().get(
//       imageUrl,
//       options: Options(responseType: ResponseType.bytes),
//     );
//     final bytes = Uint8List.fromList(response.data);
//     var directory;
//     if (Platform.isIOS) {
//       directory = await getDownloadsDirectory();
//     }
//     directory = "/storage/emulated/0/Download/";
//     final newFolder = await Directory('$directory/Ai Art Avatar').create(recursive: true);
//
//     final insideFolder = await Directory('${newFolder.path}/Text To Images').create(recursive: true);
//
//     final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
//
//     final filePath = '${insideFolder.path}/$fileName';
//
//     await File(filePath).writeAsBytes(bytes);
//
//     // final result = await ImageGallerySaver.saveFile(filePath);
//     //
//     // if (result['isSuccess']) {
//     //   return SaveImageResponse(true, 'Image saved successfully');
//     // } else {
//     //   // Error saving the image
//     //   return SaveImageResponse(false, 'Error saving the image');
//     // }
//   }
// final result = await ImageGallerySaver.saveFile(filePath);
//
// if (result['isSuccess']) {
//   return SaveImageResponse(true, 'Image saved successfully');
// } else {
//   return SaveImageResponse(false, 'Error saving the image');
// }
