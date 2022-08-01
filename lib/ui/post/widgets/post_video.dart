import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

enum Page {
  main,
  post,
}

class PostVideo extends StatefulWidget {
  PostVideo({
    Key? key,
    required this.post,
    required this.index,
    required this.play,
    this.main,
  }) : super(key: key);

  GetPost post;
  bool play;
  bool? main;
  int index;

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  VideoPlayerController? _controller;
  final _streamController = StreamController<bool>();
  int _videoIndex = 0;
  @override
  void initState() {
    print('im am video');
    _setController();
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  void _setController() {
    print(mediaUrl + widget.post.mediaUrl[widget.index].media);
    _controller = VideoPlayerController.network(
      mediaUrl + widget.post.mediaUrl[widget.index].media,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..initialize().then((_) {
        Timer(Duration(seconds: 5), () {
          _streamController.sink.add(false);
        });
        _controller!.play();
        _controller!.setVolume(0);
        setState(() {});
      }).catchError((error) => print(error));

    print(widget.play);

    if (widget.play) {
      _controller?.play();
      _controller?.setLooping(true);
    }

    _controller!.addListener(() {
      // if (!_controller!.value.isPlaying && widget.play) {
      //   Timer(const Duration(milliseconds: 200), () {
      //     _controller?.play();
      //   });
      // } else {
      if (widget.main != false) {
        if (Provider.of<AppData>(context, listen: false).isOpenStories) {
          // if (_controller!.value.isPlaying) {
          _controller?.pause();
          // }
        }
      }
    });
  }

  @override
  void didUpdateWidget(PostVideo oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _streamController.sink.add(true);
        Timer(Duration(seconds: 5), () {
          _streamController.sink.add(false);
        });

        _controller?.play();
        _controller?.setLooping(true);
      } else {
        _streamController.sink.add(false);
        _controller?.pause();
        setState(() {});
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _postVideo(
      widget.post.mediaUrl[widget.index].media,
      context,
    );
  }

  Widget _postVideo(String image, BuildContext context) {
    if (_controller != null) {
      return StreamBuilder<bool>(
          initialData: true,
          stream: _streamController.stream,
          builder: (context, snapshot) {
            return Container(
              color: Colors.grey[100],
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  const Center(child: CircularProgressIndicator.adaptive()),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (_controller!.value.volume > 0) {
                          _controller!.setVolume(0);
                        } else {
                          _controller!.setVolume(1.0);
                        }
                        setState(() {});
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width,
                        child: FittedBox(
                          clipBehavior: Clip.antiAlias,
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller!.value.size.width,
                            height: _controller!.value.size.height,
                            child: VideoPlayer(_controller!),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_controller!.value.isInitialized && snapshot.data == true)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ValueListenableBuilder(
                          valueListenable: _controller!,
                          builder: (context, VideoPlayerValue value, child) {
                            //Do Something with the value.
                            return Container(
                              width: 35,
                              height: 15,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 5,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getTime(value),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        if (_controller!.value.volume > 0) {
                          _controller!.setVolume(0);
                        } else {
                          _controller!.setVolume(1.0);
                        }
                        setState(() {});
                        print(_controller?.value.volume);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 15),
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _controller?.value.volume == 0
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          });
    } else {
      return Container();
    }
  }

  String _getTime(VideoPlayerValue value) {
    var time = (value.duration.inSeconds - value.position.inSeconds).toString();
    print(time);
    if (time.length > 1) {
      return '0:' + time;
    } else {
      if (time != '0') {
        return '0:0' + time;
      } else {
        return '0:00';
      }
    }
  }
}
