// ignore_for_file: empty_catches, library_private_types_in_public_api, use_build_context_synchronously, duplicate_ignore
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scan_solve/screen/in_app_purchase/app.dart';
import 'package:scan_solve/screen/result_screen.dart';
import 'package:scan_solve/services/InterstitialAdUtil.dart';
import 'package:scan_solve/services/adsVariable.dart';
import 'package:scan_solve/services/app_open_ad_manager.dart';
import 'package:scan_solve/services/image_press_unpress.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_database.dart';
import '../services/dialog.dart';
import '../services/permission.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  bool _isCameraInitialized = false;
  DialogService dialogService = DialogService();
  final dbHelper = DatabaseHelper();
  late final List<ChatMessage> _messages = [];
  TextEditingController textEditingController = TextEditingController();
  bool ison = false;
  bool showLoading = false;
  int count = 0;

  @override
  void initState() {
    initializeCamera();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    switch(state){
      case AppLifecycleState.resumed:
        await initializeCamera;
        break;
      case AppLifecycleState.inactive:
        await controller?.dispose();
        break;
      case AppLifecycleState.paused:
        await controller?.dispose();
        break;
      case AppLifecycleState.detached:
        await controller?.dispose();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }


  Future<void> shareprefrencecount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    count = prefs.getInt('count') ?? 0;
  }

  Future<void> loadMessage() async {
    final messages = await dbHelper.getMessages();
    _messages.clear();
    _messages.addAll(messages.map((message) => ChatMessage(
          id: message[DatabaseHelper.columnId],
          userInput: message[DatabaseHelper.columnUserInput],
          apiResponse: message[DatabaseHelper.columnApiResponse],
        )));
  }
  
  Future<void> initializeCamera() async {
    WidgetsFlutterBinding.ensureInitialized();

    final cameraPermissionStatus = await Permission.camera.request();

    if (cameraPermissionStatus.isGranted) {
      cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        onNewCameraSelected(cameras[0]);
      }
    } else if (cameraPermissionStatus.isPermanentlyDenied) {
      // ignore: use_build_context_synchronously
      showCupertinoDialog(
        context: context, // Use the appropriate context here
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
                'Please allow camera permission in settings to use the camera.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Setting'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
    } else {
      // ignore: use_build_context_synchronously
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Camera Permission Required'),
            content: const Text(
                'Please allow camera permission in settings to use the camera.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Setting'),
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await previousCameraController?.dispose();
    setState(() {
      controller = cameraController;
    });
    try {
      await cameraController.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = controller!.value.isInitialized;
          ison = false;
        });
      }
    } on CameraException {}
  }

  Future<void> _pickImageInGallery() async {
    AppOpenAdManager.shouldShowAd = false;
    final ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageCropper(pickedFile);
    }
    AppOpenAdManager.shouldShowAd = true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!_isCameraInitialized) {
      return const Center(
        child: CupertinoActivityIndicator(
          color: Color(0xff70c484),
          radius: 15,
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _isCameraInitialized
              ? SizedBox(
                  width: size.width,
                  height: size.height,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      //width: size.width,
                      height: size.height,
                      child: CameraPreview(controller!),
                    ),
                  ),
                )
              : const SizedBox(),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 100.h, right: 50.w, left: 50.w),
              child: Row(
                children: [
                  PressUnpress(
                    imageAssetUnPress: ison != true
                        ? 'images/camera_screen/flash_off.png'
                        : 'images/camera_screen/flash_on.png',
                    imageAssetPress: 'images/camera_screen/flash_off.png',
                    onTap: () {
                      if (!ison) {
                        setState(() {
                          ison = true;
                        });
                        controller?.setFlashMode(FlashMode.torch);
                      } else {
                        controller?.setFlashMode(FlashMode.off);
                        setState(() {
                          ison = false;
                        });
                      }
                    },
                    height: 65.h,
                    width: 65.w,
                  ),
                  const Spacer(),
                  SizedBox(width: 30.w),
                  PressUnpress(
                    imageAssetUnPress:
                        'images/camera_screen/history_unpress.png',
                    imageAssetPress: 'images/camera_screen/history_press.png',
                    onTap: () {
                      buildShowModalBottomSheet(context);
                    },
                    height: 65.h,
                    width: 65.w,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 100.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PressUnpress(
                    imageAssetUnPress:
                        'images/camera_screen/keyboard_unpress.png',
                    imageAssetPress:
                        'images/camera_screen/keyboard_press.png',
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      bool isLogged = prefs.getBool('isLogged') ?? false;
                      if (!isLogged) {
                        buildShowBottomSheet(context);
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const UpsellScreen(item: false)));
                      }
                    },
                  height: 102.h,
                  width: 102.w,
                ),
                PressUnpress(
                  imageAssetUnPress:
                      'images/camera_screen/capture_button_unpress.png',
                  imageAssetPress:
                      'images/camera_screen/capture_button_press.png',
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    bool isLogged = prefs.getBool('isLogged') ?? false;
                    if (isLogged) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const UpsellScreen(item: false)));
                    } else {
                      setState(() {
                        showLoading = true;
                      });
                      try {
                        XFile picture = await controller!.takePicture();
                        if (mounted) {
                          setState(() {
                            showLoading = false;
                          });
                          imageCropper(picture);
                        }
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: 'Please try again',
                          textColor: Colors.white,
                          backgroundColor: const Color(0xff70c484),
                        );
                        setState(() {
                          showLoading = false;
                        });
                      }
                    }
                  },
                  height: 200.h,
                  width: 200.w,
                ),
                PressUnpress(
                  imageAssetUnPress:
                      'images/camera_screen/gallery_unpress.png',
                  imageAssetPress: 'images/camera_screen/gallery_press.png',
                  onTap: () {
                    MyPermissionHandler.checkPermission(context, 'gallery')
                        .then(
                      (value) async {
                        if (value == true) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          bool isLogged = prefs.getBool('isLogged') ?? false;

                          if (!isLogged) {
                            _pickImageInGallery();
                          }
                          else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const UpsellScreen(item: false)));
                          }
                        } else {
                          DialogService.showpermissiondialog(
                              context, 'gallery');
                        }
                      },
                    );
                  },
                  height: 102.h,
                  width: 102.w,
                ),
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 400.h,
              child: Center(
                  child: Column(
                children: [
                  Image.asset(
                    'images/camera_screen/Take a picture of a question.png',
                    height: 38.h,
                    width: 539.w,
                  ),
                  Image.asset(
                    'images/camera_screen/scan_corner.png',
                    height: 345.h,
                    width: 967.w,
                  ),
                ],
              ))),
          if (showLoading)
            const Center(
                child: CupertinoActivityIndicator(
              color: Color(0xff70c484),
              radius: 15,
            ))
        ],
      ),
    );
  }

  Future<dynamic> buildShowBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      enableDrag: true,
      useRootNavigator: true,
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, top: 50.h),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 3,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 55.sp,
                            color: const Color(0xff70c484)),
                      ),
                      PressUnpress(
                        imageAssetUnPress:
                            'images/camera_screen/close_unpress.png',
                        imageAssetPress:
                            'images/camera_screen/close_press.png',
                        onTap: () {
                          Navigator.pop(context);
                        },
                        height: 75.h,
                        width: 75.w,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: textEditingController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20)),
                      hintText: 'Type your question here...',
                    ),
                    cursorColor: Colors.grey,
                    maxLines: 3,
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  PressUnpress(
                    imageAssetUnPress:
                        'images/camera_screen/show_solution_unpress.png',
                    imageAssetPress:
                        'images/camera_screen/show_solution_press.png',
                    onTap: () {
                      textEditingController.text.isNotEmpty
                          ? checkConnectivity().then((isConnected) async {
                              if (isConnected) {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ResponseScreen(text: textEditingController.text, item: false,)));
                                // InterstitialAdManager.showInterstitial(
                                //    ,
                                //     'pushNewScreen1',
                                //     AdsVariable.fullscreen_camera_screen,
                                //     context);
                              } else {
                                DialogService.showCheckConnectivity(context);
                              }
                            })
                          : Fluttertoast.showToast(
                              msg: 'Please type question.',
                              textColor: Colors.white,
                              backgroundColor: const Color(0xff70c484));
                    },
                    height: 150.h,
                    width: 550.w,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      useRootNavigator: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: FutureBuilder<void>(
            future: loadMessage(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                if (_messages.isEmpty) {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 50.w, vertical: 50.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'History',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 55.sp,
                                  color: const Color(0xff70c484)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff70c484),
                                  shape: const StadiumBorder()),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/chat_screen/logo.png',
                              height: 418.h,
                              width: 436,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              'No history found',
                              style: TextStyle(
                                fontSize: 55.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 50.w, vertical: 50.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'History',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 55.sp,
                                  color: const Color(0xff70c484)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff70c484),
                                  shape: const StadiumBorder()),
                              onPressed: () {
                                Navigator.pop(context);
                                dbHelper.deleteAllMessages();
                              },
                              child: const Text('Clear'),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          //padding: const EdgeInsets.all(10),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            ChatMessage message = _messages[index];
                            return Column(
                              children: [
                                ListTile(
                                  title: const Text(
                                    'Question',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff70c484),
                                    ),
                                  ),
                                  subtitle: CupertinoContextMenu(
                                    actions: <Widget>[
                                      CupertinoContextMenuAction(
                                        child: const Text('Copy'),
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: message.userInput));
                                          Fluttertoast.showToast(
                                              msg: 'Text copied to clipboard',
                                              textColor: Colors.white,
                                              backgroundColor:
                                                  const Color(0xff70c484));
                                        },
                                      ),
                                      CupertinoContextMenuAction(
                                        child: const Text('Share'),
                                        onPressed: () {
                                          Share.share(message.userInput);
                                        },
                                      ),
                                    ],
                                    child: InkWell(
                                      onTap: () {
                                        checkConnectivity().then((isConnected) {
                                          if (isConnected) {
                                            Navigator.pop(context);
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ResponseScreen(text: message.userInput, item: false,)));
                                          } else {
                                            DialogService.showCheckConnectivity(
                                                context);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 15,
                                            left: 15,
                                            right: 15,
                                            bottom: 5),
                                        margin: const EdgeInsets.only(top: 10),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(message.userInput),
                                      ),
                                    ),
                                  ),
                                ),
                                ListTile(
                                  title: const Text(
                                    'Ans',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff70c484),
                                    ),
                                  ),
                                  subtitle: CupertinoContextMenu(
                                    actions: <Widget>[
                                      CupertinoContextMenuAction(
                                        child: const Text('Copy'),
                                        onPressed: () async {
                                          await Clipboard.setData(ClipboardData(
                                              text: message.apiResponse));
                                          Fluttertoast.showToast(
                                              msg: 'Text copied to clipboard',
                                              textColor: Colors.white,
                                              backgroundColor:
                                                  const Color(0xff70c484));
                                        },
                                      ),
                                      CupertinoContextMenuAction(
                                        child: const Text('Share'),
                                        onPressed: () {
                                          Share.share(message.apiResponse);
                                        },
                                      ),
                                    ],
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 15,
                                          left: 15,
                                          right: 15,
                                          bottom: 5),
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(
                                        message.apiResponse,
                                        maxLines: 5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              }
            },
          ),
        );
      },
    );
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  void showPopupMenu(BuildContext context, String text) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset =
        renderBox.localToGlobal(Offset(renderBox.size.width, 0));

    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + 10,
      offset.dx + renderBox.size.width,
      offset.dy + renderBox.size.height + 10,
    );
    showMenu(
      context: context,
      position: position,
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text('Copy'),
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: text));
            Fluttertoast.showToast(
                msg: 'Text copied to clipboard',
                textColor: Colors.white,
                backgroundColor: const Color(0xff70c484));
          },
        ),
        PopupMenuItem(
          child: const Text('Share'),
          onTap: () {
            Share.share(text);
          },
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Future<void> imageCropper(XFile pickedFile) async {
    final sourcePath = pickedFile.path;

    var cropper = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio7x5,
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: const Color(0xff70c484),
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            cropFrameColor: Colors.white,
            cropGridColor: const Color(0xff70c484),
            showCropGrid: false,
            activeControlsWidgetColor: const Color(0xff70c484),
            hideBottomControls: false),
        IOSUiSettings(
          title: 'Crop',
          // Title of the cropping screen
          // aspectRatioLockDimensionSwapEnabled: false, // Whether to allow aspect ratio swap
          // aspectRatioLockEnabled: false, // Whether to lock aspect ratio
          // aspectRatioPickerButtonHidden: false, // Whether to hide the aspect ratio picker button
          // cancelButtonTitle: 'Cancel', // Text for the cancel button
          // doneButtonTitle: 'Done', // Text for the done button
          // hidesNavigationBar: false, // Whether to hide the navigation bar
          // minimumAspectRatio: 1.0, // Minimum allowed aspect ratio
          // rectHeight: 200, // Initial height of the cropping rectangle
          // rectWidth: 300, // Initial width of the cropping rectangle
          // rectX: 0, // Initial X coordinate of the cropping rectangle
          // rectY: 0, // Initial Y coordinate of the cropping rectangle
          // resetAspectRatioEnabled: false, // Whether to allow resetting the aspect ratio
          // resetButtonHidden: false, // Whether to hide the reset button
          // rotateButtonsHidden: false, // Whether to hide the rotate buttons
          // rotateClockwiseButtonHidden: false, // Whether to hide the rotate clockwise button
          // showActivitySheetOnDone: true, // Whether to show the activity sheet on done
          // showCancelConfirmationDialog: true, // Whether to show a confirmation dialog when canceling
        )
      ],
    );
    if (cropper != null) {
      _pickImageAndExtractText(cropper);
    }
  }

  Future<void> _pickImageAndExtractText(CroppedFile pickedFile) async {
    final appDir = await getTemporaryDirectory();
    final tempFile = File('${appDir.path}/temp_image.jpg');
    await tempFile.writeAsBytes(await pickedFile.readAsBytes());
    setState(() {
      showLoading = true;
    });
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(tempFile);
    //final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        showLoading = false;
      });
      if (recognizedText.text.isEmpty) {
        checkConnectivity().then((isConnected) {
          if (isConnected) {
            Fluttertoast.showToast(
                msg: 'No one text detect in image so please try again',
                textColor: Colors.white,
                backgroundColor: const Color(0xff70c484));
          } else {
            DialogService.showCheckConnectivity(context);
          }
        });
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ResponseScreen(text: recognizedText.text, item: true,)));
      }
      //final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      /*setState(() {
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            for (TextElement element in line.elements) {
              _extractedText += (' ${element.text}');
            }
          }
          _extractedText += ",";
        }
        //Fluttertoast.showToast(msg: _extractedText);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResponseScreen(text: _extractedText)),
        );
      });*/
    } catch (e) {
      Fluttertoast.showToast(
          msg: '$e',
          textColor: Colors.white,
          backgroundColor: const Color(0xff70c484));
    } finally {
      textRecognizer.close();
    }
  }
}
