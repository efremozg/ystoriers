import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/auth/recover/forget_pass.dart';
import 'package:y_storiers/ui/auth/sign_up/registration.dart';
import 'package:y_storiers/ui/main/control/main_control.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool needPhoneMask = false;
  bool needPhoneRussian = false;

  final _buttonController = RoundedLoadingButtonController();

  @override
  void initState() {
    _nameController.addListener(() {
      if (_nameController.text.contains('+') ||
          _nameController.text.contains('79')) {
        setState(() {
          needPhoneMask = true;
        });
      } else if (_nameController.text.contains('89')) {
        setState(() {
          needPhoneRussian = true;
        });
      } else {
        setState(() {
          needPhoneRussian = false;
          needPhoneMask = false;
        });
      }
    });
    super.initState();
  }

  void _auth() async {
    if (_nameController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        'Имя пользователя не заполнено',
        SnackBarStatus.warning(),
      );
      _buttonController.error();

      Future.delayed(Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      StandartSnackBar.show(
        context,
        'Поле пароль не заполнено',
        SnackBarStatus.warning(),
      );
      _buttonController.error();

      Future.delayed(Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    setState(() {
      _buttonController.start();
    });
    var result = await Repository().authUser(
        _nameController.text.contains('+')
            ? _nameController.text.replaceAll(RegExp(r"[^0-9]+"), '')
            : _nameController.text.contains('89') &&
                    _nameController.text.length == 11
                ? '7' + _nameController.text.substring(1, 11)
                : _nameController.text,
        _passwordController.text);
    if (result != null) {
      if (result.isCorrect) {
        _buttonController.success();
        Provider.of<AppData>(context, listen: false).setUser(
          User(
            userId: result.id!,
            userToken: result.token!,
            nickName: result.nickname!,
          ),
        );
        setState(() {});
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPageControl()),
          (route) => false,
        );
      } else {
        // setState(() {
        StandartSnackBar.show(
          context,
          'Неверный логин или пароль',
          SnackBarStatus.warning(),
        );
        _buttonController.error();

        // });
        Future.delayed(Duration(seconds: 1), () {
          // setState(() {
          _buttonController.reset();
          // });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/1.png',
                    width: 150,
                    height: 30,
                  ),
                  const SizedBox(height: 52),
                  CustomTextField(
                    controller: _nameController,
                    formatters: needPhoneMask
                        ? [
                            TextInputMask(
                                mask: '\\+ 9 (999) 999-99-99', reverse: false),
                          ]
                        : [],
                    hint: 'Телефон, имя пользователя или e-mail',
                    search: false,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: _passwordController,
                    hint: 'Пароль',
                    type: TextInputType.text,
                    password: true,
                    search: false,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 100,
                      height: 22,
                      margin: const EdgeInsets.only(top: 13, right: 15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(5),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: ((context) => ForgetPassPage()),
                            ),
                          );
                        },
                        child: Center(
                          child: Text(
                            'Забыли пароль?',
                            style: TextStyle(
                              fontSize: 12,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: RoundedLoadingButton(
                      onPressed: () => _auth(),
                      borderRadius: 5,
                      elevation: 0,
                      height: 45,
                      errorColor: accentColor,
                      controller: _buttonController,
                      child: const Center(
                        child: Text(
                          'Войти',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),

                    // AccentButton(
                    //     onTap: () {
                    //       _auth();
                    //     },
                    //     title: 'Войти',
                    //   ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: ((context) => RegistrationPage()),
                      ),
                    );
                  },
                  child: Center(
                    child: Text(
                      'Зарегестрироваться.',
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
