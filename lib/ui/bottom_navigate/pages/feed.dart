import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/feed.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/get_stories.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/stories.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/post/widgets/post.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/strory/story.dart';
import 'package:y_storiers/ui/strory/stories.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_add_publication.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';

class MainPage extends StatefulWidget {
  final Function() openChat;
  final Function() openCamera;
  const MainPage({
    Key? key,
    required this.openChat,
    required this.openCamera,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin<MainPage> {
  bool _loading = true;
  late StreamSubscription<ConnectivityResult> _subscription;
  late var hasConnection;
  bool hasInternet = true;
  bool wasLost = false;

  final _scrollController = ScrollController();

  static const double loadExtent = 80.0;
  double _oldScrollOffset = 0.0;

  GetStories? _stories;
  UserInfo? _user;

  void _getStories() async {
    var nickName = Provider.of<AppData>(context, listen: false).user.nickName;
    var result = await Repository().getStories(nickName);
    if (result != null) {
      setState(() {
        _stories = result;
      });
    }
    return;
  }

  Future<void> _refresh() async {
    _getFeed();
    _getInfo();
    // _getStories();
    getConnectivity();

    return Future.delayed(const Duration(milliseconds: 1500));
  }

  getConnectivity() => _subscription = Connectivity()
          .onConnectivityChanged
          .listen((ConnectivityResult result) async {
        hasConnection = await InternetConnectionChecker().hasConnection;
        var finalResult = result;
        print(hasConnection);
        print(result);
        if (hasConnection == false && finalResult != ConnectivityResult.none) {
          setState(() => wasLost = true);
          StandartSnackBar.showAndDontRemoveUntil(
              context,
              'Потеряно интернет соединение',
              SnackBarStatus.warning(),
              Duration(seconds: 9));
        } else if (wasLost == true &&
            (result != ConnectivityResult.wifi ||
                result != ConnectivityResult.mobile)) {
          StandartSnackBar.show(context, 'Cоединение восстановлено',
              SnackBarStatus.internetResultSuccess());
          setState(() => wasLost = false);
        } else if (hasConnection == false &&
            finalResult == ConnectivityResult.none) {
          StandartSnackBar.showAndDontRemoveUntil(
              context,
              'Потеряно интернет соединение',
              SnackBarStatus.warning(),
              Duration(seconds: 9));
        }
      });

  _scrollControllerListener() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.position.pixels;
    final bool scrollingDown = _oldScrollOffset < offset;
    _oldScrollOffset = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final double positiveReloadBorder = max(maxExtent - loadExtent, 0);

    if (((scrollingDown && offset > positiveReloadBorder) ||
        positiveReloadBorder == 0)) {
      print('is max');
    }
  }

  @override
  void initState() {
    BlocProvider.of<UserBloc>(context).scrollController = _scrollController;
    _scrollController.addListener(_scrollControllerListener);
    Timer(const Duration(seconds: 1), () {
      var provider = Provider.of<AppData>(context, listen: false);
      provider.openStories(false);
      // _getInfo();
      _getStories();
      _getFeed();
    });
    super.initState();
  }

  void _getFeed() async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    BlocProvider.of<UserBloc>(context)
        .add(GetFeed(token: token, context: context));
    var stories = Provider.of<AppData>(context, listen: false).isOpenStories;
  }

  @override
  void dispose() {
    // print('dispose');
    // var provider = Provider.of<AppData>(context, listen: false);
    // provider.openStories(true);
    _subscription.cancel();
    super.dispose();
  }

  void _getInfo() async {
    var user = Provider.of<AppData>(context, listen: false).user;
    BlocProvider.of<UserBloc>(context)
        .add(GetInfo(nickname: user.nickName, token: user.userToken));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: _appBar(),
      backgroundColor: Colors.white,
      body: BlocBuilder<UserBloc, UserState>(builder: (context, builder) {
        _user = BlocProvider.of<UserBloc>(context).userInfo;
        return _body();
      }),
    );
  }

  Widget _testBody() {
    return _allPosts();
  }

  Widget _body() {
    var bloc = BlocProvider.of<UserBloc>(context);
    return InViewNotifierCustomScrollView(
      physics: BouncingScrollPhysics(),
      controller: bloc.scrollController,
      slivers: [
        _appBar(),
        // if (Platform.isAndroid)
        CupertinoSliverRefreshControl(onRefresh: _refresh),
        _storiesPlace(),
        if (bloc.posts.isNotEmpty) _allPosts(),
        if (!bloc.loadPosts)
          SliverToBoxAdapter(
            child: PostWidget(
              post: GetPost(
                  postId: 1,
                  userId: 1,
                  userPhoto: '',
                  userName: '',
                  mediaUrl: [],
                  countOfLikes: 0,
                  timestamp: 0,
                  liked: []),
              play: true,
              nickname: '',
              loading: true,
            ),
          ),
        if (bloc.posts.isEmpty)
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 550,
            ),
          ),
      ],
      isInViewPortCondition:
          (double deltaTop, double deltaBottom, double viewPortDimension) {
        return deltaTop < (0.5 * viewPortDimension) &&
            deltaBottom > (0.5 * viewPortDimension);
      },
    );
  }

  Widget _allPostsTest() {
    var posts = BlocProvider.of<UserBloc>(context).posts;
    // return SliverList(
    //   delegate: SliverChildBuilderDelegate(
    //     (context, index) => PostWidget(
    //       post: posts[index],
    //       onDoubleTap: () {},
    //       nickname: posts[index].userName,
    //     ),
    //     childCount: posts.length,
    //   ),
    // );
    return InViewNotifierList(
      // shrinkWrap: true,
      // physics: NeverScrollableScrollPhysics(),
      builder: (context, index) => InViewNotifierWidget(
        id: '$index',
        builder: (BuildContext context, bool isInView, Widget? child) {
          // print(isInView.toString() + index.toString());
          return PostWidget(
            post: posts[index],
            play: isInView,
            nickname: posts[index].userName,
          );
        },
      ),
      itemCount: posts.length,
      scrollDirection: Axis.vertical,
      // initialInViewIds: ['0'],
      isInViewPortCondition:
          (double deltaTop, double deltaBottom, double viewPortDimension) {
        return deltaTop < (0.5 * viewPortDimension) &&
            deltaBottom > (0.5 * viewPortDimension);
      },
    );
  }

  Widget _allPosts() {
    var posts = BlocProvider.of<UserBloc>(context).posts;
    // return SliverList(
    //   delegate: SliverChildBuilderDelegate(
    //     (context, index) => PostWidget(
    //       post: posts[index],
    //       onDoubleTap: () {},
    //       nickname: posts[index].userName,
    //     ),
    //     childCount: posts.length,
    //   ),
    // );
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => InViewNotifierWidget(
          id: '$index',
          builder: (BuildContext context, bool isInView, Widget? child) =>
              PostWidget(
            post: posts[index],
            play: isInView,
            nickname: posts[index].userName,
          ),
        ),
        childCount: posts.length,
      ),
    );
  }

  Widget _storiesPlace() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 110,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _storiesWidget(),
            Container(
              height: 0.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }

  Widget _storiesWidget() {
    var stories = BlocProvider.of<UserBloc>(context)
        .stories
        .where((element) => !element.stories.isFullViewed!)
        .toList();
    var checkedStories = BlocProvider.of<UserBloc>(context)
        .stories
        .where((element) => element.stories.isFullViewed!)
        .toList();
    stories.addAll(checkedStories);

    var provider = Provider.of<AppData>(context);

    return SizedBox(
      height: 109,
      width: double.infinity,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 5),
        scrollDirection: Axis.horizontal,
        children: [
          _userStories(),
          if (stories.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => StoriesWidget(
                  userInfo: UserInfo(
                    id: 0,
                    email: '',
                    nickname: stories[index].nickname,
                    phoneNumber: '',
                    isAdmin: false,
                    fullName: '',
                    // email: '',
                    description: '',
                    gender: '',
                    birthday: 0,
                    photo: stories[index].avatar,
                    posts: [],
                    stories: stories[index],
                    subscribers: [],
                    subscriptions: [],
                    isInYourSubscription: true,
                    isInYourSubscribers: true,
                    isPhoneConfirmed: true,
                  ),
                  onTap: () {
                    provider.openStories(true);
                    stories[index].stories.isFullViewed = true;

                    // Repository().checkStory(provider.user.userToken,
                    //     stories[index].stories.allStories.first.id);
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.black,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      context: context,
                      builder: (context) => StoryPage(
                        index: index,
                        stories: stories[index].stories,
                        usersStories: stories,
                      ),
                    ).timeout(Duration(milliseconds: 10));
                    setState(() {});
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.black,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      context: context,
                      builder: (context) => StoryPage(
                        index: index,
                        stories: stories[index].stories,
                        usersStories: stories,
                      ),
                    ).then((value) => provider.openStories(false));
                  },
                ),
                itemCount: stories.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _userStories() {
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.05,
      onTap: widget.openCamera,
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(top: 9, right: 5, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 5),
                if (_user != null)
                  if (_user!.stories.stories.allStories.isNotEmpty)
                    StoriesWidget(
                      userInfo: _user,
                      main: true,
                      title: false,
                      onTap: () {
                        if (_user!.stories.stories.allStories.isNotEmpty) {
                          _user!.stories.stories.isFullViewed = true;

                          showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.black,
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height,
                            ),
                            context: context,
                            builder: (context) => StoryPage(
                              userInfo: _user,
                              usersStories: null,
                              index: 0,
                              stories: _user!.stories.stories,
                            ),
                          );
                        }
                      },
                    ),
                if (_user != null)
                  if (_user!.stories.stories.allStories.isEmpty)
                    SizedBox(
                      width: 65,
                      height: 65,
                      child: Stack(
                        children: [
                          if (_user?.photo == null)
                            Image.asset(
                              'assets/user.png',
                              fit: BoxFit.cover,
                              width: 65,
                              height: 65,
                            )
                          else if (_user!.stories.stories.allStories.isEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image(
                                image: NetworkImage(
                                  apiUrl + _user!.photo!,
                                  headers: {},
                                ),
                                fit: BoxFit.cover,
                                width: 65,
                                height: 65,
                              ),
                            ),
                          // Image.asset(
                          //   'assets/account.png',
                          //   width: 65,
                          //   height: 65,
                          // ),
                          if (_user != null)
                            if (_user!.stories.stories.allStories.isEmpty)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  height: 27,
                                  width: 27,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add_circle,
                                      size: 24,
                                      color: Color.fromRGBO(50, 181, 255, 1),
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
              ],
            ),
            if (_user == null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  height: 65,
                  width: 65,
                  child: Image.asset(
                    'assets/user.png',
                    fit: BoxFit.cover,
                    width: 65,
                    height: 65,
                  ),
                ),
              ),
            if (_user != null)
              if (_user!.stories.stories.allStories.isEmpty)
                const SizedBox(height: 3.9),
            Text(
              'Ваша история',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _appBar() {
    var scrollController = BlocProvider.of<UserBloc>(context).scrollController;
    return SliverAppBar(
      title: GestureDetector(
          onTap: () {
            scrollController?.animateTo(0,
                duration: const Duration(seconds: 1), curve: Curves.ease);
          },
          child: Image.asset('assets/1.png', width: 130, height: 30)),
      centerTitle: false,
      elevation: 0,
      pinned: true,
      backgroundColor: Colors.white,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => AddPublicationBottom(
                            openCamera: widget.openCamera,
                          ));
                },
                child: SvgPicture.asset(
                  'assets/add.svg',
                  width: 27,
                  height: 27,
                ),
              ),
              GestureDetector(
                onTap: widget.openChat,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: SvgPicture.asset(
                    'assets/messenger.svg',
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
