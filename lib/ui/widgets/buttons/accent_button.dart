import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:y_storiers/services/constants.dart';

class AccentButton extends StatelessWidget {
  final Function() onTap;
  final String title;
  final RoundedLoadingButtonController controller;
  const AccentButton({
    Key? key,
    required this.onTap,
    required this.title,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedLoadingButton(
      onPressed: onTap,
      borderRadius: 5,
      elevation: 0,
      height: 45,
      errorColor: accentColor,
      controller: controller,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
