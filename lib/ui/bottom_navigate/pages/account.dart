import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/placeholder.dart';
import 'package:y_storiers/ui/chat/pages/test/chat.dart';
import 'package:y_storiers/ui/post/post.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/settings/settings.dart';
import 'package:y_storiers/ui/strory/story.dart';
import 'package:y_storiers/ui/subscribers/subscribers.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_add_photo.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_add_publication.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_logout.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_unsubcribe_user.dart';
import 'package:y_storiers/ui/strory/stories.dart';

class AccountPage extends StatefulWidget {
  final UserModel? user;
  final Function()? openCamera;
  const AccountPage({
    Key? key,
    this.user,
    this.openCamera,
  }) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with AutomaticKeepAliveClientMixin<AccountPage> {
  bool onTapSubscribe = true;
  bool isOpenPost = false;
  GetPost? _getPost;

  Future<void> _refresh() async {
    var user = Provider.of<AppData>(context, listen: false).user;
    if (widget.user == null) {
      BlocProvider.of<UserBloc>(context).add(
        GetInfo(
          nickname: user.nickName,
          token: user.userToken,
        ),
      );
    } else {
      _getInfo();
    }
    setState(() {});
    return Future.delayed(const Duration(milliseconds: 500));
  }

  UserInfo? userInfo;
  bool _loading = true;

  @override
  void initState() {
    // Timer(const Duration(milliseconds: 500), () {
    if (widget.user != null) {
      _getInfo();
    }
    // });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _refresh();
    super.didChangeDependencies();
  }

  void _subscribe() async {
    var user = Provider.of<AppData>(context, listen: false).user;
    // print(userInfo!.nickname);
    var result =
        await Repository().subscribe(userInfo!.nickname!, user.userToken);

    if (result != null) {
      BlocProvider.of<UserBloc>(context).add(
        GetInfo(
          nickname: user.nickName,
          token: user.userToken,
        ),
      );
    }
  }

  void _getInfo() async {
    var user = Provider.of<AppData>(context, listen: false).user;
    var result = await Repository().getInfo(
        widget.user != null ? widget.user!.userName : user.nickName,
        user.userToken,
        null);

    if (result != null) {
      setState(() {
        userInfo = result;
        userInfo?.posts = result.posts.reversed.toList();
        _loading = false;
      });
      // print(result.stories.allStories[0].media);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: !isOpenPost ? _appBar() : null,
      body: BlocBuilder<UserBloc, UserState>(builder: (context, builder) {
        if (widget.user == null) {
          userInfo = BlocProvider.of<UserBloc>(context).userInfo;
        }
        return !isOpenPost
            ? _body(context)
            : PostPage(
                postId: _getPost!, index: 0, nickname: userInfo!.nickname!);
      }),
    );
  }

  CustomScrollView _body(BuildContext context) {
    var userName = Provider.of<AppData>(context).user.nickName;
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _refresh),
        _topInfo(),
        _bio(),
        if (widget.user == null || userInfo?.nickname == userName)
          _editButton(),
        if (widget.user != null &&
            userInfo?.nickname != userName &&
            userInfo != null)
          _openChat(context),
        // if (widget.user == null || userInfo?.nickname == userName) _highligts(),
        const SliverToBoxAdapter(
          child: SizedBox(
            height: 30,
            width: double.infinity,
          ),
        ),
        SliverToBoxAdapter(
          child: _greyLine(),
        ),
        _images(),
      ],
    );
  }

  CustomScrollView _alterBody(BuildContext context) {
    var userName = Provider.of<AppData>(context).user.nickName;
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(onRefresh: _refresh),
        _topInfo(),
        _bio(),
        if (widget.user == null || userInfo?.nickname == userName)
          _editButton(),
        if (widget.user != null &&
            userInfo?.nickname != userName &&
            userInfo != null)
          _openChat(context),
        // if (widget.user == null || userInfo?.nickname == userName) _highligts(),
        // if (widget.user == null || userInfo?.nickname == userName)
        SliverToBoxAdapter(
          child: _greyLine(),
        ),
        _images(),
      ],
    );
  }

  Widget _greyLine() {
    return Container(
      width: double.infinity,
      height: 1,
      color: greyClose.withOpacity(0.21),
    );
  }

  Widget _images() {
    return userInfo != null
        ? userInfo!.posts.isNotEmpty
            ? SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ScaleButton(
                    duration: const Duration(milliseconds: 150),
                    bound: 0.04,
                    onTap: () {
                      print('object');
                      // setState(() {
                      //   isOpenPost = true;
                      // });
                    },
                    child: userInfo != null
                        ? PlaceHolder(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PostPage(
                                    postId: GetPost(
                                        postId: userInfo!.posts[index].postId,
                                        userPhoto:
                                            userInfo!.posts[index].userPhoto,
                                        userId: userInfo!.posts[index].userId,
                                        userName:
                                            userInfo!.posts[index].userName,
                                        mediaUrl:
                                            userInfo!.posts[index].mediaUrl,
                                        countOfLikes:
                                            userInfo!.posts[index].countOfLikes,
                                        timestamp: userInfo!.posts[index].date,
                                        liked: userInfo!.posts[index].liked),
                                    nickname: userInfo!.nickname!,
                                    index: 0,
                                  ),
                                ),
                              );
                              // setState(() {
                              //   isOpenPost = true;
                              //   _getPost = GetPost(
                              //     postId: userInfo!.posts[index].postId,
                              //     userPhoto: userInfo!.posts[index].userPhoto,
                              //     userId: userInfo!.posts[index].userId,
                              //     userName: userInfo!.posts[index].userName,
                              //     mediaUrl: userInfo!.posts[index].mediaUrl,
                              //     countOfLikes:
                              //         userInfo!.posts[index].countOfLikes,
                              //     timestamp: userInfo!.posts[index].date,
                              //     liked: userInfo!.posts[index].liked,
                              //   );
                              // });
                            },
                            index: index,
                            nickname: userInfo!.nickname!,
                            postModel: userInfo!.posts[index],
                          )
                        : SkeletonAnimation(
                            shimmerColor: Colors.grey[200]!,
                            child: Container(
                              color: Colors.grey[200],
                            ),
                          ),
                  ),
                  childCount: userInfo != null
                      ? userInfo!.posts
                          .where((element) => element.mediaUrl.isNotEmpty)
                          .length
                      : 15,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
              )
            : SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  child: Center(
                    child: Image.asset(
                      'assets/camera.png',
                      width: 80,
                      height: 80,
                      color: greyTextColor,
                    ),
                  ),
                ),
              )
        : SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => SkeletonAnimation(
                shimmerColor: Colors.grey[200]!,
                child: Container(
                  color: Colors.grey[200],
                ),
              ),
              childCount: 15,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
          );
  }

  SliverToBoxAdapter _openChat(BuildContext context) {
    var userId = Provider.of<AppData>(context).user.userId;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(top: 17, bottom: 0),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Expanded(flex: 1, child: _subscribeCard()),
            const SizedBox(width: 5),
            Expanded(
              flex: 1,
              child: WhiteButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPageTest(
                        chatId: getChatId(
                          userInfo!.id.toString(),
                          userId.toString(),
                        ),
                        userInfo: userInfo!,
                      ),
                    ),
                  );
                },
                title: 'Написать',
                height: 30,
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _highligts() {
    var nickname = Provider.of<AppData>(context, listen: false).user.nickName;
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 109,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 15),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => StoriesWidget(
                size: 65,
                onTap: () {
                  // showModalBottomSheet(
                  //   isScrollControlled: true,
                  //   backgroundColor: Colors.black,
                  //   constraints: BoxConstraints(
                  //     minHeight: MediaQuery.of(context).size.height,
                  //   ),
                  //   context: context,
                  //   builder: (context) => StoryPage(
                  //     stories: null,
                  //     index: 0,
                  //   ),
                  // );
                },
              ),
              itemCount: 0,
            ),
            if (widget.user == null || userInfo?.nickname == nickname)
              _addHighligt()
          ],
        ),
      ),
    );
  }

  Align _addHighligt() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ScaleButton(
        duration: const Duration(milliseconds: 150),
        bound: 0.05,
        child: Container(
          width: 65,
          margin: const EdgeInsets.only(top: 8, right: 15, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 65,
                width: 65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1,
                    color: addStoryColor,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: SvgPicture.asset(
                        'assets/add_story.svg',
                        width: 20,
                      ),
                    ),
                    Center(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: SvgPicture.asset(
                          'assets/add_story.svg',
                          width: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3.9),
              const Padding(
                padding: EdgeInsets.only(left: 0),
                child: Text(
                  'New',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subscribeCard() {
    return !userInfo!.isInYourSubscription
        ? BlueButton(
            onTap: () {
              _subscribe();
              setState(() {
                userInfo!.isInYourSubscription =
                    !userInfo!.isInYourSubscription;
              });
            },
            height: 30,
          )
        : WhiteButton(
            onTap: () {
              _subscribe();
              setState(() {
                userInfo!.isInYourSubscription =
                    !userInfo!.isInYourSubscription;
              });
            },
            title: 'Отменить подписку',
            height: 30,
          );
  }

  Widget _editButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
            left: 15,
            right: 15,
            top: _loading && userInfo != null && userInfo!.posts.isNotEmpty
                ? 15
                : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(3),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => SettingsPage(),
              ),
            ).then((value) {
              if (value is UserInfo) {
                setState(() {
                  userInfo = value;
                });
              }
            });
          },
          child: Container(
            height: 35,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.7,
                color: const Color.fromRGBO(203, 203, 203, 1),
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Center(
              child: Text(
                'Редактировать профиль',
                style: TextStyle(
                  fontFamily: 'SF UI',
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bio() {
    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 15, right: 15, left: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (userInfo != null)
              // if (userInfo?.fullName != null)
              Text(
                userInfo != null && userInfo?.fullName != null
                    ? userInfo!.fullName != ''
                        ? userInfo!.fullName!
                        : userInfo!.nickname
                    : Provider.of<AppData>(context).user.nickName,
                style: const TextStyle(
                  fontFamily: 'SF UI',
                  fontSize: 15,
                ),
              )
            // else
            //   Container()
            else
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SkeletonAnimation(
                  shimmerColor: Colors.grey[200]!,
                  child: Container(
                    height: 20,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                  ),
                ),
              ),
            if (userInfo != null)
              if (userInfo?.description != null)
                Text(
                  userInfo != null && userInfo?.description != null
                      ? userInfo!.description!
                      : '',
                  style: TextStyle(fontSize: 15),
                )
              else
                Container()
            else
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SkeletonAnimation(
                    shimmerColor: Colors.grey[200]!,
                    child: Container(
                      height: 15,
                      width: 130,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
              ),
            // if (userInfo.)
            // const Text(
            //   'Link goes here',
            //   style:
            //       TextStyle(fontSize: 16, color: Color.fromRGBO(0, 76, 139, 1)),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _placeHolder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SkeletonAnimation(
        shimmerColor: Colors.grey[200]!,
        child: Container(
          height: 20,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.grey[200],
          ),
        ),
      ),
    );
  }

  Widget _topInfo() {
    return BlocBuilder<UserBloc, UserState>(builder: (context, snapshot) {
      return SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: StoriesWidget(
                userInfo: userInfo,
                size: 87,
                title: false,
                onTap: () {
                  showModalBottomSheet(
                      context: context, builder: (context) => AddPhotoBottom());
                  if (userInfo!.stories.stories.allStories.isNotEmpty) {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.black,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      context: context,
                      builder: (context) => StoryPage(
                        index: 0,
                        stories: userInfo!.stories.stories,
                        userInfo: userInfo,
                        usersStories: null,
                      ),
                    );
                  }
                },
              ),
            ),
            Row(
              children: [
                Column(
                  children: [
                    if (userInfo != null)
                      Text(
                        userInfo != null
                            ? userInfo!.posts.length.toString()
                            : '',
                        style: TextStyle(fontFamily: 'SF UI', fontSize: 16),
                      )
                    else
                      _placeHolder(),
                    const SizedBox(height: 5),
                    const Text(
                      'Публикации',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 15),
                ScaleButton(
                  duration: const Duration(milliseconds: 150),
                  bound: 0.04,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscribersPage(
                          viewType: ViewType.mySubscribers,
                          userInfo: userInfo!,
                          onChanged: (result) {
                            setState(() {
                              userInfo = result;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        if (userInfo != null)
                          Text(
                            userInfo!.subscribers.length.toString(),
                            style: const TextStyle(
                                fontFamily: 'SF UI', fontSize: 16),
                          )
                        else
                          _placeHolder(),
                        const SizedBox(height: 5),
                        const Text(
                          'Подписчики',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ScaleButton(
                  duration: const Duration(milliseconds: 150),
                  bound: 0.04,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscribersPage(
                          viewType: ViewType.subscribers,
                          userInfo: userInfo!,
                          onChanged: (result) {
                            setState(() {
                              userInfo = result;
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        if (userInfo != null)
                          Text(
                            userInfo!.subscriptions.length.toString(),
                            style: const TextStyle(
                                fontFamily: 'SF UI', fontSize: 16),
                          )
                        else
                          _placeHolder(),
                        const SizedBox(height: 5),
                        const Text(
                          'Подписки',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 22),
              ],
            )
          ],
        ),
      );
    });
  }

  AppBar _appBar() {
    var provider = Provider.of<AppData>(context);
    return AppBar(
      elevation: 0,
      foregroundColor: Colors.black,
      backgroundColor: Colors.white,
      title: Text(
        widget.user?.userName ?? provider.user.nickName,
        style: const TextStyle(
          fontFamily: 'SF UI',
          fontSize: 22,
          color: Colors.black,
        ),
      ),
      actions: [
        if (widget.user == null ||
            widget.user!.userName == provider.user.nickName)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => AddPublicationBottom(
                            openCamera: () {
                              widget.openCamera!();
                            },
                          )).then((value) {
                    if (value is PostInfo) {
                      // setState(() {
                      //   userInfo?.posts.insert(
                      //     0,
                      //     Post(
                      //       postId: value.postId,
                      //       userId: value.userId,
                      //       userName: value.userName,
                      //       mediaUrl: value.mediaUrl,
                      //       countOfLikes: value.countOfLikes,
                      //       date: value.date,
                      //       liked: value.liked,
                      //     ),
                      //   );
                      // });
                    }
                  });
                  // provider.logOut();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: SvgPicture.asset(
                    'assets/add.svg',
                    width: 27,
                    height: 27,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => LogoutBottom(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Image.asset(
                    'assets/menu.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              )
            ],
          )
        else if (userInfo != null)
          userInfo!.isInYourSubscription
              ? GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) => const UnsubscribeUserBottom())
                        .then((value) {
                      if (value is bool) {
                        _subscribe();
                        setState(() {
                          userInfo!.isInYourSubscription =
                              !userInfo!.isInYourSubscription;
                        });
                      }
                    });
                    // provider.logOut();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.more_horiz_outlined,
                      color: Colors.black,
                    ),
                  ),
                )
              : Container()
      ],
      centerTitle: widget.user != null ? true : false,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
