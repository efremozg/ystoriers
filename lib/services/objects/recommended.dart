import 'dart:convert';

import 'package:y_storiers/services/objects/get_post.dart';

RecommendedAnswer feedAnswerFromJson(String str) =>
    RecommendedAnswer.fromJson(json.decode(str));

String feedAnswerToJson(RecommendedAnswer data) => json.encode(data.toJson());

class RecommendedAnswer {
  RecommendedAnswer({
    required this.posts,
  });

  List<GetPost> posts;

  factory RecommendedAnswer.fromJson(Map<String, dynamic> json) =>
      RecommendedAnswer(
        posts:
            List<GetPost>.from(json["posts"].map((x) => GetPost.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "posts": List<dynamic>.from(posts.map((x) => x.toJson())),
      };
}
