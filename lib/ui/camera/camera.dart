import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neon_circular_timer/neon_circular_timer.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/main.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/posts.dart';
import 'package:y_storiers/ui/add_post/image_item_widget.dart';
import 'package:y_storiers/ui/camera/add_story.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    Key? key,
    required this.closeChat,
    required this.openPicker,
    required this.openAddPhoto,
  }) : super(key: key);

  final Function() closeChat;
  final Function() openPicker;
  final Function() openAddPhoto;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  final _streamController = StreamController<bool>();
  var cameraIndex = 0;
  var _recording = false;
  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  int _totalEntitiesCount = 0;
  int _imageIndex = 0;
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );

  @override
  void initState() {
    super.initState();
    _requestAssets();
    _setCamera(0);
  }

  void _setCamera(int index) async {
    controller = CameraController(
      cameras[index],
      ResolutionPreset.ultraHigh,
    );
    controller?.prepareForVideoRecording();
    controller?.initialize().then((_) {
      controller!.lockCaptureOrientation();
      if (!mounted) {
        return;
      }
      cameraIndex = cameraIndex == 0 ? 1 : 0;
      setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      // setState(() {
      //    _isCameraInitialized = controller!.value.isInitialized;
      // });
    }
  }

  @override
  void dispose() {
    print('dispose');
    _streamController.close();
    controller?.dispose();
    super.dispose();
  }

  Future<void> _requestAssets() async {
    // Request permissions.
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    // Further requests can be only procceed with authorized or limited.
    if (ps != PermissionState.authorized && ps != PermissionState.limited) {
      // showToast('Permission is not granted.');
      return;
    }
    // Obtain assets using the path entity.
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: _filterOptionGroup,
    );

    if (!mounted) {
      return;
    }
    // Return if not paths found.
    if (paths.isEmpty) {
      // showToast('No paths found.');
      return;
    }
    if (_path == null) {
      setState(() {
        _path = paths.first;
      });
    }
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: 1,
    );
    if (!mounted) {
      return;
    }
    if (_entities == null) {
      setState(() {
        _entities = entities;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      if (!controller!.value.isInitialized) {
        return Container(
          color: Colors.black,
        );
      }
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: StreamBuilder<bool>(
            initialData: false,
            stream: _streamController.stream,
            builder: (context, snapshot) {
              return Stack(
                children: [
                  if (controller != null) _camera(snapshot),
                  if (!snapshot.data!) _closeButton(),
                  if (!snapshot.data!) _bottomButtons(),
                ],
              );
            }),
      ),
    );
  }

  Widget _camera(AsyncSnapshot<bool> snapshot) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 40),
      alignment: Alignment.topCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          onDoubleTap: () {
            // setState(() {
            // cameraIndex = cameraIndex == 0 ? 1 : 0;
            _setCamera(cameraIndex);
            // });
          },
          child: CameraPreview(
            controller!,
            child: _pickButton(snapshot),
          ),
        ),
      ),
    );
  }

  Widget _bottomButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                widget.openPicker();
              },
              child: Container(
                height: 30,
                width: 30,
                margin: const EdgeInsets.only(left: 17),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _entities != null
                    ? ImageItemWidget(
                        entity: _entities![0],
                        option: const ThumbnailOption(
                          size: ThumbnailSize.square(1500),
                        ),
                      )
                    : null,
              ),
            ),
            GestureDetector(
              onTap: () {
                widget.openAddPhoto();
              },
              child: const Text(
                'Публикация',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            const Text(
              'История',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                // setState(() {
                _setCamera(cameraIndex);
                // });
              },
              child: Container(
                height: 50,
                width: 50,
                margin: const EdgeInsets.only(right: 17),
                decoration: BoxDecoration(
                  color: greyStoriesColor,
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/left_array.svg',
                      width: 22,
                      height: 9.23,
                    ),
                    const SizedBox(height: 7),
                    SvgPicture.asset(
                      'assets/right_array.svg',
                      width: 23,
                      height: 8.52,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _closeButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () {
          widget.closeChat();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 17, top: 23),
          child: const Icon(
            Icons.close,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _pickButton(AsyncSnapshot<bool> snapshot) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedContainer(
        width: snapshot.data! ? 120 : 85,
        height: snapshot.data! ? 120 : 85,
        margin: EdgeInsets.only(bottom: !snapshot.data! ? 25 : 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        duration: const Duration(milliseconds: 150),
        child: Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () async {
                  var picture = await controller?.takePicture();
                  Timer(const Duration(milliseconds: 500), () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStoryPage(
                          photo: picture!,
                          pictureType: cameraIndex == 1
                              ? PictureType.back
                              : PictureType.front,
                          mediaType: MediaType.image,
                        ),
                      ),
                    );
                  });
                },
                onLongPressMoveUpdate: (details) {
                  if (details.localOffsetFromOrigin.distance > 100) {
                    controller?.setZoomLevel(
                      details.localOffsetFromOrigin.distance / 100,
                    );
                  }
                },
                onLongPress: () async {
                  if (!controller!.value.isRecordingVideo) {
                    _streamController.sink.add(true);
                    await controller?.startVideoRecording();

                    Timer(const Duration(seconds: 15), () async {
                      if (controller!.value.isRecordingVideo) {
                        _streamController.sink.add(false);
                        XFile? videoFile =
                            await controller?.stopVideoRecording();
                        controller?.dispose();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddStoryPage(
                              photo: videoFile!,
                              pictureType: cameraIndex == 0
                                  ? PictureType.front
                                  : PictureType.back,
                              mediaType: MediaType.video,
                            ),
                          ),
                        ).then((value) {
                          _setCamera(0);
                        });
                      }
                    });
                  }
                },
                onLongPressUp: () async {
                  // setState(() {
                  _streamController.sink.add(false);
                  // });
                  XFile? videoFile = await controller?.stopVideoRecording();
                  controller?.pausePreview();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddStoryPage(
                        photo: videoFile!,
                        pictureType: cameraIndex == 0
                            ? PictureType.front
                            : PictureType.back,
                        mediaType: MediaType.video,
                      ),
                    ),
                  ).then((value) => controller?.buildPreview());
                },
                child: Container(
                  height: 78,
                  width: 78,
                  margin: EdgeInsets.all(!snapshot.data! ? 2 : 30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(!snapshot.data! ? 2 : 0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (snapshot.data!)
                NeonCircularTimer(
                  width: 115,
                  backgroudColor: Colors.white.withOpacity(0),
                  innerFillColor: Colors.white.withOpacity(0),
                  outerStrokeColor: Colors.white.withOpacity(0),
                  neonColor: Colors.white.withOpacity(0),
                  duration: 15,
                  controller: null,
                  isTimerTextShown: false,
                  neumorphicEffect: false,
                  strokeWidth: 6,
                  innerFillGradient: LinearGradient(colors: [
                    Color.fromRGBO(253, 29, 29, 1),
                    Color.fromRGBO(247, 119, 55, 1),
                  ]),
                  neonGradient: LinearGradient(colors: [
                    Color.fromRGBO(247, 119, 55, 1),
                    Color.fromRGBO(253, 29, 29, 1),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _pickButton(CameraController? controller, int cameraIndex,
  //     AsyncSnapshot<bool> snapshot) {
  //   print(snapshot.data!);
  //   return Align(
  //     alignment: Alignment.bottomCenter,
  //     child: AnimatedContainer(
  //       width: snapshot.data! ? 120 : 85,
  //       height: snapshot.data! ? 120 : 85,
  //       margin: EdgeInsets.only(bottom: !snapshot.data! ? 25 : 9),
  //       decoration: BoxDecoration(
  //         color: Colors.white.withOpacity(0.4),
  //         shape: BoxShape.circle,
  //       ),
  //       duration: const Duration(milliseconds: 150),
  //       child: Center(
  //         child: Stack(
  //           children: [
  //             GestureDetector(
  //               onTap: () async {
  //                 var picture = await controller!.takePicture();
  //                 Timer(const Duration(seconds: 1), () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (context) => AddStoryPage(
  //                         photo: picture,
  //                         pictureType: cameraIndex == 1
  //                             ? PictureType.back
  //                             : PictureType.front,
  //                         mediaType: MediaType.image,
  //                       ),
  //                     ),
  //                   );
  //                 });
  //               },
  //               onLongPressMoveUpdate: (details) {
  //                 if (details.localOffsetFromOrigin.distance > 100) {
  //                   controller?.setZoomLevel(
  //                     details.localOffsetFromOrigin.distance / 100,
  //                   );
  //                 }
  //               },
  //               onLongPress: () async {
  //                 if (!controller!.value.isRecordingVideo) {
  //                   _streamController.sink.add(true);
  //                   BlocProvider.of<CameraBloc>(context).add(RecordVideo());
  //                   // Future.delayed(const Duration(milliseconds: 500), () async {
  //                   // });
  //                   // await controller.startVideoRecording();

  //                   // Timer(const Duration(seconds: 15), () async {
  //                   //   if (controller.value.isRecordingVideo) {
  //                   //     _streamController.sink.add(false);
  //                   //     XFile? videoFile = await controller.stopVideoRecording();
  //                   //     Navigator.push(
  //                   //       context,
  //                   //       MaterialPageRoute(
  //                   //         builder: (context) => AddStoryPage(
  //                   //           photo: videoFile,
  //                   //           pictureType: cameraIndex == 0
  //                   //               ? PictureType.front
  //                   //               : PictureType.back,
  //                   //           mediaType: MediaType.video,
  //                   //         ),
  //                   //       ),
  //                   //     );
  //                   //   }
  //                   // });
  //                 }
  //               },
  //               onLongPressUp: () async {
  //                 // setState(() {
  //                 _streamController.sink.add(false);
  //                 // });
  //                 XFile? videoFile = await controller?.stopVideoRecording();
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => AddStoryPage(
  //                       photo: videoFile!,
  //                       pictureType: cameraIndex == 0
  //                           ? PictureType.front
  //                           : PictureType.back,
  //                       mediaType: MediaType.video,
  //                     ),
  //                   ),
  //                 );
  //               },
  //               child: Container(
  //                 height: 78,
  //                 width: 78,
  //                 margin: EdgeInsets.all(!snapshot.data! ? 2 : 30),
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   border: Border.all(
  //                     color: Colors.white,
  //                     width: 4,
  //                   ),
  //                 ),
  //                 child: Container(
  //                   margin: EdgeInsets.all(!snapshot.data! ? 2 : 0),
  //                   decoration: const BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             if (snapshot.data!)
  //               NeonCircularTimer(
  //                 width: 115,
  //                 backgroudColor: Colors.white.withOpacity(0),
  //                 innerFillColor: Colors.white.withOpacity(0),
  //                 outerStrokeColor: Colors.white.withOpacity(0),
  //                 neonColor: Colors.white.withOpacity(0),
  //                 duration: 15,
  //                 controller: null,
  //                 isTimerTextShown: false,
  //                 neumorphicEffect: false,
  //                 strokeWidth: 6,
  //                 innerFillGradient: LinearGradient(colors: [
  //                   Color.fromRGBO(253, 29, 29, 1),
  //                   Color.fromRGBO(247, 119, 55, 1),
  //                 ]),
  //                 neonGradient: LinearGradient(colors: [
  //                   Color.fromRGBO(247, 119, 55, 1),
  //                   Color.fromRGBO(253, 29, 29, 1),
  //                 ]),
  //               ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
