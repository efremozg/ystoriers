import 'dart:convert';
import 'dart:io';

import 'package:easy_mask/easy_mask.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/settings/bio.dart';
import 'package:y_storiers/ui/settings/gender.dart';
import 'package:y_storiers/ui/widgets/bottom_sheets/bottom_add_photo.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  String _birthday = '';

  DateTime? _chosenDateTime;

  String _image = '';
  String _imageUrl = '';

  @override
  void initState() {
    _getInfo();
    super.initState();
  }

  void _getInfo() async {
    var result = BlocProvider.of<UserBloc>(context).userInfo;

    if (result != null) {
      print(result.birthday);
      setState(
        () {
          _nameController.text = result.fullName ?? '';
          _nicknameController.text = result.nickname ?? '';
          _phoneController.text = '+${getFormatPhone(result.phoneNumber)}';
          _descriptionController.text = result.description ?? '';
          _emailController.text = result.email ?? '';
          _genderController.text = result.gender != null
              ? result.gender == 'male'
                  ? 'Мужской'
                  : 'Женский'
              : '';
          // if (result.birthday != null) {
          //   _birthdayController.text = result.birthday.toString();
          // } else {
          _birthday = _getBirhdayDate(
            result.birthday != null ? result.birthday.toString() : null,
          );
          // .toString().substring(0, 4) +
          //     '-' +
          //     result.birthday.toString().substring(4, 6) +
          //     '-' +
          //     result.birthday.toString().substring(6, 8);
          // }
          if (result.photo != null) {
            _imageUrl = result.photo!;
          }
        },
      );
    }
  }

  String getFormatPhone(String? phone) {
    if (phone != null && phone.length > 9) {
      return phone.substring(0, 1) +
          ' (' +
          phone.substring(1, 4) +
          ') ' +
          phone.substring(4, 7) +
          '-' +
          phone.substring(7, 9) +
          '-' +
          phone.substring(9, 11);
    } else {
      return '';
    }
  }

  String _getBirhdayDate(String? date) {
    if (date != null && date.length == 8) {
      return date.substring(0, 4) +
          '/' +
          date.substring(4, 6) +
          '/' +
          date.substring(6, 8);
    } else {
      return '';
    }
  }

  void _updateInfo() async {
    if (_emailController.text.isNotEmpty) {
      if (!_emailController.text.contains('@') ||
          !_emailController.text.contains('.')) {
        StandartSnackBar.show(
          context,
          'Неправильно указан E-Mail',
          SnackBarStatus.warning(),
        );
        return;
      }
    }
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    print(_nameController.text);
    BlocProvider.of<UserBloc>(context).add(
      UpdateInfo(
        name: _nameController.text != '' ? _nameController.text : null,
        email: _emailController.text != '' ? _emailController.text : null,
        nickname: _nicknameController.text.toLowerCase(),
        description: _descriptionController.text != ''
            ? _descriptionController.text
            : null,
        gender: _genderController.text == ''
            ? null
            : _genderController.text == 'Мужской'
                ? 'male'
                : 'female',
        birth: _birthday.isNotEmpty
            ? _birthday.contains('/')
                ? int.parse(_birthday.replaceAll('/', ''))
                : int.parse(_birthday.replaceAll('-', ''))
            : null,
        photo: _image != '' ? 'data:image/jpeg;base64,' + _image : 'photo',
        token: token,
        phone: _phoneController.text != '' ? _phoneController.text : null,
        context: context,
      ),
    );
    // var result = await Repository().editInfo(
    //   _nameController.text,
    //   _nicknameController.text,
    //   _descriptionController.text,
    //   _genderController.text,
    //   11111111,
    //   _image != '' ? 'data:image/jpeg;base64,' + _image : null,
    //   token,
    // );

    // if (result != null) {
    //   Navigator.pop(context, result.user);
  }

  void _setImage(File image) async {
    try {
      var bytes = await image.readAsBytes();

      setState(() {
        _image = base64Encode(bytes);
      });
    } on PlatformException catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, snapshot) {
      // var loading = BlocProvider.of<UserBloc>(context).networkLoading;
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _appBar(context),
                _topImage(context),
                _editInfo(),
                _paddingBottom(),
              ],
            ),
            // if (loading)
          ],
        ),
      );
    });
  }

  SliverToBoxAdapter _paddingBottom() {
    return const SliverToBoxAdapter(child: SizedBox(height: 40));
  }

  SliverToBoxAdapter _editInfo() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _infoCard('Имя', _nameController),
          _infoCard('Имя пользователя', _nicknameController),
          _infoCard('О себе', _descriptionController, clickable: false),
          _infoCard('E-Mail', _emailController),
          _infoCard('Телефон', _phoneController, phone: true, clickable: false),
          _infoCard('Пол', _genderController, clickable: false),
          _infoCard('День рождения', null, clickable: false),
        ],
      ),
    );
  }

  Widget _infoCard(String leading, TextEditingController? controller,
      {bool? clickable, bool? phone}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.only(right: 50),
      child: ListTile(
        leading: SizedBox(
          width: 87,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              leading,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
        title: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (clickable != null &&
                    phone == null &&
                    leading == 'День рождения') {
                  _showTime();
                } else if (leading == 'О себе') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BioPage(
                          description: _descriptionController.text,
                          onChanged: (text) {
                            setState(() {
                              _descriptionController.text = text;
                            });
                          }),
                    ),
                  );
                } else if (leading == 'Пол') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GenderPage(
                        gender: _genderController.text != ''
                            ? _genderController.text == 'Мужской'
                                ? Gender.male
                                : Gender.female
                            : Gender.male,
                        onChanged: (gender) {
                          _genderController.text =
                              gender == Gender.male ? 'Мужской' : 'Женский';
                        },
                      ),
                    ),
                  );
                }
              },
              child: controller != null
                  ? TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 14),
                      enabled: clickable,
                      // maxLines: 10,
                      scrollPhysics: const BouncingScrollPhysics(),
                      inputFormatters: [
                        if (leading == 'О себе')
                          LengthLimitingTextInputFormatter(150),
                        if (leading == 'Телефон')
                          TextInputMask(
                            mask: '\\+ 7 (999) 999-99-99',
                            reverse: false,
                          ),
                      ],
                      decoration: InputDecoration(
                        focusColor: Colors.grey,
                        hintText: leading,
                        border: const UnderlineInputBorder(
                            borderSide: BorderSide.none),
                        hintStyle: const TextStyle(fontSize: 14),
                      ),
                    )
                  : Container(
                      height: 45,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _birthday != '' ? _getDate(_birthday) : 'День рождения',
                        style: TextStyle(
                            color: _birthday != '' ? Colors.black : Colors.grey,
                            fontSize: 14),
                      ),
                    ),
            ),
            Container(
              width: double.infinity,
              height: 0.1,
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  String _getDate(String date) {
    print(date.substring(5, 7));
    switch (date.substring(5, 7)) {
      case '01':
        return date.substring(8, 10) +
            ' января ' +
            date.substring(0, 4) +
            ' г.';
      case '02':
        return date.substring(8, 10) +
            ' февраля ' +
            date.substring(0, 4) +
            ' г.';
      case '03':
        return date.substring(8, 10) + ' марта ' + date.substring(0, 4) + ' г.';
      case '04':
        return date.substring(8, 10) +
            ' апреля ' +
            date.substring(0, 4) +
            ' г.';
      case '05':
        return date.substring(8, 10) + ' мая ' + date.substring(0, 4) + ' г.';
      case '06':
        return date.substring(8, 10) + ' июня ' + date.substring(0, 4) + ' г.';
      case '07':
        return date.substring(8, 10) + ' июля ' + date.substring(0, 4) + ' г.';
      case '08':
        return date.substring(8, 10) +
            ' августа ' +
            date.substring(0, 4) +
            ' г.';
      case '09':
        return date.substring(8, 10) +
            ' сентября ' +
            date.substring(0, 4) +
            ' г.';
      case '10':
        return date.substring(8, 10) +
            ' октября ' +
            date.substring(0, 4) +
            ' г.';
      case '11':
        return date.substring(8, 10) +
            ' ноября ' +
            date.substring(0, 4) +
            ' г.';
      case '12':
        return date.substring(8, 10) +
            ' декабря ' +
            date.substring(0, 4) +
            ' г.';
    }
    return date;
  }

  SliverToBoxAdapter _topImage(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleButton(
            duration: const Duration(milliseconds: 150),
            bound: 0.05,
            onTap: () => _showBottomSheet(),
            child: SizedBox(
              height: 90,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: _image == ''
                        ? _imageUrl == ''
                            ? Image.asset(
                                'assets/user.png',
                                fit: BoxFit.cover,
                              )
                            : Image(
                                image: NetworkImage(
                                  mediaUrl + _imageUrl,
                                  headers: {},
                                ),
                                fit: BoxFit.cover,
                              )
                        : Image.memory(
                            base64Decode(_image),
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => _showBottomSheet(),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Изменить фото профиля',
                style: TextStyle(color: greyTextColor),
              ),
            ),
          )
        ],
      ),
    );
  }

  SliverAppBar _appBar(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leadingWidth: 70,
      pinned: true,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(left: 14, top: 5, right: 0, bottom: 5),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        'Редактировать профиль',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            _updateInfo();
          },
          child: Container(
            color: Colors.transparent,
            padding:
                const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 14),
            child: const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Готово',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return AddPhotoBottom();
        }).then((value) {
      if (value is File) {
        _setImage(value);
      }
      if (value is String) {
        if (value == 'delete') {
          setState(() {
            _image = '';
            _imageUrl = '';
          });
        }
      }
    });
  }

  void _showTime() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 450,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              height: 380,
              child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  use24hFormat: true,
                  initialDateTime: _birthday.isNotEmpty
                      ? DateTime(
                          int.parse(
                            _birthday.substring(0, 4),
                          ),
                          int.parse(
                            _birthday.substring(5, 7),
                          ),
                          int.parse(
                            _birthday.substring(8, 10),
                          ),
                        )
                      : DateTime.now(),
                  onDateTimeChanged: (val) {
                    // print(val);
                    setState(() {
                      // _chosenDateTime = val;
                      _birthday =
                          val.toString().substring(0, 11).replaceAll('-', '/');
                    });
                  }),
            ),
            Material(
              color: Colors.white,
              child: Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    if (_birthday == '') {
                      setState(() {
                        _birthday = DateTime.now().toString().substring(0, 11);
                      });
                    }
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Готово',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
