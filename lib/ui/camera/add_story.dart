import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/stories_request.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/main/control/main_control.dart';
import 'package:y_storiers/ui/post/widgets/preview_video.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

enum PictureType {
  front,
  back,
}

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({
    Key? key,
    required this.photo,
    required this.pictureType,
    required this.mediaType,
  }) : super(key: key);

  final XFile photo;
  final PictureType pictureType;
  final MediaType mediaType;

  @override
  State<AddStoryPage> createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  @override
  void initState() {
    _checkPermission();
    super.initState();
  }

  Future<void> _checkPermission() async {
    final serviceStatus = await Permission.photos.status;
    final isGpsOn = serviceStatus == ServiceStatus.enabled;
    if (!isGpsOn) {
      return;
    }
    final status = await Permission.photos.request();
    if (status == PermissionStatus.granted) {
    } else if (status == PermissionStatus.denied) {
    } else if (status == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
  }

  void _addStories() async {
    if (BlocProvider.of<UserBloc>(context).state is StoryAddeting) {
      StandartSnackBar.show(
        context,
        'Подождите, пока загрузиться предыдущая история',
        SnackBarStatus.loading(),
      );
      return;
    }
    var user = Provider.of<AppData>(context, listen: false).user;
    var media = '';
    File? lastFile;
    var mime = lookupMimeType(widget.photo.path);
    if (mime == 'image/png' || mime == 'image/jpg' || mime == 'image/jpeg') {
      lastFile = await compressFile(File(widget.photo.path));
    } else {
      var mediaInfo = await VideoCompress.compressVideo(
        widget.photo.path,
        duration: 15,
        quality: VideoQuality.Res1280x720Quality,
        deleteOrigin: true,
      );

      lastFile = mediaInfo?.file;
    }
    if (mime == 'video/quicktime') {
      mime = 'video/MP4';
    }
    var bytes = lastFile?.readAsBytesSync();
    media = "data:$mime;base64," + base64Encode(bytes!);
    BlocProvider.of<UserBloc>(context).add(
      AddStory(
        mediaType: widget.mediaType,
        token: user.userToken,
        context: context,
        media: media,
      ),
    );
    // var result = await Repository().addStory(
    //   StroiesRequest(
    //     media: media,
    //     reversed: false,
    //     mediaType: widget.mediaType == MediaType.image ? 'image' : 'video',
    //   ),
    //   user.userToken,
    // );

    // if (result != null) {
    //   if (result.success) {
    //     BlocProvider.of<UserBloc>(context).add(Loading(loading: false));
    //     BlocProvider.of<UserBloc>(context).add(
    //       GetInfo(
    //         nickname: user.nickName,
    //         token: user.userToken,
    //       ),
    //     );
    //     Navigator.pushAndRemoveUntil(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => MainPageControl(),
    //         ),
    //         (route) => false);
    //   }
    // } else {
    //   BlocProvider.of<UserBloc>(context).add(Loading(loading: false));
    // }
  }

  Future<File?> compressFile(File file) async {
    final filePath = file.absolute.path;

    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 10,
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, snapshot) {
      // var loading = BlocProvider.of<UserBloc>(context).networkLoading;
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            SafeArea(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[900],
                    ),
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.mediaType == MediaType.image
                          ? widget.pictureType == PictureType.front
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(pi),
                                  child: Image.file(
                                    File(widget.photo.path),
                                    fit: BoxFit.fitWidth,
                                  ),
                                )
                              : Image.file(
                                  File(widget.photo.path),
                                  fit: BoxFit.fitWidth,
                                )
                          : PreviewVideo(xFile: widget.photo),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 45,
                        width: 45,
                        padding: const EdgeInsets.only(right: 3),
                        margin: const EdgeInsets.only(left: 10, top: 10),
                        decoration: BoxDecoration(
                          color: greyStoriesColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _bottomButtons(),
                  // if (snapshot is StoryAddeting)
                  //   Align(
                  //     alignment: Alignment.bottomLeft,
                  //     child: Padding(
                  //       padding: EdgeInsets.only(left: 15, bottom: 5),
                  //       child: CircularProgressIndicator.adaptive(),
                  //     ),
                  //   )
                ],
              ),
            ),
            // if (loading)
            // Container(
            //   width: MediaQuery.of(context).size.width,
            //   height: MediaQuery.of(context).size.height,
            //   color: Colors.white.withOpacity(0.3),
            //   child: Center(
            //     child: Container(
            //       width: 50,
            //       height: 50,
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         boxShadow: [
            //           BoxShadow(color: Colors.grey[400]!, blurRadius: 5)
            //         ],
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //       child: const Center(
            //         child: CircularProgressIndicator.adaptive(
            //           backgroundColor: Colors.black,
            //           value: 20,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  Widget _bottomButtons() {
    var userInfo = BlocProvider.of<UserBloc>(context).userInfo;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 5),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // GestureDetector(
            //   onTap: () {
            //     _addStories();
            //   },
            //   child: Container(
            //     height: 40,
            //     width: 150,
            //     padding: const EdgeInsets.all(7),
            //     margin: const EdgeInsets.only(left: 17),
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(20),
            //       color: greyStoriesColor,
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Container(
            //           decoration: BoxDecoration(
            //             border: Border.all(width: 1, color: Colors.white),
            //             shape: BoxShape.circle,
            //           ),
            //           child: userInfo != null
            //               ? userInfo.photo != null
            //                   ? ClipRRect(
            //                       borderRadius: BorderRadius.circular(30),
            //                       child: Image.network(
            //                         mediaUrl + userInfo.photo!,
            //                         height: 21,
            //                         width: 21,
            //                         fit: BoxFit.cover,
            //                       ),
            //                     )
            //                   : Image.asset(
            //                       'assets/user.png',
            //                       height: 21,
            //                       width: 21,
            //                     )
            //               : Image.asset(
            //                   'assets/user.png',
            //                   height: 21,
            //                   width: 21,
            //                 ),
            //         ),
            //         const Padding(
            //           padding: EdgeInsets.only(right: 5),
            //           child: Text(
            //             'Ваша история',
            //             style: TextStyle(color: Colors.white, fontSize: 14),
            //           ),
            //         )
            //       ],
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                _addStories();
                // Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(builder: (context) => MainPageControl()),
                //     (route) => false);
              },
              child: Container(
                height: 45,
                width: 45,
                margin: const EdgeInsets.only(right: 17),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_right_alt_outlined,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
