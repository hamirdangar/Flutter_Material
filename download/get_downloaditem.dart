
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../constant.dart';
import '../service/sharedPreferencesService.dart';

enum ImageAnimatorStatus { complete, isEmpty ,loading}
enum GetCreationStatus {complete,isEmpty,loading}
enum GeneratStatus { complete,generating}
enum AiImageVideoStatus { complete, isEmpty ,loading}
enum FaceDanceStatus { complete, isEmpty ,loading}
// enum TextToVideo { generating, complete, isEmpty ,loading}
// enum ImageToVideo { generating, complete, isEmpty ,loading}

class CreationController extends GetxController {

  RxList<File> creation = <File>[].obs;
  Rx<GetCreationStatus> getCreationStatus = GetCreationStatus.isEmpty.obs;


  RxList<File> image_animator = <File>[].obs;
  RxList<File> ai_image_video = <File>[].obs;
  RxList<File> fane_dance_video = <File>[].obs;
  Rx<ImageAnimatorStatus> imageAnimatorStatus = ImageAnimatorStatus.isEmpty.obs;
  Rx<AiImageVideoStatus> aiImageVideoStatus = AiImageVideoStatus.isEmpty.obs;
  Rx<FaceDanceStatus> faceDanceStatus = FaceDanceStatus.isEmpty.obs;
  Rx<GeneratStatus> generateStatus = GeneratStatus.complete.obs;

  @override
  void onInit() {
    super.onInit();
    getImageAnimator();
    getAiImageVideo();
    getFaceDanceVideo();
    chackSharePrefarence();
    getCreation();
  }



  Future<void> getCreation() async {
    getCreationStatus.value = GetCreationStatus.loading;
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/creation';
    final folder = Directory(folderPath);
    if (await folder.exists()) {
      final imageFiles = await _getImagesInFolder(folder);
      imageFiles.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
      creation.assignAll(imageFiles);
      getCreationStatus.value = GetCreationStatus.complete;
    } else {
      creation.clear();
      getCreationStatus.value = GetCreationStatus.isEmpty;
      if (kDebugMode) {
        print('Directory not found.');
      }
    }
  }

  Future<void> chackSharePrefarence() async {
    // final taskids = await SharedPreferencesService.gettaskID();
    // print('ham he yam1=========================$taskids');
    // if(taskids.isNotEmpty){
    //   print('ham he yam=========================$taskids');
    //   generateStatus.value = GeneratStatus.generating;
    //   var videoTask = await fetchVideoTask(taskids);
    //   if (videoTask != null) {
    //     print('Result URL: ${videoTask.result}');
    //     print('Result Cover URL: ${videoTask.resultCover}');
    //     if(videoTask.result.isNotEmpty){
    //       final directory = await getApplicationDocumentsDirectory();
    //       final folderPath = '${directory.path}/ai_image_video';
    //       await Directory(folderPath).create(recursive: true);
    //       final response = await HttpClient().getUrl(Uri.parse(videoTask.result));
    //       final httpClientResponse = await response.close();
    //       final Uint8List bytes = await consolidateHttpClientResponseBytes(httpClientResponse);
    //       final fileName = 'ai_video_animate_anime_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    //       final filePath = '$folderPath/$fileName';
    //       await File(filePath).writeAsBytes(bytes);
    //       final result = await ImageGallerySaver.saveFile(filePath);
    //       Fluttertoast.showToast(msg: 'Image saved successfully', backgroundColor: backgroundColor, textColor: textColor);
    //       await getAiImageVideo();
    //       generateStatus.value = GeneratStatus.complete;
    //     }else{
    //       await Future.delayed(const Duration(seconds: 2));
    //       chackSharePrefarence();
    //     }
    //   }
    // }
  }


  Future<void> getImageAnimator() async {
    imageAnimatorStatus.value = ImageAnimatorStatus.loading;
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/image_animator';
    final folder = Directory(folderPath);
    if (await folder.exists()) {
      final imageFiles = await _getImagesInFolder(folder);
      imageFiles.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
      image_animator.assignAll(imageFiles);
      imageAnimatorStatus.value = ImageAnimatorStatus.complete;
    } else {
      image_animator.clear();
      imageAnimatorStatus.value = ImageAnimatorStatus.isEmpty;
      print('Directory not found.');
    }
  }

  Future<void> getFaceDanceVideo() async {
    faceDanceStatus.value = FaceDanceStatus.loading;
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/Face_Dance';
    final folder = Directory(folderPath);
    if (await folder.exists()) {
      final imageFiles = await _getImagesInFolder(folder);
      imageFiles.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
      fane_dance_video.assignAll(imageFiles);
      faceDanceStatus.value = FaceDanceStatus.complete;
    } else {
      fane_dance_video.clear();
      faceDanceStatus.value = FaceDanceStatus.isEmpty;
      print('Directory not found.');
    }
  }

  Future<void> getAiImageVideo() async {
    aiImageVideoStatus.value = AiImageVideoStatus.loading;
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/ai_image_video';
    final folder = Directory(folderPath);

    if (await folder.exists()) {
      final imageFiles = await _getImagesInFolder(folder);
      imageFiles.sort((a, b) {
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
      ai_image_video.assignAll(imageFiles);
      aiImageVideoStatus.value = AiImageVideoStatus.complete;
    } else {
      ai_image_video.clear();
      aiImageVideoStatus.value = AiImageVideoStatus.isEmpty;
      print('Directory not found.');
    }
  }

  // Future<void> getAiVideo() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final folderPath = '${directory.path}/aiVideo';
  //   final folder = Directory(folderPath);
  //
  //   if (await folder.exists()) {
  //     final imageFiles = await _getImagesInFolder(folder);
  //     imageFiles.sort((a, b) {
  //       return b.lastModifiedSync().compareTo(a.lastModifiedSync());
  //     });
  //     ai_image_video.assignAll(imageFiles);
  //   } else {
  //     ai_image_video.clear();
  //     print('Directory not found.');
  //   }
  // }

  Future<List<File>> _getImagesInFolder(Directory directory) async {
    final imageFiles = <File>[];
    final list = directory.list();
    await for (final entity in list) {
      if (entity is File && _isImageFile(entity)) {
        imageFiles.add(entity);
      } else if (entity is Directory) {
        final subdirectoryImages = await _getImagesInFolder(entity);
        imageFiles.addAll(subdirectoryImages);
      }
    }

    return imageFiles;
  }

  bool _isImageFile(File file) {
    final extensions = ['.jpg', '.jpeg', '.png', '.gif','.mp4'];
    final extension = file.path.toLowerCase();
    return extensions.any((ext) => extension.endsWith(ext));
  }
}
