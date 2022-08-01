import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:y_storiers/services/constants.dart';

class ChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool parameters;
  final Function() sendMessage;
  const ChatTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.parameters,
    required this.sendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextField(
          onChanged: (text) {},
          controller: controller,
          cursorHeight: 16,
          cursorColor: Theme.of(context).primaryColor,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            contentPadding:
                const EdgeInsets.only(top: 12, right: 100, left: 16),
            filled: true,
            fillColor: messageColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: const BorderSide(
                width: 0,
                style: BorderStyle.none,
              ),
            ),
            hintText: hint,
          ),
        ),
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: Container(
        //     margin: const EdgeInsets.only(left: 3),
        //     width: 32,
        //     height: 32,
        //     decoration: const BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Color.fromRGBO(80, 58, 212, 1),
        //     ),
        //     child: const Icon(
        //       Icons.camera_alt_rounded,
        //       size: 20,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: sendMessage,
            child: Container(
                margin: const EdgeInsets.only(right: 12),
                child: const Text(
                  'Отправить',
                  style: TextStyle(
                    color: Color.fromRGBO(80, 58, 212, 1),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )),
          ),
        ),
      ],
    );
  }
}
