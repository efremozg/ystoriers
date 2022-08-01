import 'dart:convert';

CheckName checkNameFromJson(String str) => CheckName.fromJson(json.decode(str));

class CheckName {
  CheckName({
    required this.isExist,
    required this.token,
  });

  bool isExist;
  String? token;

  factory CheckName.fromJson(Map<String, dynamic> json) => CheckName(
        isExist: json["exists"],
        token: json["token"],
      );
}
