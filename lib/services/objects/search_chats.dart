// To parse this JSON data, do
//
//     final searchChats = searchChatsFromJson(jsonString);

import 'dart:convert';

SearchChats searchChatsFromJson(String str) =>
    SearchChats.fromJson(json.decode(str));

String searchChatsToJson(SearchChats data) => json.encode(data.toJson());

class SearchChats {
  SearchChats({
    required this.allUsers,
    required this.allUsersFromSubscriptions,
  });

  List<AllUser> allUsers;
  List<AllUser> allUsersFromSubscriptions;

  factory SearchChats.fromJson(Map<String, dynamic> json) => SearchChats(
        allUsers: List<AllUser>.from(
            json["all_users"].map((x) => AllUser.fromJson(x))),
        allUsersFromSubscriptions: List<AllUser>.from(
            json["all_users_from_subscriptions"]
                .map((x) => AllUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "all_users": List<dynamic>.from(allUsers.map((x) => x.toJson())),
        "all_users_from_subscriptions": List<dynamic>.from(
            allUsersFromSubscriptions.map((x) => x.toJson())),
      };
}

class AllUser {
  AllUser({
    required this.id,
    required this.photo,
    required this.nickname,
    required this.name,
  });

  int id;
  String? photo;
  String nickname;
  String? name;

  factory AllUser.fromJson(Map<String, dynamic> json) => AllUser(
        id: json["id"],
        photo: json["photo"],
        nickname: json["nickname"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "photo": photo,
        "nickname": nickname,
        "name": name,
      };
}
