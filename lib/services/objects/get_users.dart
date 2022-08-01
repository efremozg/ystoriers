// To parse this JSON data, do
//
//     final getUsers = getUsersFromJson(jsonString);

import 'dart:convert';

GetUsers getUsersFromJson(String str) => GetUsers.fromJson(json.decode(str));

String getUsersToJson(GetUsers data) => json.encode(data.toJson());

class GetUsers {
  GetUsers({
    required this.allUsers,
  });

  List<AllUser> allUsers;

  factory GetUsers.fromJson(Map<String, dynamic> json) => GetUsers(
        allUsers: List<AllUser>.from(
            json["all_users"].map((x) => AllUser.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "all_users": List<dynamic>.from(allUsers.map((x) => x.toJson())),
      };
}

class AllUser {
  AllUser({
    required this.nickname,
    required this.fullName,
    required this.photo,
  });

  String nickname;
  String fullName;
  String photo;

  factory AllUser.fromJson(Map<String, dynamic> json) => AllUser(
        nickname: json["nickname"],
        fullName: json["full_name"] ?? '',
        photo: json["photo"],
      );

  static Map<String, dynamic> toMap(AllUser user) => {
        "nickname": user.nickname,
        "photo": user.photo,
      };

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "photo": photo,
      };

  static String encode(List<AllUser> musics) => json.encode(
        musics
            .map<Map<String, dynamic>>((music) => AllUser.toMap(music))
            .toList(),
      );

  static List<AllUser> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<AllUser>((item) => AllUser.fromJson(item))
          .toList();
}
