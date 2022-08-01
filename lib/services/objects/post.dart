// To parse this JSON data, do
//
//     final postModel = postModelFromJson(jsonString);

import 'dart:convert';

PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

String postModelToJson(PostModel data) => json.encode(data.toJson());

enum MediaType {
  image,
  video,
}

class PostModel {
  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.mediaUrl,
    required this.countOfLikes,
    required this.isLiked,
    required this.date,
  });

  int postId;
  int userId;
  String userName;
  List<MediaUrl> mediaUrl;
  int countOfLikes;
  bool isLiked;
  int date;

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        postId: json["post_id"],
        userId: json["user_id"],
        userName: json["user_name"],
        mediaUrl: List<MediaUrl>.from(
            json["media_url"].map((x) => MediaUrl.fromJson(x))),
        countOfLikes: json["count_of_likes"],
        isLiked: json["is_liked"],
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "post_id": postId,
        "user_id": userId,
        "user_name": userName,
        "media_url": List<dynamic>.from(mediaUrl.map((x) => x.toJson())),
        "count_of_likes": countOfLikes,
        "is_liked": isLiked,
        "date": date,
      };
}

class MediaUrl {
  MediaUrl({
    required this.url,
    required this.mediaType,
  });

  String url;
  MediaType mediaType;

  factory MediaUrl.fromJson(Map<String, dynamic> json) => MediaUrl(
        url: json["url"],
        mediaType:
            json["media_type"] == 'image' ? MediaType.image : MediaType.video,
      );

  Map<String, dynamic> toJson() => {
        "url": url,
      };
}
