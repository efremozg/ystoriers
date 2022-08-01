import 'dart:convert';

import 'package:y_storiers/services/objects/post.dart';

GetPost getPostFromJson(String str) => GetPost.fromJson(json.decode(str));

String getPostToJson(GetPost data) => json.encode(data.toJson());

class GetPost {
  GetPost({
    required this.postId,
    required this.userPhoto,
    required this.userId,
    required this.userName,
    required this.mediaUrl,
    required this.countOfLikes,
    required this.timestamp,
    required this.liked,
  });

  int postId;
  String userPhoto;
  int userId;
  String userName;
  List<Media> mediaUrl;
  int countOfLikes;
  int timestamp;
  List<dynamic> liked;

  factory GetPost.fromJson(Map<String, dynamic> json) => GetPost(
        postId: json["post_id"],
        userPhoto: json["user_photo"] ?? '',
        userId: json["user_id"],
        userName: json["user_name"],
        mediaUrl:
            List<Media>.from(json["media_url"].map((x) => Media.fromJson(x))),
        countOfLikes: json["count_of_likes"],
        timestamp: json["date"],
        liked: List<dynamic>.from(json["liked"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "post_id": postId,
        "user_id": userId,
        "user_name": userName,
        "media_url": List<dynamic>.from(mediaUrl.map((x) => x.toJson())),
        "count_of_likes": countOfLikes,
        "timestamp": timestamp,
        "liked": List<dynamic>.from(liked.map((x) => x)),
      };
}

class Media {
  Media({
    required this.media,
    required this.mediaType,
  });

  String media;
  MediaType mediaType;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        media: json["media"],
        mediaType:
            json["media_type"] == 'image' ? MediaType.image : MediaType.video,
      );

  Map<String, dynamic> toJson() => {
        "media": media,
      };
}
