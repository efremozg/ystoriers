import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/ui/add_post/add_post.dart';
import 'package:y_storiers/ui/camera/add_story.dart';
import 'package:y_storiers/ui/camera/get_story.dart';
import 'package:y_storiers/ui/main/control/navigate_control.dart';
import 'package:y_storiers/ui/camera/camera.dart';
import 'package:y_storiers/ui/chat/pages/all_chats.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class StoriesControl extends StatefulWidget {
  const StoriesControl({
    Key? key,
    required this.closeChat,
    required this.openAddPhoto,
  }) : super(key: key);

  final Function() closeChat;
  final Function() openAddPhoto;

  @override
  State<StoriesControl> createState() => _StoriesControlState();
}

class _StoriesControlState extends State<StoriesControl>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  // int _currentTabIndex = 0;
  bool _isScrollable = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: PageView(
        physics: const ClampingScrollPhysics(),
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          CameraPage(
            closeChat: widget.closeChat,
            openPicker: () {
              setState(() {
                _pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.decelerate,
                );
              });
            },
            openAddPhoto: () {
              widget.openAddPhoto();
            },
          ),
          GetStoryPage(
            closePicker: () {
              setState(() {
                _pageController.animateToPage(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.decelerate,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
