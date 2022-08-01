import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/ui/add_post/add_post.dart';
import 'package:y_storiers/ui/add_post/edit_post.dart';
import 'package:y_storiers/ui/auth/sign_in/login.dart';
import 'package:y_storiers/ui/main/control/stories_control.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/settings/settings.dart';

class AddPublicationBottom extends StatefulWidget {
  final Function() openCamera;
  const AddPublicationBottom({
    Key? key,
    required this.openCamera,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AddPublicationBottom> {
  ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            height: 3,
            width: 30,
            decoration: BoxDecoration(
                color: greyClose, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 15),
          const Text(
            'Создать',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 1,
            color: greyClose.withOpacity(0.21),
          ),
          ScaleButton(
            duration: const Duration(milliseconds: 150),
            bound: 0.04,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const AddPostPage(
                    photoType: PhotoType.publication,
                  ),
                ),
              ).then((value) => Navigator.pop(context, value));
            },
            child: ListTile(
              leading: SizedBox(
                height: 25,
                width: 25,
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/add_post_two.svg',
                      width: 25,
                      height: 25,
                    ),
                    SvgPicture.asset(
                      'assets/add_post_one.svg',
                      width: 25,
                      height: 25,
                    ),
                  ],
                ),
              ),
              title: const Text('Публикация'),
            ),
          ),
          Container(
              width: double.infinity,
              height: 1,
              color: greyClose.withOpacity(0.21)),
          ScaleButton(
            duration: const Duration(milliseconds: 150),
            bound: 0.04,
            onTap: () {
              Navigator.pop(context);
              widget.openCamera();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => StoriesControl(
              //       closeChat: () {},
              //     ),
              //   ),
              // );
              // provider.logOut();
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(builder: (context) => const LoginPage()),
              //     (route) => false);
            },
            child: ListTile(
              leading: SizedBox(
                height: 25,
                width: 25,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: SvgPicture.asset(
                          'assets/add_story_one.svg',
                          height: 8,
                          width: 8,
                        ),
                      ),
                    ),
                    SvgPicture.asset(
                      'assets/add_story_two.svg',
                      width: 25,
                      height: 25,
                    ),
                    SvgPicture.asset(
                      'assets/add_story_three.svg',
                      width: 25,
                      height: 10,
                    ),
                  ],
                ),
              ),
              title: const Text('История'),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: greyClose.withOpacity(0.21),
          ),
        ],
      ),
    );
  }
}
