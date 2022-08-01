import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/ui/add_post/add_post.dart';
import 'package:y_storiers/ui/add_post/edit_post.dart';
import 'package:y_storiers/ui/auth/sign_in/login.dart';
import 'package:y_storiers/ui/main/control/stories_control.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/settings/settings.dart';

class LogoutBottom extends StatefulWidget {
  const LogoutBottom({
    Key? key,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<LogoutBottom> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            height: 3,
            width: 30,
            decoration: BoxDecoration(
                color: greyClose, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 15),
          // const Text(
          //   'Выйти',
          //   style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          // ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 1,
            color: greyClose.withOpacity(0.21),
          ),
          ScaleButton(
            duration: const Duration(milliseconds: 150),
            bound: 0.04,
            onTap: () {
              provider.logOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const LoginPage(),
                ),
              ).then((value) => Navigator.pop(context, value));
              BlocProvider.of<UserBloc>(context).add(LogOut());
            },
            child: const ListTile(
              leading: SizedBox(
                height: 25,
                width: 25,
                child: Icon(
                  Icons.logout,
                  color: Colors.black,
                  size: 25,
                ),
              ),
              title: Text('Выйти из аккаунта'),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: greyClose.withOpacity(0.21),
          ),
        ],
      ),
    );
  }
}
