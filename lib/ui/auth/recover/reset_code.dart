import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/auth/recover/choose_account.dart';
import 'package:y_storiers/ui/auth/recover/update_pass.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class ResetCodePage extends StatefulWidget {
  final String phone;
  const ResetCodePage({Key? key, required this.phone}) : super(key: key);

  @override
  State<ResetCodePage> createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  final _codeController = TextEditingController();
  final _buttonController = RoundedLoadingButtonController();

  void _checkPhone() async {
    _buttonController.start();
    var result = await Repository().checkResetCode(
        widget.phone.replaceAll('+', ''), int.parse(_codeController.text));

    if (result != null) {
      _buttonController.success();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChooseAccountPage(
            profiles: result,
          ),
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        _buttonController.reset();
      });
    } else {
      _buttonController.error();
      Future.delayed(Duration(seconds: 1), () {
        _buttonController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Введите код, отправленный на указанный номер телефона',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
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
                const SizedBox(height: 20),
                CustomTextField(
                  hint: 'Введите код',
                  search: false,
                  controller: _codeController,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
                  child: AccentButton(
                    controller: _buttonController,
                    onTap: () {
                      _checkPhone();
                    },
                    title: 'Проверить',
                  ),
                )
              ],
            ),
          ),
          SafeArea(
            bottom: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                width: 150,
                height: 22,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      'Вернуться к телефону.',
                      style: TextStyle(
                        fontSize: 12,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
