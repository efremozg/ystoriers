import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/posts.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/image_item_widget.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/post/widgets/preview_video.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

enum PhotoType {
  account,
  publication,
  stories,
}

class AddPostPage extends StatefulWidget {
  final PhotoType photoType;
  final Function()? returnToMain;
  const AddPostPage({
    Key? key,
    required this.photoType,
    this.returnToMain,
  }) : super(key: key);

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final FilterOptionGroup _filterOptionGroup = FilterOptionGroup(
    imageOption: const FilterOption(
      sizeConstraint: SizeConstraint(ignoreSize: true),
    ),
  );
  CachedVideoPlayerController? _controller;
  final int _sizePerPage = 50;

  final _streamController = StreamController<int>();

  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  List<AssetEntity> _choosenEntities = [];
  int _totalEntitiesCount = 0;
  int _imageIndex = 0;

  int _page = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreToLoad = true;

  void _addPosts() async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    List<Media> _media = [];
    // BlocProvider.of<UserBloc>(context).add(Loading(loading: true));

    for (var element in _choosenEntities) {
      // var mime = await element.mimeTypeAsync;
      // if (mime == 'image/heic')
      var file = await element.file;
      File? lastFile;
      var mime = lookupMimeType(file!.path);
      if (mime == 'image/png' || mime == 'image/jpg' || mime == 'image/jpeg') {
        lastFile = await compressFile(file);
      } else {
        var mediaInfo = await VideoCompress.compressVideo(
          file.path,
          quality: VideoQuality.HighestQuality,
          duration: element.videoDuration.inSeconds > 60
              ? 60
              : element.videoDuration.inSeconds,
          deleteOrigin: false,
        );

        lastFile = mediaInfo!.file;
      }

      // if (mime == 'video/quicktime') {
      //   mime = 'video/MP4';
      // }
      // print(mime);
      var bytes = lastFile?.readAsBytesSync();
      _media.add(
        Media(
          media:
              "data:${mime == 'video/quicktime' ? 'video/mp4' : mime};base64," +
                  base64Encode(bytes!),
          mediaType: element.type == AssetType.image ? 'image' : 'video',
        ),
      );
    }
    BlocProvider.of<UserBloc>(context).add(
      AddPost(
        media: _media,
        token: token,
        context: context,
        photoType: widget.photoType,
        onSuccess: widget.returnToMain,
      ),
    );
    // var result = await Repository().addPosts(
    //   PostRequest(media: _media, description: ''),
    //   token,
    // );

    // if (result != null) {
    //   if (result.postCreated) {
    //     if (widget.photoType != PhotoType.stories) {
    //       // BlocProvider.of<UserBloc>(context).add(Loading(loading: false));
    //       Navigator.pop(context, result.post);
    //     } else {
    //       // BlocProvider.of<UserBloc>(context).add(Loading(loading: false));
    //       widget.returnToMain!();
    //     }
    //   }
    // } else {
    //   // BlocProvider.of<UserBloc>(context).add(Loading(loading: true));
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
      quality: 14,
    );

    return result;
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

  Future<void> _requestAssets() async {
    setState(() {
      _isLoading = true;
    });
    // Request permissions.
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!mounted) {
      return;
    }
    // Further requests can be only procceed with authorized or limited.
    if (ps != PermissionState.authorized && ps != PermissionState.limited) {
      setState(() {
        _isLoading = false;
      });
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
      setState(() {
        _isLoading = false;
      });
      // showToast('No paths found.');
      return;
    }
    setState(() {
      _path = paths.first;
    });
    _totalEntitiesCount = _path!.assetCount;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      if (widget.photoType == PhotoType.account) {
        _entities = entities
            .where((element) =>
                element.type != AssetType.video &&
                element.type != AssetType.audio)
            .toList();
      } else {
        _entities = entities;
      }
      _isLoading = false;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
    });
  }

  Future<void> _loadMoreAsset() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      if (widget.photoType == PhotoType.account) {
        _entities!.addAll(entities
            .where(
              (element) => element.type == AssetType.image,
            )
            .toList());
      } else {
        _entities!.addAll(entities);
      }
      _page++;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _isLoadingMore = false;
    });
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_path == null) {
      return const Center(child: Text('Request paths first.'));
    }
    if (_entities?.isNotEmpty != true) {
      return const Center(child: Text('No assets found on this device.'));
    }
    return GridView.custom(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == _entities!.length - 8 &&
              !_isLoadingMore &&
              _hasMoreToLoad) {
            _loadMoreAsset();
          }
          final AssetEntity entity = _entities![index];
          return ScaleButton(
            duration: const Duration(milliseconds: 150),
            bound: 0.04,
            child: Stack(
              children: [
                if (widget.photoType != PhotoType.account)
                  ImageItemWidget(
                    key: ValueKey<int>(index),
                    entity: entity,
                    selected: _choosenEntities.contains(entity),
                    index: _choosenEntities.contains(entity)
                        ? _choosenEntities
                                .indexWhere((element) => element == entity) +
                            1
                        : null,
                    onTap: () {
                      if (!_choosenEntities.contains(entity)) {
                        if (_choosenEntities.length < 11) {
                          if (_choosenEntities.isNotEmpty) {
                            if (_choosenEntities.last == entity) {
                              _choosenEntities.remove(entity);
                            }
                          }
                          if (_choosenEntities.isNotEmpty) {
                            if (_choosenEntities.last != entity) {
                              _choosenEntities.add(entity);
                            }
                          } else {
                            _choosenEntities.add(entity);
                          }
                          setState(() {});
                        }
                      } else {
                        _choosenEntities.remove(entity);
                        setState(() {});
                      }
                      _controller?.dispose();
                      if (entity.type == AssetType.video) {
                        _setController(index);
                      }
                      _streamController.sink.add(index);
                      _imageIndex = index;
                    },
                    option: const ThumbnailOption(
                      size: ThumbnailSize.square(200),
                    ),
                  ),
                if (widget.photoType == PhotoType.account)
                  ImageItemWidget(
                    key: ValueKey<int>(index),
                    entity: entity,
                    onTap: () {
                      _streamController.sink.add(index);
                      _imageIndex = index;
                      setState(() {});
                    },
                    option: const ThumbnailOption(
                      size: ThumbnailSize.square(200),
                    ),
                  ),
                if (_choosenEntities.isNotEmpty)
                  if (_entities![_imageIndex] == entity)
                    GestureDetector(
                      onTap: () {
                        if (!_choosenEntities.contains(entity)) {
                          if (_choosenEntities.length < 11) {
                            if (_choosenEntities.isNotEmpty) {
                              if (_choosenEntities.last == entity) {
                                _choosenEntities.remove(entity);
                              }
                            }
                            if (_choosenEntities.isNotEmpty) {
                              if (_choosenEntities.last != entity) {
                                _choosenEntities.add(entity);
                              }
                            } else {
                              _choosenEntities.add(entity);
                            }
                            setState(() {});
                          }
                        } else {
                          _choosenEntities.remove(entity);
                          setState(() {});
                        }
                        _controller?.dispose();
                        if (entity.type == AssetType.video) {
                          _setController(index);
                        }
                        _streamController.sink.add(index);
                        _imageIndex = index;
                      },
                      child: Container(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                if (_entities?[index].type == AssetType.video)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _getTime(_entities?[index].videoDuration),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        childCount: _entities!.length,
        findChildIndexCallback: (Key key) {
          if (key is ValueKey<int>) {
            return key.value;
          }
          return null;
        },
      ),
    );
  }

  String _getTime(Duration? duration) {
    print(duration!.inSeconds - duration.inHours * 60);
    if (duration != null) {
      if (duration.inMinutes > 0) {
        return '${duration.inMinutes}:${duration.inSeconds - duration.inMinutes * 60}';
      } else {
        return '0:${duration.inSeconds}';
      }
    } else {
      return '';
    }
  }

  @override
  void initState() {
    _requestAssets();
    _checkPermission();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, snapshot) {
      // var loading = BlocProvider.of<UserBloc>(context).networkLoading;
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _anotherAppBar(),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: _entities != null
                      ? StreamBuilder<int>(
                          stream: _streamController.stream,
                          initialData: 0,
                          builder: (context, snapshot) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width,
                              child: _entities![snapshot.data!].type ==
                                      AssetType.image
                                  ? ImageItemWidget(
                                      entity: _entities![snapshot.data!],
                                      option: const ThumbnailOption(
                                        size: ThumbnailSize.square(1500),
                                      ),
                                    )
                                  : _postVideo(context, snapshot.data!),
                            );
                          },
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width,
                        ),
                ),
                const SizedBox(height: 1),
                Expanded(flex: 1, child: _buildBody(context)),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _setController(int index) async {
    if (_entities![index] != null) {
      var file = await _entities![index].file;
      _controller = CachedVideoPlayerController.file(File(file!.path))
        ..initialize().then((_) {
          // if (_controller!.value.duration.inSeconds > 15) {
          //   Timer.periodic(Duration(seconds: 15), (timer) {
          //     setState(() {
          //       _controller?.setLooping(true);
          //     });
          //   });
          // }
          print('inited');
          // _controller?.setLooping(true);
          // Timer.periodic(Duration(seconds: 15), (timer) { })
          _controller!.play();
          _controller!.setVolume(1);
          setState(() {});
        });
      _controller!.setLooping(true);
      _controller!.seekTo(const Duration(seconds: 0));
    }
    // else if (widget.xFile != null) {
    //   _controller = VideoPlayerController.file(File(widget.xFile!.path))
    //     ..initialize().then((_) {
    //       _controller!.play();
    //       _controller!.setVolume(1);
    //       setState(() {});
    //     });
    // }

    _controller?.addListener(
      () {
        if (!_controller!.value.isPlaying) {
          Timer(const Duration(milliseconds: 200), () {
            _controller?.play();
          });
        }
      },
    );
  }

  Widget _postVideo(BuildContext context, int index) {
    if (_controller != null) {
      return Container(
        color: Colors.black,
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: Stack(
          children: [
            const Center(child: CircularProgressIndicator.adaptive()),
            Center(
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: FittedBox(
                  clipBehavior: Clip.antiAlias,
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: CachedVideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.black,
      );
    }
  }

  AppBar _anotherAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      flexibleSpace: Container(
        color: Colors.black,
        width: double.infinity,
        height: 110,
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.photoType == PhotoType.stories) {
                            widget.returnToMain!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      widget.photoType != PhotoType.account
                          ? 'Новая публикация'
                          : 'Выберите фотографию',
                      style: TextStyle(
                          fontFamily: 'SF UI',
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () async {
                        if (widget.photoType == PhotoType.account) {
                          var file = await _entities![_imageIndex].file;
                          var compressedFile = compressFile(file!);
                          Navigator.pop(context, compressedFile);
                        } else {
                          if (_choosenEntities.isNotEmpty) {
                            _addPosts();
                          } else {
                            StandartSnackBar.show(
                              context,
                              'Выберите фото',
                              SnackBarStatus.warning(),
                            );
                          }
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Text(
                          'Далее',
                          style: TextStyle(
                            color: Color.fromRGBO(80, 58, 212, 1),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // SizedBox(
    //   width: 100,
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.end,
    //     children: [
    //       SvgPicture.asset(
    //         'assets/add.svg',
    //         width: 27,
    //         height: 27,
    //       ),
    //       GestureDetector(
    //         onTap: () {},
    //         child: Container(
    //           width: 14,
    //           height: 3,
    //           margin: const EdgeInsets.only(left: 20, right: 5),
    //           child: SvgPicture.asset(
    //             'assets/more.svg',
    //             width: 25,
    //             height: 25,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
  }
}
