import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/network_service.dart';
import 'package:y_storiers/ui/add_post/add_post.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/main/control/navigate_control.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/likes.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/feed.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/search.dart';
import 'package:y_storiers/ui/camera/camera.dart';
import 'package:y_storiers/ui/chat/pages/all_chats.dart';
import 'package:y_storiers/ui/main/control/stories_control.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class MainPageControl extends StatefulWidget {
  const MainPageControl({Key? key}) : super(key: key);

  @override
  State<MainPageControl> createState() => _MainPageControlState();
}

class _MainPageControlState extends State<MainPageControl>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // int _currentTabIndex = 0;
  bool _isScrollable = true;

  @override
  void initState() {
    super.initState();
    //_checkInternetConncetion();
    _tabController = TabController(initialIndex: 2, length: 4, vsync: this);
    _tabController.addListener(() {
      // setState(() {
      //   _currentTabIndex = _tabController.index;
      // });
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: TabBarView(
          physics: _isScrollable
              ? ClampingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            AddPostPage(
              photoType: PhotoType.stories,
              returnToMain: () {
                setState(() {
                  //_checkInternetConncetion();
                  _tabController.index = 2;
                });
              },
            ),
            StoriesControl(
              closeChat: () {
                setState(() {
                  //_checkInternetConncetion();
                  _tabController.index = 2;
                });
              },
              openAddPhoto: () {
                setState(() {
                  // _checkInternetConncetion();
                  _tabController.index = 0;
                });
              },
            ),
            NavigateControl(
              openCamera: () {
                setState(() {
                  //_checkInternetConncetion();
                  // _currentTabIndex = 0;
                  _tabController.index = 1;
                });
              },
              onChangedPage: (page) {
                setState(() {
                  //_checkInternetConncetion();
                  page == 0 ? _isScrollable = true : _isScrollable = false;
                });
                if (_isScrollable) {
                  provider.openStories(false);
                } else {
                  provider.openStories(true);
                }
              },
              openChat: () {
                setState(() {
                  _tabController.index = 3;
                });
              },
            ),
            AllChatsPage(
              closeChat: () {
                setState(() {
                  // _currentTabIndex = 1;
                  _tabController.index = 2;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
