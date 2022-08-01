import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/get_stories.dart';
import 'package:y_storiers/services/objects/stories.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/ui/strory/story.dart';

enum StoriesPlace {
  account,
  home,
}

class StoriesWidget extends StatefulWidget {
  final double size;
  final bool title;
  final UserInfo? userInfo;
  final Function() onTap;
  final bool main;
  const StoriesWidget({
    Key? key,
    this.size = 72.83,
    required this.onTap,
    this.main = false,
    this.userInfo,
    this.title = true,
  }) : super(key: key);

  @override
  State<StoriesWidget> createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.05,
      onTap: widget.onTap,
      child: Container(
        alignment: Alignment.centerLeft,
        width: widget.size + 5,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.only(top: widget.main ? 0 : 8, right: 5, bottom: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: widget.size,
              width: widget.size,
              decoration:
                  widget.userInfo?.stories.stories.isFullViewed != null &&
                          widget.userInfo!.stories.stories.allStories.isNotEmpty
                      ? widget.userInfo!.stories.stories.isFullViewed!
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.6),
                                width: 1,
                              ),
                            )
                          : null
                      : null,
              child: Stack(
                children: [
                  if (widget.userInfo?.photo != null &&
                      !widget.userInfo!.photo!.contains('mp4'))
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          height: widget.userInfo!.stories.stories.allStories
                                  .isNotEmpty
                              ? widget.main
                                  ? widget.size - 11
                                  : widget.size - 11
                              : widget.main
                                  ? widget.size - 11
                                  : widget.size - 11,
                          width: widget.userInfo!.stories.stories.allStories
                                  .isNotEmpty
                              ? widget.main
                                  ? widget.size - 11
                                  : widget.size - 11
                              : widget.main
                                  ? widget.size - 11
                                  : widget.size - 11,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: widget.userInfo?.photo != null &&
                                  !widget.userInfo!.photo!.contains('mp4')
                              ? CachedNetworkImage(
                                  imageUrl: mediaUrl + widget.userInfo!.photo!,
                                  fit: BoxFit.cover,
                                  height: widget.size - 11,
                                  width: widget.size - 11,
                                )
                              : Image.asset(
                                  'assets/user.png',
                                  fit: BoxFit.cover,
                                  height: widget.size - 11,
                                  width: widget.size - 11,
                                ),
                        ),
                      ),
                    )
                  else
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          height:
                              widget.main ? widget.size - 11 : widget.size - 11,
                          width:
                              widget.main ? widget.size - 11 : widget.size - 11,
                          decoration:
                              const BoxDecoration(shape: BoxShape.circle),
                          child: Image.asset(
                            'assets/user.png',
                            fit: BoxFit.cover,
                            height: widget.size - 11,
                            width: widget.size - 11,
                          ),
                        ),
                      ),
                    ),
                  if (widget.userInfo?.stories.stories.isFullViewed != null)
                    if (!widget.userInfo!.stories.stories.isFullViewed!)
                      // if (widget.userInfo!.stories.allStories.isNotEmpty)
                      Image.asset(
                        'assets/ellipse.png',
                      )
                    else
                      Container()
                  else if (widget.userInfo != null)
                    if (widget.userInfo!.stories.stories.allStories.isNotEmpty)
                      Image.asset(
                        'assets/ellipse.png',
                      )
                  // Image.asset(
                  //   'assets/ellipse.png',
                  // ),
                ],
              ),
            ),
            if (widget.title) const SizedBox(height: 3.9),
            if (widget.title)
              Container(
                width: widget.size + 5,
                child: Center(
                  child: Text(
                    widget.userInfo!.nickname!.length < 7
                        ? widget.userInfo!.nickname!
                        : widget.userInfo!.nickname!.substring(0, 7) + '..',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
