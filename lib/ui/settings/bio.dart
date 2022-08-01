import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:y_storiers/services/constants.dart';

class BioPage extends StatelessWidget {
  final String description;
  final Function(String text) onChanged;
  BioPage({
    Key? key,
    required this.description,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _description = TextEditingController(text: description);
    final _streamController = StreamController<int>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(_description, context),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide.none,
                    horizontal: BorderSide(
                      color: Colors.black,
                      width: 0.1,
                    ),
                  ),
                ),
                child: TextField(
                    controller: _description,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onChanged: (text) {
                      _streamController.sink.add(text.length);
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(150),
                    ],
                    autofocus: true,
                    decoration: const InputDecoration.collapsed(hintText: '')),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0, right: 20.0),
                  child: StreamBuilder<int>(
                      stream: _streamController.stream,
                      initialData: description.length,
                      builder: (context, snapshot) {
                        return Text((150 - snapshot.data!).toString());
                      }),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  AppBar _appBar(TextEditingController controller, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: const Text(
        'Биография',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            onChanged.call(controller.text);
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
