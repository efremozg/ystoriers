import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/check_name.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/auth/sign_up/phone.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _nameController = TextEditingController();
  final _buttonController = RoundedLoadingButtonController();
  bool error = false;

  @override
  void initState() {
    _nameController.addListener(() {
      if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(_nameController.text)) {
        if (_nameController.text != '') {
          setState(() {
            error = true;
          });
        } else {
          if (error) {
            setState(() {
              error = false;
            });
          }
        }
      } else {
        if (error) {
          setState(() {
            error = false;
          });
        }
      }
    });
    super.initState();
  }

  void _checkName() async {
    if (error) {
      StandartSnackBar.show(
        context,
        'Некорректное имя пользователя',
        SnackBarStatus.warning(),
      );
      _buttonController.error();
      Future.delayed(Duration(seconds: 1), () {
        _buttonController.reset();
      });
      return;
    }
    _buttonController.start();
    var provider = Provider.of<AppData>(context, listen: false);
    var result =
        await Repository().checkAvaibleName(_nameController.text.toLowerCase());
    if (result is CheckName) {
      if (result != null) {
        if (result.isExist == false) {
          _buttonController.success();
          provider.setUserNickname(_nameController.text);
          provider.setUserToken(result.token!);
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => PhonePage(
                name: _nameController.text,
              ),
            ),
          );
          Future.delayed(Duration(seconds: 1), () {
            _buttonController.reset();
          });
        } else {
          StandartSnackBar.show(
            context,
            'Никнейм занят',
            SnackBarStatus.warning(),
          );
          _buttonController.error();
          Future.delayed(Duration(seconds: 1), () {
            _buttonController.reset();
          });
        }
      }
    } else {
      StandartSnackBar.show(
        context,
        'Ошибка',
        SnackBarStatus.warning(),
      );
      _buttonController.error();
      Future.delayed(Duration(seconds: 1), () {
        _buttonController.reset();
      });
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
                  'Создание имени пользователя',
                  style: TextStyle(fontSize: 18),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 30, right: 30, top: 8),
                  child: const Text(
                    'Выберите имя пользователя для своего нового аккаунта. Вы сможете изменить его позже. ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  hint: 'Имя пользователя',
                  search: false,
                  controller: _nameController,
                  formatters: [],
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: error ? 50 : 0,
                  width: double.infinity,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 8),
                    child: Text(
                      'В именах пользователей можно использовать только буквы латинского алфавита (a-z, A-Z), цифры, символы, подчеркивания и точки',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
                  child: AccentButton(
                    controller: _buttonController,
                    onTap: () {
                      _checkName();
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
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      'Войти.',
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
