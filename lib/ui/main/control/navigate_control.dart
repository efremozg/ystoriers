import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/services/tab_item.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/likes.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/feed.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/search.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

import '../../../services/network_service.dart';
import '../../add_post/widgets/standart_snackbar.dart';

class NavigateControl extends StatefulWidget {
  final Function(int) onChangedPage;
  final Function() openChat;
  final Function() openCamera;
  const NavigateControl({
    Key? key,
    required this.onChangedPage,
    required this.openChat,
    required this.openCamera,
  }) : super(key: key);

  @override
  State<NavigateControl> createState() => _NavigateControlState();
}

class _NavigateControlState extends State<NavigateControl>
    with SingleTickerProviderStateMixin {
  final List<TabItem> tabBar = [
    TabItem(
        title: 'Главная',
        icon: SvgPicture.asset('assets/home.svg'),
        activeIcon: SvgPicture.asset('assets/home_active.svg')),
    TabItem(
        title: 'Рекомендации',
        icon: SvgPicture.asset('assets/search.svg'),
        activeIcon: SvgPicture.asset('assets/search_active.svg')),
    TabItem(
        title: 'Действия',
        icon: SvgPicture.asset('assets/heart.svg'),
        activeIcon: SvgPicture.asset('assets/heart_active.svg')),
    TabItem(
      title: 'Профиль',
      image: Image.asset(
        'assets/user.png',
        height: 21,
        width: 21,
      ),
    ),
  ];
  late TabController _tabController;
  int _currentTabIndex = 0;
  final StreamController<int> _streamController = StreamController<int>();

  UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: tabBar.length,
      vsync: this,
      animationDuration: Duration.zero,
    );
    _loadUser();
    // _getInfo();
    _tabController.addListener(() {
      //   setState(() {
      widget.onChangedPage(_tabController.index);
      //     _currentTabIndex = _tabController.index;
      //   });
    });
  }

  void _loadUser() {
    var user = Provider.of<AppData>(context, listen: false).user;
    BlocProvider.of<UserBloc>(context).add(
      GetInfo(nickname: user.nickName, token: user.userToken),
    );
    BlocProvider.of<UserBloc>(context)
        .add(GetNotification(token: user.userToken));

    BlocProvider.of<UserBloc>(context).add(
      GetRecomended(token: user.userToken),
    );
  }

  void _getInfo() async {
    userInfo = BlocProvider.of<UserBloc>(context).userInfo;

    if (userInfo != null) {
      // setState(
      //   () {
      tabBar[3] = (TabItem(
        title: 'Профиль',
        image: userInfo != null
            ? userInfo!.photo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: CachedNetworkImage(
                      imageUrl: mediaUrl + userInfo!.photo!,
                      height: 21,
                      width: 21,
                      memCacheHeight: 50,
                      memCacheWidth: 50,
                      maxWidthDiskCache: 50,
                      maxHeightDiskCache: 50,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/user.png',
                    height: 21,
                    width: 21,
                  )
            : Image.asset(
                'assets/user.png',
                height: 21,
                width: 21,
              ),
        activeIcon: Container(
          padding: EdgeInsets.all(1),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 1.5, color: Colors.black)),
          child: userInfo != null
              ? userInfo!.photo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: CachedNetworkImage(
                        imageUrl: mediaUrl + userInfo!.photo!,
                        height: 21,
                        width: 21,
                        memCacheHeight: 50,
                        memCacheWidth: 50,
                        maxWidthDiskCache: 50,
                        maxHeightDiskCache: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/user.png',
                      height: 21,
                      width: 21,
                    )
              : Image.asset(
                  'assets/user.png',
                  height: 21,
                  width: 21,
                ),
        ),
      ));
      //   },
      // );
    }
  }

  void _checkInternetConncetion() {
    var networkStatus = Provider.of<NetworkStatus>(context);

    if (networkStatus == NetworkStatus.Offline) {
      StandartSnackBar.show(
          context, 'Потеряно интернет соединение', SnackBarStatus.warning());
    } else
      print('network $networkStatus');
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context, listen: true);
    var bloc = BlocProvider.of<UserBloc>(context);
    return BlocBuilder<UserBloc, UserState>(builder: (context, builder) {
      if (BlocProvider.of<UserBloc>(context).userInfo != null) {
        _getInfo();
      }
      return Scaffold(
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: StreamBuilder<int>(
              stream: _streamController.stream,
              initialData: 0,
              builder: (context, snapshot) {
                return BottomNavigationBar(
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedItemColor: Colors.black,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  onTap: (index) {
                    if (index == 0 && snapshot.data == 0) {
                      bloc.scrollController?.animateTo(0,
                          duration: const Duration(seconds: 1),
                          curve: Curves.ease);
                    }
                    _streamController.sink.add(index);
                    // setState(() {
                    _tabController.index = index;
                    //   _currentTabIndex = index;
                    // });
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  currentIndex: snapshot.data!,
                  items: [
                    for (final item in tabBar)
                      BottomNavigationBarItem(
                        activeIcon: item.activeIcon,
                        icon: item.icon ?? item.image!,
                        label: item.title,
                      ),
                  ],
                );
              }),
        ),
        backgroundColor: Colors.white,
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            MainPage(
              openCamera: widget.openCamera,
              openChat: widget.openChat,
            ),
            SearchPage(),
            LikesPage(),
            AccountPage(
              openCamera: widget.openCamera,
            ),
          ],
        ),
      );
    });
  }
}
