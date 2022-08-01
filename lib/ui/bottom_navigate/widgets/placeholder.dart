import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:cached_video_preview/cached_video_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/ui/post/post.dart';

class PlaceHolder extends StatefulWidget {
  PlaceHolder({
    Key? key,
    required this.postModel,
    required this.index,
    required this.onTap,
    required this.nickname,
  }) : super(key: key);

  final PostInfo postModel;
  final int index;
  final Function() onTap;
  final String nickname;

  @override
  State<PlaceHolder> createState() => _PlaceHolderState();
}

class _PlaceHolderState extends State<PlaceHolder> {
  String? image = '';
  CachedVideoPlayerController? _controller;

  @override
  void didChangeDependencies() {
    // if (_controller == null) {
    if (widget.postModel.mediaUrl.isNotEmpty) {
      if (widget.postModel.mediaUrl[0].mediaType == MediaType.video) {
        _setController();
      }
    }
    // }
    // print('123');

    super.didChangeDependencies();
  }

  @override
  void initState() {
    // if (_controller == null) {
    // if (widget.postModel.mediaUrl.isNotEmpty) {
    //   if (widget.postModel.mediaUrl[0].mediaType == 'video') {
    //     _setController();
    //   }
    // }
    // }
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _setController() {
    // _controller = CachedVideoPlayerController.network(
    //     mediaUrl + widget.postModel.mediaUrl[0].media);
    // _controller?.initialize();
    // _controller?.setVolume(0);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.05,
      onTap: widget.onTap,
      child: Stack(
        children: [
          widget.postModel.mediaUrl.isNotEmpty
              ? widget.postModel.mediaUrl[0].mediaType == MediaType.image
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey[200],
                      child: CachedNetworkImage(
                        imageUrl: mediaUrl + widget.postModel.mediaUrl[0].media,
                        fit: BoxFit.cover,
                        memCacheHeight: 400,
                        memCacheWidth: 400,
                        maxWidthDiskCache: 400,
                        maxHeightDiskCache: 400,
                      ),
                      // child: Image(
                      //   image: NetworkImageSSL(
                      //       mediaUrl + widget.postModel.mediaUrl[0].media,
                      //       headers: {}),
                      //   fit: BoxFit.cover,
                      //   errorBuilder: (context, error, stackTrace) => Container(
                      //     color: Colors.grey[200],
                      //   ),
                      // ),
                    )
                  : Stack(
                      children: [
                        Container(
                          color: Colors.grey[200],
                          width: double.infinity,
                          height: double.infinity,
                          child: FittedBox(
                            clipBehavior: Clip.antiAlias,
                            fit: BoxFit.cover,
                            child: CachedVideoPreviewWidget(
                              path:
                                  mediaUrl + widget.postModel.mediaUrl[0].media,
                              type: SourceType.remote,
                              placeHolder: SkeletonAnimation(
                                shimmerColor: Colors.grey[200]!,
                                child: Container(
                                  color: Colors.grey[200],
                                ),
                              ),
                              httpHeaders: const <String, String>{},
                              remoteImageBuilder: (BuildContext context, url) =>
                                  Container(
                                // decoration: BoxDecoration(
                                //   image: DecorationImage(
                                //     image: NetworkImage(
                                //       url,
                                //     ),
                                //   ),
                                // ),
                                width: 50,
                                height: 50,
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 50,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.postModel.mediaUrl.first.mediaType ==
                            MediaType.video)
                          _videoWidget()
                      ],
                    )
              : Container(
                  color: Colors.grey[200],
                ),
          if (widget.postModel.mediaUrl.length > 1) _lengthOfImages(),
        ],
      ),
    );
  }

  Widget _videoWidget() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        alignment: Alignment.center,
        width: 40,
        height: 25,
        child: Container(
          margin: const EdgeInsets.only(top: 3),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _lengthOfImages() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        alignment: Alignment.center,
        width: 40,
        height: 25,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 11, left: 5),
              child: SvgPicture.asset(
                'assets/post_length_two.svg',
                color: Colors.white,
                width: 14,
                height: 14,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(
                top: 7,
                right: 0,
              ),
              child: SvgPicture.asset(
                'assets/post_length.svg',
                color: Colors.white,
                width: 14,
                height: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
