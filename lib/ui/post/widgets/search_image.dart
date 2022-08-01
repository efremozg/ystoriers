import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_preview/cached_video_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:video_player/video_player.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/ui/post/post.dart';

class SearchImage extends StatefulWidget {
  SearchImage({
    Key? key,
    required this.crossAxisCellCount,
    required this.index,
    required this.mainAxisCellCount,
    required this.picutreIndex,
    required this.postModel,
  }) : super(key: key);

  int crossAxisCellCount;
  int mainAxisCellCount;
  int index;
  int picutreIndex;
  final GetPost postModel;

  @override
  State<SearchImage> createState() => _SearchImageState();
}

class _SearchImageState extends State<SearchImage> {
  String? image = '';
  VideoPlayerController? _controller;
  @override
  void initState() {
    // _setController();

    super.initState();
  }

  // void _setController() {
  //   _controller = VideoPlayerController.network(
  //       mediaUrl + widget.postModel.mediaUrl[0].media)
  //     ..initialize().then((_) {
  //       _controller!.setVolume(0);
  //       setState(() {});
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    return StaggeredGridTile.count(
      crossAxisCellCount: widget.crossAxisCellCount,
      mainAxisCellCount: widget.mainAxisCellCount,
      child: ScaleButton(
        duration: const Duration(milliseconds: 150),
        bound: 0.05,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostPage(
                postId: widget.postModel,
                index: widget.index,
                nickname: widget.postModel.userName,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              color: Colors.grey[200],
            ),
            widget.postModel.mediaUrl[0].mediaType == MediaType.image
                ? Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: double.infinity,
                    child: CachedNetworkImage(
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      maxWidthDiskCache: 300,
                      maxHeightDiskCache: 300,
                      imageUrl: mediaUrl + widget.postModel.mediaUrl[0].media,
                      fit: BoxFit.cover,
                    ),
                    // child: Image(
                    //   image: NetworkImageSSL(
                    //     mediaUrl + widget.postModel.mediaUrl[0].media,
                    //     headers: {},
                    //   ),
                    //   fit: BoxFit.cover,
                    // ),
                  )
                : Container(
                    color: Colors.grey[200],
                    width: double.infinity,
                    height: double.infinity,
                    child: FittedBox(
                      clipBehavior: Clip.antiAlias,
                      fit: BoxFit.cover,
                      child: CachedVideoPreviewWidget(
                        path: mediaUrl + widget.postModel.mediaUrl[0].media,
                        type: SourceType.remote,
                        placeHolder: SkeletonAnimation(
                          shimmerColor: Colors.grey[200]!,
                          child: Container(
                            color: Colors.grey[200],
                          ),
                        ),
                        remoteImageBuilder: (BuildContext context, url) {
                          print(url);
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  url,
                                ),
                              ),
                            ),

                            width: 50,
                            height: 50,
                            // child: Image.network(
                            //   url,
                            //   fit: BoxFit.cover,
                            //   width: double.infinity,
                            //   height: 50,
                            // ),
                          );
                        },
                      ),
                    ),
                  ),
            if (widget.postModel.mediaUrl.length > 1) _lengthOfImages(),
            if (widget.postModel.mediaUrl.length == 1 &&
                widget.postModel.mediaUrl.first.mediaType == MediaType.video)
              _videoWidget(),
          ],
        ),
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
