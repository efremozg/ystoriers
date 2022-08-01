// To parse this JSON data, do
//
//     final successAnswer = successAnswerFromJson(jsonString);

import 'dart:convert';

SuccessAnswer successAnswerFromJson(String str) =>
    SuccessAnswer.fromJson(json.decode(str));

String successAnswerToJson(SuccessAnswer data) => json.encode(data.toJson());

class SuccessAnswer {
  SuccessAnswer({
    required this.success,
  });

  bool success;

  factory SuccessAnswer.fromJson(Map<String, dynamic> json) => SuccessAnswer(
        success: json["success"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
      };
}
