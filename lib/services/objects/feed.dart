// To parse this JSON data, do
//
//     final feedAnswer = feedAnswerFromJson(jsonString);

import 'dart:convert';

import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/stories.dart';

FeedAnswer feedAnswerFromJson(String str) =>
    FeedAnswer.fromJson(json.decode(str));

String feedAnswerToJson(FeedAnswer data) => json.encode(data.toJson());

class FeedAnswer {
  FeedAnswer({
    required this.feed,
    required this.storiesUsers,
  });

  List<GetPost> feed;
  List<StoriesUser> storiesUsers;

  factory FeedAnswer.fromJson(Map<String, dynamic> json) => FeedAnswer(
        feed: List<GetPost>.from(json["feed"].map((x) => GetPost.fromJson(x))),
        storiesUsers: List<StoriesUser>.from(
            json["stories_users"].map((x) => StoriesUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "feed": List<GetPost>.from(feed.map((x) => x.toJson())),
        "stories_users":
            List<StoriesUser>.from(storiesUsers.map((x) => x.toJson())),
      };
}

class StoriesUser {
  StoriesUser({
    required this.id,
    required this.nickname,
    required this.avatar,
    required this.stories,
  });

  int id;
  String nickname;
  String? avatar;
  StoriesAnswer stories;

  factory StoriesUser.fromJson(Map<String, dynamic> json) => StoriesUser(
        id: json['id'] ?? 0,
        nickname: json["nickname"] ?? '',
        avatar: json["avatar"],
        stories: StoriesAnswer.fromJson(json["stories"]),
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "avatar": avatar == null ? null : avatar,
        "stories": stories.toJson(),
      };
}
