import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/ui/auth/sign_in/login.dart';
import 'package:y_storiers/ui/main/control/main_control.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class Check extends StatefulWidget {
  const Check({Key? key}) : super(key: key);

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
    if (provider.user.userId == 0) {
      return const LoginPage();
    }
    if (provider.user.userId != 0) {
      return const MainPageControl();
    }
    return Container();
  }
}
