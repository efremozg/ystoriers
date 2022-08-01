import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/auth/recover/reset_code.dart';
import 'package:y_storiers/ui/auth/sign_in/login.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/dialog/accept_dialog.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/dialog/dialogs.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({Key? key}) : super(key: key);

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  var _code = '+7';
  var _phoneController = TextEditingController();

  void _resetPassword() async {
    _buttonController.start();
    if (_phoneController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        'Телефон не заполнен',
        SnackBarStatus.warning(),
      );
      _buttonController.error();

      Future.delayed(Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    var result = await Repository().resetPasswordStepOne(
      token,
      _code.replaceAll('+', '') + _phoneController.text,
    );
    if (result != null) {
      if (result.success) {
        _buttonController.success();
        Future.delayed(Duration(seconds: 1), () {
          _buttonController.reset();
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetCodePage(
              phone: _code.replaceAll('+', '') + _phoneController.text,
            ),
          ),
        );
        _showDialog();
        _buttonController.error();
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
  }

  final _buttonController = RoundedLoadingButtonController();
  @override
  Widget build(BuildContext context) {
    _buttonController.reset();
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
                const Text(
                  'Не удается выполнить вход?',
                  style: TextStyle(fontSize: 18),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, top: 8),
                  child: const Text(
                    'Введите номер телефона и мы отправим Вам код для восстановления доступа к аккаунту',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
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
                // const CustomTextField(
                //   hint: 'Телефон, имя пользователя или e-mail',
                //   search: false,
                // ),
                CustomTextField(
                  hint: 'Номер телефона',
                  type: TextInputType.phone,
                  controller: _phoneController,
                  search: false,
                  onSelect: (code) {
                    _code = code;
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
                  child: AccentButton(
                    controller: _buttonController,
                    onTap: () {
                      _resetPassword();
                    },
                    title: 'Далее',
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Center(
                    child: Text(
                      'Вернуться к входу.',
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

  void _showDialog() {
    Dialogs.showUnmodal(
      context,
      AcceptDialog(
        title: "Код подтверждения был отправлен на телефон",
        text:
            "Мы отправили код для восстановление доступа к вашему аккаунту на телефон ${_code + _phoneController.text}",
        onAccept: () {
          Navigator.pop(context);
          // Timer(const Duration(seconds: 1), () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       fullscreenDialog: true,
          //       builder: (context) => const UpdatePassPage(),
          //     ),
          //   );
          // });
        },
        positiveTitle: 'Остаться',
        negativeTitle: 'Выйти',
      ),
    );
  }
}
