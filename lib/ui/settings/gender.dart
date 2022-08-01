import 'dart:async';

import 'package:flutter/material.dart';
import 'package:y_storiers/services/constants.dart';

enum Gender {
  male,
  female,
}

class GenderPage extends StatelessWidget {
  final Function(Gender) onChanged;
  Gender gender;
  GenderPage({
    Key? key,
    required this.onChanged,
    required this.gender,
  }) : super(key: key);

  var controller = StreamController<Gender>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: _body(),
    );
  }

  Widget _body() {
    return StreamBuilder<Gender>(
      stream: controller.stream,
      initialData: gender,
      builder: (context, snapshot) => Column(
        children: [
          GestureDetector(
            onTap: () {
              gender = Gender.male;
              controller.sink.add(Gender.male);
            },
            child: ListTile(
              title: const Text('Мужской'),
              trailing: Container(
                height: 25,
                width: 25,
                decoration: snapshot.data! == Gender.male
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 7,
                          color: accentColor,
                        ),
                      )
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.5,
                          color: Colors.grey[300]!,
                        ),
                      ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              gender = Gender.female;
              controller.sink.add(Gender.female);
            },
            child: ListTile(
              title: const Text('Женский'),
              trailing: Container(
                height: 25,
                width: 25,
                decoration: snapshot.data! == Gender.female
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 7,
                          color: accentColor,
                        ),
                      )
                    : BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.5,
                          color: Colors.grey[300]!,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'Выберите пол',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () async {
            onChanged.call(gender);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Готово',
                  style: TextStyle(
                    fontSize: 15,
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
