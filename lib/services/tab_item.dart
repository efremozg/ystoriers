import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TabItem {
  String title;
  SvgPicture? icon;
  Widget? image;
  Widget? activeIcon;
  Image? activeImage;
  TabItem(
      {required this.title,
      this.icon,
      this.image,
      this.activeIcon,
      this.activeImage});
}
