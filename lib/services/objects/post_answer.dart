import 'dart:convert';

import 'package:y_storiers/services/objects/user_info.dart';

PostAnswer postAnswerFromJson(String str) =>
    PostAnswer.fromJson(json.decode(str));

String postAnswerToJson(PostAnswer data) => json.encode(data.toJson());

class PostAnswer {
  PostAnswer({
    required this.postCreated,
    required this.post,
    required this.id,
  });

  bool postCreated;
  PostInfo post;
  int id;

  factory PostAnswer.fromJson(Map<String, dynamic> json) => PostAnswer(
        postCreated: json["post_created"],
        post: PostInfo.fromJson(json["post"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "post_created": postCreated,
        "post": post.toJson(),
        "id": id,
      };
}

// class Post {
//   Post({
//     required this.postId,
//     required this.userId,
//     required this.userName,
//     required this.mediaUrl,
//     required this.countOfLikes,
//     required this.date,
//     required this.liked,
//   });

//   int postId;
//   int userId;
//   String userName;
//   List<MediaUrl> mediaUrl;
//   int countOfLikes;
//   int date;
//   List<dynamic> liked;

//   factory Post.fromJson(Map<String, dynamic> json) => Post(
//         postId: json["post_id"],
//         userId: json["user_id"],
//         userName: json["user_name"],
//         mediaUrl: List<MediaUrl>.from(
//             json["media_url"].map((x) => MediaUrl.fromJson(x))),
//         countOfLikes: json["count_of_likes"],
//         date: json["date"],
//         liked: List<dynamic>.from(json["liked"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "post_id": postId,
//         "user_id": userId,
//         "user_name": userName,
//         "media_url": List<dynamic>.from(mediaUrl.map((x) => x.toJson())),
//         "count_of_likes": countOfLikes,
//         "date": date,
//         "liked": List<dynamic>.from(liked.map((x) => x)),
//       };
// }
