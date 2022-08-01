// To parse this JSON data, do
//
//     final likeAnswer = likeAnswerFromJson(jsonString);

import 'dart:convert';

LikeAnswer likeAnswerFromJson(String str) =>
    LikeAnswer.fromJson(json.decode(str));

String likeAnswerToJson(LikeAnswer data) => json.encode(data.toJson());

class LikeAnswer {
  LikeAnswer({
    required this.success,
    required this.isLike,
  });

  bool success;
  bool isLike;

  factory LikeAnswer.fromJson(Map<String, dynamic> json) => LikeAnswer(
        success: json["success"],
        isLike: json["is_like"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "is_like": isLike,
      };
}
