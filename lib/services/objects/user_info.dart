// To parse this JSON data, do
//
//     final userInfo = userInfoFromJson(jsonString);

import 'dart:convert';

import 'package:y_storiers/services/objects/feed.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/stories.dart';

class EditUser {
  bool success;
  UserInfo user;

  EditUser({
    required this.success,
    required this.user,
  });

  factory EditUser.fromJson(Map<String, dynamic> json) => EditUser(
        success: json['success'],
        user: UserInfo.fromJson(json['user']),
      );
}

UserInfo userInfoFromJson(String str) => UserInfo.fromJson(json.decode(str));

String userInfoToJson(UserInfo data) => json.encode(data.toJson());

class UserInfo {
  UserInfo({
    required this.id,
    required this.nickname,
    required this.phoneNumber,
    required this.email,
    required this.isAdmin,
    required this.isPhoneConfirmed,
    required this.fullName,
    required this.description,
    required this.gender,
    required this.birthday,
    required this.photo,
    required this.posts,
    required this.stories,
    required this.subscribers,
    required this.subscriptions,
    required this.isInYourSubscription,
    required this.isInYourSubscribers,
  });

  int id;
  String? nickname;
  String? phoneNumber;
  String? email;
  bool? isAdmin;
  bool? isPhoneConfirmed;
  dynamic fullName;
  dynamic description;
  dynamic gender;
  int? birthday;
  String? photo;
  List<PostInfo> posts;
  StoriesUser stories;
  List<Subscribers> subscribers;
  List<Subscription> subscriptions;
  bool isInYourSubscription;
  bool isInYourSubscribers;

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
        id: json["id"],
        nickname: json["nickname"] ?? '',
        phoneNumber: json["phone_number"] ?? '',
        email: json["email"] ?? '',
        isAdmin: json["is_admin"],
        isPhoneConfirmed: json["is_phone_confirmed"] ?? false,
        fullName: json["full_name"] ?? '',
        description: json["description"] ?? '',
        gender: json["gender"] ?? '',
        birthday: json["birthday"] ?? 0,
        photo: json["photo"],
        posts:
            List<PostInfo>.from(json["posts"].map((x) => PostInfo.fromJson(x))),
        stories: StoriesUser.fromJson(json['stories']),
        subscribers: List<Subscribers>.from(
            json["subscribers"].map((x) => Subscribers.fromJson(x))),
        subscriptions: List<Subscription>.from(
            json["subscriptions"].map((x) => Subscription.fromJson(x))),
        isInYourSubscription: json["is_in_your_subscription"],
        isInYourSubscribers: json["is_in_your_subscribers"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "phone_number": phoneNumber,
        // "email": email,
        "is_admin": isAdmin,
        "is_phone_confirmed": isPhoneConfirmed,
        "full_name": fullName,
        "description": description,
        "gender": gender,
        "birthday": birthday,
        "photo": photo,
        "posts": List<dynamic>.from(posts.map((x) => x.toJson())),
        "subscribers": List<dynamic>.from(subscribers.map((x) => x)),
        "subscriptions":
            List<dynamic>.from(subscriptions.map((x) => x.toJson())),
      };
}

class Story {
  Story({
    required this.media,
    required this.mediaType,
    required this.timestamp,
  });

  String media;
  String mediaType;
  int timestamp;

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        media: json["media"] ?? '',
        mediaType: json["media_type"] ?? '',
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "media": media,
        "media_type": mediaType,
        "timestamp": timestamp,
      };
}

class PostInfo {
  PostInfo({
    required this.postId,
    required this.userPhoto,
    required this.userId,
    required this.userName,
    required this.mediaUrl,
    required this.countOfLikes,
    required this.date,
    required this.liked,
  });

  int postId;
  String userPhoto;
  int userId;
  String userName;
  List<Media> mediaUrl;
  int countOfLikes;
  int date;
  List<dynamic> liked;

  factory PostInfo.fromJson(Map<String, dynamic> json) => PostInfo(
        postId: json["post_id"],
        userPhoto: json["user_photo"] ?? '',
        userId: json["user_id"],
        userName: json["user_name"] ?? '',
        mediaUrl:
            List<Media>.from(json["media_url"].map((x) => Media.fromJson(x))),
        countOfLikes: json["count_of_likes"],
        date: json["date"],
        liked: List<dynamic>.from(json["liked"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "post_id": postId,
        "user_id": userId,
        "user_name": userName,
        "media_url": List<dynamic>.from(mediaUrl.map((x) => x.toJson())),
        "count_of_likes": countOfLikes,
        "date": date,
        "liked": List<dynamic>.from(liked.map((x) => x)),
      };
}

class MediaUrl {
  MediaUrl({
    required this.media,
    required this.mediaType,
  });

  String media;
  String mediaType;

  factory MediaUrl.fromJson(Map<String, dynamic> json) => MediaUrl(
        media: json["media"] ?? '',
        mediaType: json["media_type"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "media": media,
        "media_type": mediaType,
      };
}

Subscription subscriptionFromJson(String str) =>
    Subscription.fromJson(json.decode(str));

String subscriptionToJson(Subscription data) => json.encode(data.toJson());

class Subscription {
  Subscription({
    required this.nickname,
    required this.photo,
    required this.isInYourSubscription,
    required this.isInYourSubscribers,
  });

  String nickname;
  String? photo;
  bool isInYourSubscription;
  bool isInYourSubscribers;

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        nickname: json["nickname"] ?? '',
        photo: json["photo"],
        isInYourSubscription: json["is_in_your_subscription"],
        isInYourSubscribers: json["is_in_your_subscribers"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "photo": photo,
        "is_in_your_subscription": isInYourSubscription,
        "is_in_your_subscribers": isInYourSubscribers,
      };
}

Subscribers subscribersFromJson(String str) =>
    Subscribers.fromJson(json.decode(str));

String subscribersToJson(Subscribers data) => json.encode(data.toJson());

class Subscribers {
  Subscribers({
    required this.nickname,
    required this.photo,
    required this.isInYourSubscription,
    required this.isInYourSubscribers,
  });

  String nickname;
  String? photo;
  bool isInYourSubscription;
  bool isInYourSubscribers;

  factory Subscribers.fromJson(Map<String, dynamic> json) => Subscribers(
        nickname: json["nickname"] ?? '',
        photo: json["photo"],
        isInYourSubscription: json["is_in_your_subscription"],
        isInYourSubscribers: json["is_in_your_subscribers"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "photo": photo,
        "is_in_your_subscription": isInYourSubscription,
        "is_in_your_subscribers": isInYourSubscribers,
      };
}
