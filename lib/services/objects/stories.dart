// To parse this JSON data, do
//
//     final storiesAnswer = storiesAnswerFromJson(jsonString);

import 'dart:convert';

StoriesAnswer storiesAnswerFromJson(String str) =>
    StoriesAnswer.fromJson(json.decode(str));

String storiesAnswerToJson(StoriesAnswer data) => json.encode(data.toJson());

class StoriesAnswer {
  StoriesAnswer({
    required this.nickname,
    required this.photo,
    required this.allStories,
    // required this.notViewedStories,
    required this.index,
    required this.isFullViewed,
  });

  String? nickname;
  String? photo;
  List<Story> allStories;
  int? index;
  bool? isFullViewed;

  factory StoriesAnswer.fromJson(Map<String, dynamic> json) => StoriesAnswer(
        nickname: json["nickname"],
        photo: json["photo"],
        allStories:
            List<Story>.from(json["all_stories"].map((x) => Story.fromJson(x))),
        index: json["index"],
        isFullViewed: json["is_full_viewed"],
        // notViewedStories: List<Story>.from(
        //   json["not_viewed_stories"].map((x) => Story.fromJson(x)),
        // ),
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "photo": photo,
        "all_stories": List<dynamic>.from(allStories.map((x) => x.toJson())),
        "index": index,
        "is_full_viewed": isFullViewed,
      };
}

class Story {
  Story({
    required this.id,
    required this.media,
    required this.mediaType,
    required this.timestamp,
  });

  String media;
  int id;
  String mediaType;
  int timestamp;

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json["id"],
        media: json["media"] ?? '',
        mediaType: json["media_type"] ?? '',
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "media": media,
        "media_type": mediaType,
        "timestamp": timestamp,
      };
}
