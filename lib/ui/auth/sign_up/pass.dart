import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/main/control/main_control.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _passController = TextEditingController();
  final _buttonController = RoundedLoadingButtonController();

  void _setPassword() async {
    _buttonController.start();
    if (_passController.text.length < 9) {
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
    var provider = Provider.of<AppData>(context, listen: false);
    var result = await Repository()
        .setPassword(_passController.text, provider.user.userToken);

    if (result != null) {
      if (result.userCreated) {
        _buttonController.success();
        Provider.of<AppData>(context, listen: false).setUserId(result.id);
        // setState(() {});
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPageControl()),
          (route) => false,
        );
      } else {
        _buttonController.error();
        Future.delayed(Duration(seconds: 1), () {
          _buttonController.reset();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
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
              'Придумайте пароль',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              hint: 'Пароль',
              search: false,
              password: true,
              controller: _passController,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
              child: AccentButton(
                controller: _buttonController,
                onTap: () {
                  _setPassword();
                  // provider
                  //     .setUser(User(userId: '1', userToken: '', nickName: ''));
                  // setState(() {});
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const MainPageControl(),
                  //   ),
                  //   (route) => false,
                  // );
                },
                title: 'Далее',
              ),
            )
          ],
        ),
      ),
    );
  }
}
