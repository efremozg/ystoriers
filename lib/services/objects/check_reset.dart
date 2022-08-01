// To parse this JSON data, do
//
//     final checkResetCode = checkResetCodeFromJson(jsonString);

import 'dart:convert';

CheckResetCode checkResetCodeFromJson(String str) =>
    CheckResetCode.fromJson(json.decode(str));

String checkResetCodeToJson(CheckResetCode data) => json.encode(data.toJson());

class CheckResetCode {
  CheckResetCode({
    required this.isCorrect,
    required this.allProfiles,
  });

  bool isCorrect;
  List<AllProfile> allProfiles;

  factory CheckResetCode.fromJson(Map<String, dynamic> json) => CheckResetCode(
        isCorrect: json["is_correct"],
        allProfiles: List<AllProfile>.from(
            json["all_profiles"].map((x) => AllProfile.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "is_correct": isCorrect,
        "all_profiles": List<dynamic>.from(allProfiles.map((x) => x.toJson())),
      };
}

class AllProfile {
  AllProfile({
    required this.nickname,
    required this.photo,
    required this.id,
    required this.token,
  });

  String nickname;
  String? photo;
  int id;
  String token;

  factory AllProfile.fromJson(Map<String, dynamic> json) => AllProfile(
        nickname: json["nickname"],
        photo: json["photo"],
        id: json["id"],
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "nickname": nickname,
        "id": id,
        "token": token,
      };
}
