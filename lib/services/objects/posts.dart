// To parse this JSON data, do
//
//     final postAnswer = postAnswerFromJson(jsonString);

import 'dart:convert';

PostRequest postAnswerFromJson(String str) =>
    PostRequest.fromJson(json.decode(str));

String postAnswerToJson(PostRequest data) => json.encode(data.toJson());

class PostRequest {
  PostRequest({
    required this.media,
    required this.description,
  });

  List<Media> media;
  String description;

  factory PostRequest.fromJson(Map<String, dynamic> json) => PostRequest(
        media: List<Media>.from(json["media"].map((x) => Media.fromJson(x))),
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "media": List<dynamic>.from(media.map((x) => x.toJson())),
        "description": description,
      };
}

class Media {
  Media({
    required this.media,
    required this.mediaType,
  });

  String media;
  String mediaType;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        media: json["base64"],
        mediaType: json["media_type"],
      );

  Map<String, dynamic> toJson() => {
        "base64": media,
        "media_type": mediaType,
      };
}
