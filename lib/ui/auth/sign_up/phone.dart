import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/auth/sign_in/login.dart';
import 'package:y_storiers/ui/auth/sign_up/code.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class PhonePage extends StatefulWidget {
  final String name;
  const PhonePage({Key? key, required this.name}) : super(key: key);

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _phoneController = TextEditingController();
  final _buttonController = RoundedLoadingButtonController();

  var _code = '+7';

  @override
  void initState() {
    // _phoneController.addListener(() {
    //   if (_phoneController.text.isNotEmpty) {
    //     if (_phoneController.text == '+ 8') {
    //       setState(() {
    //         _phoneController.text = '+ 7';
    //         _phoneController.selection = TextSelection.fromPosition(
    //             TextPosition(offset: _phoneController.text.length));
    //       });
    //     }
    //   }
    // });
    super.initState();
  }

  void _checkPhone() async {
    var result = await Repository()
        .checkPhone(context, widget.name, _code + _phoneController.text);

    if (result == true) {
      _buttonController.success();
      // print('nice');
    } else {
      _buttonController.error();
      // print('oops');
    }
    Future.delayed(Duration(seconds: 1), () {
      _buttonController.reset();
    });
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => CodePage(name: widget.name)));
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
                const Text(
                  'Добавьте номер телефона',
                  style: TextStyle(fontSize: 18),
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
                  hint: 'Номер телефона',
                  search: false,
                  onSelect: (code) {
                    _code = code;
                  },
                  controller: _phoneController,
                  type: TextInputType.phone,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 15, left: 15),
                  child: AccentButton(
                    controller: _buttonController,
                    onTap: () {
                      _checkPhone();
                      // Dialogs.showUnmodal(
                      //   context,
                      //   AcceptDialog(
                      //     title: "Электронное письмо отправленно на почту",
                      //     text:
                      //         "Мы отправили ссылку на восстановление доступа к вашему аккаунту на адрес E-mail.com/ru",
                      //     onAccept: () {
                      //       Navigator.pop(context);
                      //       Timer(const Duration(seconds: 1), () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             fullscreenDialog: true,
                      //             builder: (context) => const UpdatePassPage(),
                      //           ),
                      //         );
                      //       });
                      //     },
                      //     positiveTitle: 'Остаться',
                      //     negativeTitle: 'Выйти',
                      //   ),
                      // );
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
}
