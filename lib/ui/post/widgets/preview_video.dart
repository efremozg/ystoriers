import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class PreviewVideo extends StatefulWidget {
  PreviewVideo({
    Key? key,
    this.video,
    this.xFile,
    this.main,
  }) : super(key: key);

  AssetEntity? video;
  XFile? xFile;
  bool? main;

  @override
  State<PreviewVideo> createState() => _PreviewVideoState();
}

class _PreviewVideoState extends State<PreviewVideo> {
  VideoPlayerController? _controller;
  int _videoIndex = 0;
  @override
  void initState() {
    _setController();

    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _setController() async {
    if (widget.video != null) {
      var file = await widget.video?.file;
      _controller = VideoPlayerController.file(File(file!.path))
        ..initialize().then((_) {
          // if (_controller!.value.duration.inSeconds > 15) {
          //   Timer.periodic(Duration(seconds: 15), (timer) {
          //     setState(() {
          //       _controller?.setLooping(true);
          //     });
          //   });
          // }
          _controller?.setLooping(true);
          // Timer.periodic(Duration(seconds: 15), (timer) { })
          _controller!.play();
          _controller!.setVolume(1);
          setState(() {});
        });
      _controller!.setLooping(true);
      _controller!.seekTo(const Duration(seconds: 0));
    } else if (widget.xFile != null) {
      _controller = VideoPlayerController.file(File(widget.xFile!.path))
        ..initialize().then((_) {
          _controller!.play();
          _controller!.setVolume(1);
          setState(() {});
        });
    }

    _controller?.addListener(
      () {
        if (!_controller!.value.isPlaying) {
          Timer(const Duration(milliseconds: 200), () {
            _controller?.play();
          });
        }
      },
    );
    // _controller!.addListener(() {
    //   if (!_controller!.value.isPlaying) {
    //     Timer(const Duration(milliseconds: 200), () {
    //       _controller?.play();
    //     });
    //   } else {
    //     // if (Provider.of<AppData>(context, listen: false).isOpenStories) {
    //     // if (_controller!.value.isPlaying) {
    //     // _controller?.pause();
    //     // }
    //     // }
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return _postVideo(
      context,
    );
  }

  Widget _postVideo(BuildContext context) {
    if (_controller != null) {
      return Container(
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
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
