import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/points.dart';
import 'package:y_storiers/ui/post/widgets/post_image.dart';
import 'package:y_storiers/ui/post/widgets/post_video.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_delete_post.dart';

class PostWidget extends StatefulWidget {
  PostWidget({
    Key? key,
    required this.post,
    required this.play,
    this.onDeleted,
    this.main,
    this.loading = false,
    required this.nickname,
  }) : super(key: key);
  GetPost post;
  String nickname;
  Function()? onDeleted;
  bool loading;
  bool? main;
  bool play;

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget>
    with AutomaticKeepAliveClientMixin {
  var streamController = StreamController<int>();
  var scrollController = ScrollController();
  final PageController _tabController = PageController(initialPage: 0);
  final ValueKey _key = ValueKey('disable sound');
  bool? liked;

  // String? userPhoto;

  void _setLike() async {
    print('im here');
    setState(() {
      liked = liked == null ? true : !liked!;
      if (liked!) {
        widget.post.countOfLikes++;
      } else {
        widget.post.countOfLikes--;
      }
    });
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    var result = await Repository().likePosts(token, widget.post.postId);
    BlocProvider.of<UserBloc>(context).add(GetNotification(token: token));
  }

  // void _getProfiePhoto() async {
  //   var token = Provider.of<AppData>(context, listen: false).user.userToken;
  //   var result = await Repository().getInfo(widget.nickname, token, context);

  //   if (result != null) {
  //     if (result.photo != null) {
  //       setState(() {
  //         userPhoto = result.photo!;
  //       });
  //     }
  //   }
  // }

  void _deletePost() async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    var result = await Repository().deletePost(token, widget.post.postId);
    if (result != null) {
      if (result.success) {
        BlocProvider.of<UserBloc>(context)
            .add(DeletePost(postId: widget.post.postId));
        widget.onDeleted!();
      }
    }
  }

  @override
  void initState() {
    if (!widget.loading) {
      // _getProfiePhoto();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // for (var element in post.images) {
    //   _streams.add(StreamController<int>());
    // }
    // print(userPhoto);

    var nickname = Provider.of<AppData>(context).user.nickName;
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                    user: UserModel([], widget.nickname, ''),
                  ),
                ),
              );
            },
            child: SizedBox(
              height: 55,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!widget.loading)
                          if (widget.post.userPhoto == '')
                            Image.asset(
                              'assets/user.png',
                              height: 30,
                              width: 30,
                            )
                          else
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: mediaUrl + widget.post.userPhoto,
                                maxHeightDiskCache: 100,
                                maxWidthDiskCache: 100,
                                fit: BoxFit.cover,
                                height: 30,
                                width: 30,
                              ),
                            )
                        else
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: SkeletonAnimation(
                              shimmerColor: Colors.grey[200]!,
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 9),
                        if (!widget.loading)
                          Text(
                            widget.nickname,
                            style: const TextStyle(
                                fontFamily: 'SF UI', fontSize: 14),
                          )
                        else
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SkeletonAnimation(
                              shimmerColor: Colors.grey[200]!,
                              child: Container(
                                height: 30,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.nickname == nickname)
                    Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: IconButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => DeletePostBottom(
                                      viewTypeDelete: ViewTypeDelete.post,
                                      onDelete: _deletePost,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.more_horiz_rounded,
                                  color: Colors.black,
                                  size: 23,
                                )),
                          ),
                        ))
                ],
              ),
            ),
          ),
          GestureDetector(
            onDoubleTap: () {
              _setLike();
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.width,
              child: !widget.loading
                  ? PageView.builder(
                      controller: _tabController,
                      onPageChanged: (index) {
                        streamController.sink.add(index);
                      },
                      itemBuilder: (context, index) =>
                          widget.post.mediaUrl[index].mediaType ==
                                  MediaType.image
                              ? PostImage(post: widget.post, index: index)
                              : PostVideo(
                                  play: widget.play,
                                  post: widget.post,
                                  index: index,
                                  main: widget.main,
                                ),
                      itemCount: widget.post.mediaUrl.length,
                    )
                  : SkeletonAnimation(
                      shimmerColor: Colors.grey[200]!,
                      child: Container(
                        color: Colors.grey[200],
                      ),
                    ),
            ),
          ),
          SizedBox(
            height: 68,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 13),
                        if (!widget.loading)
                          GestureDetector(
                            onTap: () {
                              _setLike();
                            },
                            child: Image.asset(
                              liked == null
                                  ? !widget.post.liked.contains(nickname)
                                      ? 'assets/heart.png'
                                      : 'assets/heart_red.png'
                                  : liked!
                                      ? 'assets/heart_red.png'
                                      : 'assets/heart.png',
                              width: 25,
                              height: 25,
                              //  widget.post.isLiked
                              // ?
                              // : Colors.black,
                            ),
                          ),
                        if (!widget.loading) const SizedBox(width: 16),
                        if (!widget.loading)
                          Container(
                            height: 27,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Нравится: " +
                                    widget.post.countOfLikes.toString(),
                                style: const TextStyle(
                                  fontFamily: 'SF UI',
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        if (widget.loading)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SkeletonAnimation(
                              shimmerColor: Colors.grey[200]!,
                              child: Container(
                                height: 20,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 8.74),
                      child: !widget.loading
                          ? Text(
                              readTimestamp(widget.post.timestamp),
                              style: TextStyle(color: greyTextColor),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: SkeletonAnimation(
                                shimmerColor: Colors.grey[200]!,
                                child: Container(
                                  height: 20,
                                  width: 113,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                if (widget.post.mediaUrl.length > 1)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10.61),
                      height: 30,
                      width: 50,
                      child: StreamBuilder<int>(
                        stream: streamController.stream,
                        initialData: 0,
                        builder: (context, snapshot) {
                          return Center(
                            child: ListView.builder(
                              controller: scrollController,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                // print(scrollController.initialScrollOffset.);
                                scrollController.animateTo(
                                    snapshot.data! > 1
                                        ? snapshot.data!.toDouble() * 9
                                        : 0,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease);
                                return Align(
                                  child: PostPoints(
                                    index: index,
                                    position: snapshot.data ?? 0,
                                  ),
                                );
                              },
                              itemCount: widget.post.mediaUrl.length,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = formatDate(date, [yyyy, '.', mm, '.', dd]);
    }
    if (diff.inDays < 1) {
      time = ' Сегодня';
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' день назад';
      } else {
        if (diff.inDays < 5) {
          time = diff.inDays.toString() + ' дня назад';
        } else {
          time = diff.inDays.toString() + ' дней назад';
        }
      }
    } else if (diff.inMinutes < 60) {
      // if (diff.inDays == 7) {
      time = (diff.inMinutes).floor().toString() + 'Неделю';
      // } else {
      // time = (diff.inMinutes / 7).floor().toString() + ' WEEKS AGO';
      // }
    } else if (diff.inDays < 7) {
      time = (diff.inDays).floor().toString() + ' неделю назад';
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' неделю назад';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' неделю назад';
      }
    }

    return time;
  }

  @override
  bool get wantKeepAlive => true;
}
