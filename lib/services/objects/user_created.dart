// To parse this JSON data, do
//
//     final userCreatedtAnswer = userCreatedtAnswerFromJson(jsonString);

import 'dart:convert';

UserCreatedAnswer userCreatedtAnswerFromJson(String str) =>
    UserCreatedAnswer.fromJson(json.decode(str));

String userCreatedtAnswerToJson(UserCreatedAnswer data) =>
    json.encode(data.toJson());

class UserCreatedAnswer {
  UserCreatedAnswer({
    required this.userCreated,
    required this.id,
  });

  bool userCreated;
  int id;

  factory UserCreatedAnswer.fromJson(Map<String, dynamic> json) =>
      UserCreatedAnswer(
        userCreated: json["user_created"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "user_created": userCreated,
      };
}
