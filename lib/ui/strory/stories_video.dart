import 'dart:async';
import 'dart:math';

import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:story_time/story_page_view/story_page_view.dart';
import 'package:video_player/video_player.dart';
import 'package:y_storiers/bloc/story/story_bloc.dart';
import 'package:y_storiers/bloc/story/story_event.dart';
import 'package:y_storiers/bloc/story/story_state.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class StoriesVideo extends StatefulWidget {
  StoriesVideo({
    Key? key,
    required this.url,
    required this.pause,
    required this.loaded,
    required this.duration,
    required this.indicatorAnimationController,
    this.main,
  }) : super(key: key);

  String url;
  Function() pause;
  Function(Duration) loaded;
  Function(Duration) duration;
  ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  bool? main;

  @override
  State<StoriesVideo> createState() => _StoriesVideoState();
}

class _StoriesVideoState extends State<StoriesVideo> {
  CachedVideoPlayerController? _controller;
  late var url;
  @override
  void initState() {
    widget.pause();
    _setController();
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _setController() async {
    print(mediaUrl + widget.url);
    widget.pause();

    // print('indicator: ' +
    //     widget.indicatorAnimationController.value.pause.toString());

    BlocProvider.of<StoryBloc>(context).add(LoadStory());
    // print(widget.url);
    _controller = CachedVideoPlayerController.network(mediaUrl + widget.url)
      ..initialize().then((_) {
        widget.pause();
        _controller!.play();
        _controller!.setVolume(1);
        widget.duration(_controller!.value.duration);
        setState(() {});
      }).onError((error, stackTrace) {
        print(error);
      });
    print('${_controller?.dataSource}');

    _controller?.addListener(() {
      if (mediaUrl + widget.url != _controller?.dataSource) {
        _controller?.dispose();
        _setController();
      }
    });
    _addListener();
  }

  void _addListener() {
    _controller?.addListener(() async {
      if (_controller != null) {
        if (_controller!.value.isPlaying &&
            _controller!.value.position.inMilliseconds != 0) {
          if (widget.indicatorAnimationController.value.pause == true) {
            widget.loaded(_controller!.value.duration);
            BlocProvider.of<StoryBloc>(context).add(LoadedStory(
              duration: _controller!.value.duration,
            ));
          }
        }
      } else {
        widget.pause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _postVideo(
      context,
    );
  }

  Widget _postVideo(BuildContext context) {
    if (_controller != null) {
      return BlocBuilder<StoryBloc, StoryState>(builder: (context, snapshot) {
        if (snapshot is StoryPaused) {
          _controller?.pause();
          print('pause');
        }
        if (snapshot is StoryResumed) {
          print('resume');
          _controller?.play();
        }
        return Container(
          color: Colors.grey[900],
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Center(
                  child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Colors.grey[800]!,
                  ),
                ),
              )),
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (_controller!.value.volume > 0) {
                      _controller!.setVolume(0);
                    } else {
                      _controller!.setVolume(1.0);
                    }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
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
              ),
            ],
          ),
        );
      });
    } else {
      return Container();
    }
  }
}
