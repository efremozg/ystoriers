// To parse this JSON data, do
//
//     final postAnswer = postAnswerFromJson(jsonString);

import 'dart:convert';

StroiesRequest storiesAnswerFromJson(String str) =>
    StroiesRequest.fromJson(json.decode(str));

String storiesAnswerToJson(StroiesRequest data) => json.encode(data.toJson());

class StroiesRequest {
  StroiesRequest({
    required this.media,
    required this.reversed,
    required this.mediaType,
  });

  String media;
  bool reversed;
  String mediaType;

  factory StroiesRequest.fromJson(Map<String, dynamic> json) => StroiesRequest(
        media: json["media"],
        reversed: json["is_reversed"],
        mediaType: json["media_type"],
      );

  Map<String, dynamic> toJson() => {
        "media_type": mediaType,
        "media": media,
        "is_reversed": reversed,
      };
}
