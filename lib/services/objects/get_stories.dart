// To parse this JSON data, do
//
//     final getStories = getStoriesFromJson(jsonString);

import 'dart:convert';

GetStories getStoriesFromJson(String str) =>
    GetStories.fromJson(json.decode(str));

String getStoriesToJson(GetStories data) => json.encode(data.toJson());

class GetStories {
  GetStories({
    required this.nickname,
    required this.photo,
    required this.allStories,
    required this.notViewedStories,
  });

  String nickname;
  String? photo;
  List<AllStory> allStories;
  List<NotViewedStory> notViewedStories;

  factory GetStories.fromJson(Map<String, dynamic> json) => GetStories(
        nickname: json["nickname"],
        photo: json["photo"],
        allStories: List<AllStory>.from(
            json["all_stories"].map((x) => AllStory.fromJson(x))),
        notViewedStories: List<NotViewedStory>.from(
            json["not_viewed_stories"].map((x) => NotViewedStory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "photo": photo,
        "all_stories": List<dynamic>.from(allStories.map((x) => x.toJson())),
        "not_viewed_stories":
            List<dynamic>.from(notViewedStories.map((x) => x.toJson())),
      };
}

class AllStory {
  AllStory({
    required this.media,
    required this.mediaType,
    required this.timestamp,
  });

  String media;
  String mediaType;
  int timestamp;

  factory AllStory.fromJson(Map<String, dynamic> json) => AllStory(
        media: json["media"],
        mediaType: json["media_type"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "media": media,
        "media_type": mediaType,
        "timestamp": timestamp,
      };
}

class NotViewedStory {
  NotViewedStory({
    required this.media,
    required this.mediaType,
    required this.timestamp,
  });

  String media;
  String mediaType;
  String timestamp;

  factory NotViewedStory.fromJson(Map<String, dynamic> json) => NotViewedStory(
        media: json["media"],
        mediaType: json["media_type"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "media": media,
        "media_type": mediaType,
        "timestamp": timestamp,
      };
}
