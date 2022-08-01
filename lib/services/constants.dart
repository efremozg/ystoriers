import 'package:flutter/material.dart';

//Test
// String apiUrl = 'http://ystories.site:8080/';
//Release
String apiUrl = 'https://ystories.ru/';
String mediaUrl = 'https://ystories.ru';

Color accentColor = const Color.fromARGB(255, 40, 167, 240);

Color greyTextColor = const Color.fromRGBO(158, 158, 158, 1);
Color greyStoriesColor = const Color.fromRGBO(31, 31, 31, 1);
Color greyLineColor = const Color.fromRGBO(218, 218, 218, 1);
Color messageColor = const Color.fromARGB(255, 228, 228, 228);
Color addStoryColor = const Color.fromRGBO(220, 220, 200, 1);
Color greyTextButtonColor = const Color.fromRGBO(111, 111, 111, 1);
Color greyBorderColor = const Color.fromRGBO(203, 203, 203, 1);
Color greyClose = const Color.fromRGBO(196, 196, 196, 1);

String getChatId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$a$b";
  } else {
    return "$b$a";
  }
}
