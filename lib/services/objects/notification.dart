// To parse this JSON data, do
//
//     final notificationAnswer = notificationAnswerFromJson(jsonString);

import 'dart:convert';

import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/post_answer.dart';
import 'package:y_storiers/services/objects/user_info.dart';

NotificationAnswer notificationAnswerFromJson(String str) =>
    NotificationAnswer.fromJson(json.decode(str));

String notificationAnswerToJson(NotificationAnswer data) =>
    json.encode(data.toJson());

class NotificationAnswer {
  NotificationAnswer({
    required this.sortedNotif,
    required this.sortedNotifDay,
    required this.sortedNotifWeek,
    required this.sortedNotifMonth,
  });

  List<SortedNotif> sortedNotif;
  List<SortedNotif> sortedNotifDay;
  List<SortedNotif> sortedNotifWeek;
  List<SortedNotif> sortedNotifMonth;

  factory NotificationAnswer.fromJson(Map<String, dynamic> json) =>
      NotificationAnswer(
        sortedNotif: List<SortedNotif>.from(
            json["sorted_notif"].map((x) => SortedNotif.fromJson(x))),
        sortedNotifDay: List<SortedNotif>.from(
            json["sorted_notif_day"].map((x) => SortedNotif.fromJson(x))),
        sortedNotifWeek: List<SortedNotif>.from(
            json["sorted_notif_week"].map((x) => SortedNotif.fromJson(x))),
        sortedNotifMonth: List<SortedNotif>.from(
            json["sorted_notif_month"].map((x) => SortedNotif.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sorted_notif": List<dynamic>.from(sortedNotif.map((x) => x.toJson())),
      };
}

class SortedNotif {
  SortedNotif({
    required this.type,
    required this.post,
    required this.userLikedNickname,
    required this.userLikedPhoto,
    required this.timestamp,
    required this.subNickname,
    required this.subPhoto,
    required this.isInYourSubscriptions,
  });

  String type;
  GetPost? post;
  String? userLikedNickname;
  String? userLikedPhoto;
  int timestamp;
  String? subNickname;
  String? subPhoto;
  bool isInYourSubscriptions;

  factory SortedNotif.fromJson(Map<String, dynamic> json) => SortedNotif(
        type: json["type"],
        post: json["post"] == null ? null : GetPost.fromJson(json["post"]),
        userLikedNickname: json["user_liked_nickname"],
        userLikedPhoto:
            json["user_liked_photo"] == null ? null : json["user_liked_photo"],
        timestamp: json["timestamp"],
        subNickname: json["sub_nickname"],
        subPhoto: json["sub_photo"],
        isInYourSubscriptions: json["is_in_your_subscriptions"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "post": post?.toJson(),
        "user_liked_nickname":
            userLikedNickname == null ? null : userLikedNickname,
        "user_liked_photo": userLikedPhoto == null ? null : userLikedPhoto,
        "timestamp": timestamp,
        "sub_nickname": subNickname == null ? null : subNickname,
        "sub_photo": subPhoto == null ? null : subPhoto,
      };
}
