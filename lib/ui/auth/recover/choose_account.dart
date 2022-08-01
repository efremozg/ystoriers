import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/check_reset.dart';
import 'package:y_storiers/services/objects/get_users.dart';
import 'package:y_storiers/ui/auth/recover/update_pass.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class ChooseAccountPage extends StatefulWidget {
  final List<AllProfile> profiles;
  const ChooseAccountPage({
    Key? key,
    required this.profiles,
  }) : super(key: key);

  @override
  State<ChooseAccountPage> createState() => _ChooseAccountPageState();
}

class _ChooseAccountPageState extends State<ChooseAccountPage> {
  final _codeController = TextEditingController();
  final _buttonController = RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Выберите аккаунт, у которого хотите изменить пароль',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.only(left: 30, right: 30, top: 8),
          //   child: const Text(
          //     'Введите имя пользователя или электронный адрес и мы отправим вам ссылку для восстановления доступа к аккаунту',
          //     style: TextStyle(fontSize: 12, color: Colors.grey),
          //     textAlign: TextAlign.center,
          //   ),
          // ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _chatCard(index),
              childCount: widget.profiles.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatCard(int index) {
    return ScaleButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdatePassPage(
              userId: widget.profiles[index].id,
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 150),
      bound: 0.05,
      child: Container(
        color: Colors.white,
        height: 70,
        width: double.infinity,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 15),
                if (widget.profiles[index].photo == null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: const Image(
                      image: AssetImage(
                        'assets/user.png',
                      ),
                      fit: BoxFit.cover,
                      width: 55,
                      height: 55,
                    ),
                  )
                // Image.asset(
                //   'assets/account.png',
                //   height: 55,
                //   width: 55,
                // ),
                else if (widget.profiles[index].photo!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image(
                      image: NetworkImage(
                        apiUrl + widget.profiles[index].photo!,
                        headers: {},
                      ),
                      fit: BoxFit.cover,
                      width: 55,
                      height: 55,
                    ),
                  ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 17,
                      child: Text(
                        widget.profiles[index].nickname,
                        style:
                            const TextStyle(fontFamily: 'SF UI', fontSize: 14),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
