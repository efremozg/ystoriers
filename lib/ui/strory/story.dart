import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:story_time/story_page_view/story_page_view.dart';
import 'package:y_storiers/bloc/story/story_bloc.dart';
import 'package:y_storiers/bloc/story/story_event.dart';
import 'package:y_storiers/bloc/story/story_state.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/feed.dart';
import 'package:y_storiers/services/objects/stories.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/objects/user_info.dart' as user;
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/strory/stories_video.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_delete_post.dart';

class StoryPage extends StatefulWidget {
  user.UserInfo? userInfo;
  int index;
  StoriesAnswer? stories;
  List<StoriesUser>? usersStories;
  StoryPage({
    Key? key,
    required this.index,
    this.userInfo,
    required this.stories,
    required this.usersStories,
  }) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late ValueNotifier<IndicatorAnimationCommand> indicatorAnimationController;
  Story? story;

  @override
  void initState() {
    super.initState();
    indicatorAnimationController = ValueNotifier<IndicatorAnimationCommand>(
      IndicatorAnimationCommand(pause: true, resume: false),
    );
    setPause();
  }

  @override
  void dispose() {
    indicatorAnimationController.dispose();
    super.dispose();
  }

  void setPause() {
    BlocProvider.of<StoryBloc>(context).add(PauseStory());
    indicatorAnimationController.value = IndicatorAnimationCommand(
      pause: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<StoryBloc>(context);
    setPause();
    return BlocBuilder<StoryBloc, StoryState>(
      bloc: bloc,
      buildWhen: (state, event) {
        if (event is StoryChangePage) {
          if (story?.mediaType == 'video') {
            setPause();
          }
          return true;
        } else if (event is StoryLoaded) {
          indicatorAnimationController.value = IndicatorAnimationCommand(
            duration: bloc.duration,
          );
          print('event is' + event.toString());
          return true;
        } else {
          return false;
        }
      },
      builder: (context, snapshot) {
        return _body(context, bloc);
      },
    );
  }

  SafeArea _body(BuildContext context, StoryBloc bloc) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(top: 50),
        decoration: BoxDecoration(
          border: Border.all(width: 0),
          borderRadius: BorderRadius.circular(30),
          color: Colors.black,
        ),
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _storyPageView(context, bloc),
        ),
      ),
    );
  }

  StoryPageView _storyPageView(BuildContext context, StoryBloc bloc) {
    return StoryPageView(
      initialStoryIndex: (pageIndex) => widget.stories?.index ?? widget.index,
      indicatorAnimationController: indicatorAnimationController,
      indicatorPadding: const EdgeInsets.only(top: 10, left: 5, right: 5),
      onStoryIndexChanged: (value) {
        if (story?.mediaType == 'video') {
          setPause();
        }
        // if (widget.usersStories != null) {
        var token = Provider.of<AppData>(context, listen: false).user.userToken;
        Future.delayed(Duration(milliseconds: 1000), () {
          if (story != null) {
            print('im here');
            //Repository().checkStory(token, story!.id);
          }
        });
        // }
        // if (value != 0) {
        print(value);
        // }
      },
      onPageBack: (value) {
        BlocProvider.of<StoryBloc>(context).add(ChangePageStory());
        Timer(Duration(milliseconds: 1200), () {
          print('media type is: ' + story!.mediaType.toString());
          print('it is a video!!');
          if (story!.mediaType != 'image') {
            print('it is a video!!');
            setPause();
          }
        });
      },
      onPageForward: (value) {
        BlocProvider.of<StoryBloc>(context).add(ChangePageStory());
        print(story?.id);
        if (story!.mediaType == 'video') {
          Future.delayed(Duration(milliseconds: 1000), () {
            setPause();
          });
        }
      },
      indicatorDuration: bloc.duration == null
          ? const Duration(seconds: 5)
          : bloc.duration!.inSeconds < 16
              ? bloc.duration!
              : const Duration(seconds: 15),
      onStoryPaused: () async =>
          BlocProvider.of<StoryBloc>(context).add(PauseStory()),
      onStoryUnpaused: () async =>
          BlocProvider.of<StoryBloc>(context).add(ResumeStory()),
      pageLength: widget.stories != null ? 1 : widget.usersStories!.length,
      storyLength: (int pageIndex) {
        return widget.stories != null
            ? widget.stories!.allStories.length
            : widget.usersStories![pageIndex].stories.allStories.length;
      },
      initialPage: widget.index,
      itemBuilder: (context, pageIndex, storyIndex) {
        if (widget.stories != null) {
          story = widget.stories!.allStories[storyIndex];
        }
        if (widget.usersStories != null) {
          story =
              widget.usersStories![pageIndex].stories.allStories[storyIndex];
        }
        return Stack(
          children: [
            _background(),
            _storyWidget(),
            _nicknameAndTime(pageIndex),
          ],
        );
      },
      gestureItemBuilder: (context, pageIndex, storyIndex) {
        return _bottomButtons(pageIndex);
      },
      onPageLimitReached: () {
        Navigator.maybePop(context);
      },
    );
  }

  Widget _background() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(width: 30, color: Colors.black),
        ),
      ),
    );
  }

  Widget _storyWidget() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.only(bottom: 70),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: story?.mediaType == 'image'
              ? CachedNetworkImage(
                  imageUrl: mediaUrl + story!.media,
                  fit: BoxFit.fitWidth,
                )
              : StoriesVideo(
                  url: story!.media,
                  duration: (duration) async {},
                  loaded: (duration) async {
                    indicatorAnimationController.value =
                        IndicatorAnimationCommand(
                      resume: true,
                      duration: duration,
                    );
                  },
                  pause: () async {
                    indicatorAnimationController.value =
                        IndicatorAnimationCommand(
                      pause: true,
                    );
                  },
                  indicatorAnimationController: indicatorAnimationController,
                ),
        ),
      ),
    );
  }

  Widget _nicknameAndTime(int pageIndex) {
    return GestureDetector(
      onTap: () {
        print('tapped');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(
              user: UserModel(
                [],
                widget.stories != null
                    ? Provider.of<AppData>(context, listen: false).user.nickName
                    : widget.usersStories![pageIndex].nickname.toString(),
                '',
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 25, left: 10),
        child: Row(
          children: [
            if (widget.stories != null)
              if (widget.userInfo?.photo != null)
                Container(
                  height: 32,
                  width: 32,
                  margin: const EdgeInsets.only(bottom: 0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        mediaUrl + widget.userInfo!.photo!,
                      ),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
            if (widget.usersStories?[pageIndex].avatar != null)
              Container(
                height: 32,
                width: 32,
                margin: const EdgeInsets.only(bottom: 0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      mediaUrl + widget.usersStories![pageIndex].avatar!,
                    ),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            if (widget.usersStories?[pageIndex].avatar == null &&
                widget.stories == null)
              Container(
                height: 32,
                width: 32,
                margin: const EdgeInsets.only(bottom: 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/user.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.stories != null
                  ? widget.userInfo?.nickname ??
                      Provider.of<AppData>(context).user.nickName
                  : widget.usersStories![pageIndex].nickname.toString(),
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                _getStoryTime(story!.timestamp),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStoryTime(int timestamp) {
    var time = DateTime.fromMillisecondsSinceEpoch(story!.timestamp * 1000)
        .difference(DateTime.now());
    if (time.inHours * -1 > 0) {
      return (time.inHours * -1).toString() + ' ч';
    } else {
      return (time.inMinutes * -1).toString() + ' мин';
    }
  }

  Widget _bottomButtons(int pageIndex) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () async {
            Future.delayed(Duration(seconds: 1), () {
              BlocProvider.of<StoryBloc>(context).add(PauseStory());
            });
            indicatorAnimationController.value = IndicatorAnimationCommand(
              pause: true,
            );
            // print('tapped');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountPage(
                  user: UserModel(
                    [],
                    widget.stories != null
                        ? Provider.of<AppData>(context, listen: false)
                            .user
                            .nickName
                        : widget.usersStories![pageIndex].nickname.toString(),
                    '',
                  ),
                ),
              ),
            ).then((value) {
              BlocProvider.of<StoryBloc>(context).add(ResumeStory());
              indicatorAnimationController.value = IndicatorAnimationCommand(
                resume: true,
              );
            });
          },
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 250,
              margin: const EdgeInsets.only(top: 20),
              height: 45,
              color: Colors.white.withOpacity(0.0),
            ),
          ),
        ),
        if (widget.stories != null &&
            widget.userInfo?.nickname ==
                Provider.of<AppData>(context, listen: false).user.nickName)
          GestureDetector(
            onTap: () async {},
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 40,
                width: 40,
                color: Colors.transparent,
                margin: EdgeInsets.only(
                    top: 25, right: widget.stories != null ? 60 : 10),
                child: IconButton(
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DeletePostBottom(
                        viewTypeDelete: ViewTypeDelete.stories,
                        storiesId: story!.id,
                        onDelete: () {
                          widget.stories?.allStories.removeWhere(
                              (element) => element.id == story?.id);
                          setState(() {});
                        },
                      ),
                    );
                    // await showModalBottomSheet(
                    //   isScrollControlled: true,
                    //   constraints: const BoxConstraints(
                    //     minHeight: 600,
                    //   ),
                    //   backgroundColor: Colors.transparent,
                    //   context: context,
                    //   builder: (context) => const SendMessageBottom(),
                    // );
                  },
                  icon: const Icon(
                    Icons.more_horiz_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),
          ),
        // Center(
        //   child: ElevatedButton(
        //     child: const Text('show modal bottom sheet'),
        //     onPressed: () async {
        //       indicatorAnimationController.value =
        //           IndicatorAnimationCommand(
        //         pause: true,
        //       );
        //       // await showModalBottomSheet(
        //       //   context: context,
        //       //   builder: (context) => SizedBox(
        //       //     height: MediaQuery.of(context).size.height / 2,
        //       //     child: Padding(
        //       //       padding: const EdgeInsets.all(24),
        //       //       child: Text(
        //       //         'Look! The indicator is now paused\n\n'
        //       //         'It will be coutinued after closing the modal bottom sheet.',
        //       //         style:
        //       //             Theme.of(context).textTheme.headline5,
        //       //         textAlign: TextAlign.center,
        //       //       ),
        //       //     ),
        //       //   ),
        //       // );
        //       // indicatorAnimationController.value =
        //       //     IndicatorAnimationCommand(
        //       //   resume: true,
        //       // );
        //     },
        //   ),
        // ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: IconButton(
              padding: EdgeInsets.zero,
              color: Colors.white,
              icon: const Icon(
                Icons.close_rounded,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: GestureDetector(
        //     onTap: () async {
        //       indicatorAnimationController.value =
        //           IndicatorAnimationCommand.pause;
        //       await showModalBottomSheet(
        //         isScrollControlled: true,
        //         constraints: const BoxConstraints(
        //           minHeight: 600,
        //         ),
        //         backgroundColor: Colors.transparent,
        //         context: context,
        //         builder: (context) => const SendMessageBottom(),
        //       );
        //     },
        //     child: Row(
        //       children: [
        //         Expanded(
        //           flex: 4,
        //           child: Container(
        //             height: 40,
        //             color: Colors.black,
        //             margin: const EdgeInsets.only(bottom: 15, left: 10),
        //             width: MediaQuery.of(context).size.width,
        //             child: SeacrhTextField(
        //               controller: TextEditingController(),
        //               hint: 'Отправить сообщение...',
        //               parameters: false,
        //             ),
        //           ),
        //         ),
        //         const Expanded(
        //           flex: 1,
        //           child: Padding(
        //             padding: EdgeInsets.only(bottom: 15),
        //             child: Icon(
        //               Icons.send,
        //               color: Colors.white,
        //             ),
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
        // _likeWidget(),
      ],
    );
  }

  // Widget _likeWidget() {
  //   return GestureDetector(
  //                           onTap: () {
  //                             // _setLike();
  //                           },
  //                           child: Image.asset(
  //                             story. == null
  //                                 ? !widget.post.liked.contains(nickname)
  //                                     ? 'assets/heart.png'
  //                                     : 'assets/heart_red.png'
  //                                 : liked!
  //                                     ? 'assets/heart_red.png'
  //                                     : 'assets/heart.png',
  //                             width: 25,
  //                             height: 25,
  //                             //  widget.post.isLiked
  //                             // ?
  //                             // : Colors.black,
  //                           ),
  //                         ),
  // }
}
