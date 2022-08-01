// To parse this JSON data, do
//
//     final correctAnswer = correctAnswerFromJson(jsonString);

import 'dart:convert';

CorrectAnswer correctAnswerFromJson(String str) =>
    CorrectAnswer.fromJson(json.decode(str));

String correctAnswerToJson(CorrectAnswer data) => json.encode(data.toJson());

class CorrectAnswer {
  CorrectAnswer({
    required this.isCorrect,
    required this.token,
    required this.id,
    required this.nickname,
  });

  bool isCorrect;
  String? token;
  String? nickname;
  int? id;

  factory CorrectAnswer.fromJson(Map<String, dynamic> json) => CorrectAnswer(
        isCorrect: json["is_correct"],
        token: json["token"] ?? '',
        nickname: json["nickname"] ?? '',
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "is_correct": isCorrect,
        "token": token,
      };
}

class CorrectAnswerCode {
  CorrectAnswerCode({
    required this.isCorrect,
  });

  bool isCorrect;

  factory CorrectAnswerCode.fromJson(Map<String, dynamic> json) =>
      CorrectAnswerCode(
        isCorrect: json["is_correct"],
      );

  Map<String, dynamic> toJson() => {
        "is_correct": isCorrect,
      };
}
