// To parse this JSON data, do
//
//     final subscribeAnswer = subscribeAnswerFromJson(jsonString);

import 'dart:convert';

SubscribeAnswer subscribeAnswerFromJson(String str) =>
    SubscribeAnswer.fromJson(json.decode(str));

String subscribeAnswerToJson(SubscribeAnswer data) =>
    json.encode(data.toJson());

class SubscribeAnswer {
  SubscribeAnswer({
    required this.success,
    required this.subscribe,
  });

  bool success;
  bool subscribe;

  factory SubscribeAnswer.fromJson(Map<String, dynamic> json) =>
      SubscribeAnswer(
        success: json["success"],
        subscribe: json["subscribe"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "subscribe": subscribe,
      };
}
