import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/auth/sign_in/login.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/dialog/accept_dialog.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/dialog/dialogs.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class UpdatePassPage extends StatefulWidget {
  final int userId;
  const UpdatePassPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<UpdatePassPage> createState() => _UpdatePassPageState();
}

class _UpdatePassPageState extends State<UpdatePassPage> {
  final _newPassword = TextEditingController();
  final _newPasswordSecond = TextEditingController();

  final _buttonController = RoundedLoadingButtonController();

  void _updatePass() async {
    _buttonController.start();
    if (_newPassword.text.isEmpty) {
      StandartSnackBar.show(
        context,
        'Поле новый пароль не заполнено',
        SnackBarStatus.warning(),
      );
      _buttonController.error();

      Future.delayed(const Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    if (_newPasswordSecond.text.isEmpty) {
      StandartSnackBar.show(
        context,
        'Поле повторите пароль не заполнено',
        SnackBarStatus.warning(),
      );
      _buttonController.error();

      Future.delayed(const Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    if (_newPassword.text.length < 9) {
      StandartSnackBar.show(
        context,
        'Должно быть минимум 8 символов',
        SnackBarStatus.warning(),
      );
      _buttonController.error();

      Future.delayed(const Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    if (_newPassword.text != _newPasswordSecond.text) {
      StandartSnackBar.show(
        context,
        'Пароли не совпадают',
        SnackBarStatus.warning(),
      );
      _buttonController.error();

      Future.delayed(const Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    var result =
        await Repository().resetPassword(widget.userId, _newPassword.text);

    if (result != null) {
      if (result.success) {
        _buttonController.success();

        Future.delayed(const Duration(seconds: 1), () {
          _buttonController.reset();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        });
      }
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Введите новый пароль',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: 'Новый пароль',
              search: false,
              password: true,
              controller: _newPassword,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: 'Повторите пароль',
              search: false,
              password: true,
              controller: _newPasswordSecond,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
              child: AccentButton(
                controller: _buttonController,
                onTap: _updatePass,
                title: 'Далее',
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showDialog() {
    Dialogs.showUnmodal(
      context,
      AcceptDialog(
        title: "Пароль восстановлен",
        text: "Теперь вы можете пользоваться вашим аккаунтом",
        onAccept: () {
          Navigator.pop(context);
        },
        positiveTitle: 'Остаться',
        negativeTitle: 'Выйти',
      ),
    );
  }
}
