import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/dialog/main_dialog.dart';
import 'package:y_storiers/ui/widgets/buttons/accent_button.dart';

class AcceptDialog extends StatelessWidget {
  final String title;
  final String text;
  final String positiveTitle;
  final String negativeTitle;
  final Function onAccept;
  // ignore: use_key_in_widget_constructors
  const AcceptDialog({
    required this.title,
    required this.text,
    required this.onAccept,
    required this.positiveTitle,
    required this.negativeTitle,
  });

  Widget buildImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset('assets/check_ellipse.svg'),
        SvgPicture.asset('assets/check.svg'),
      ],
    );
  }

  Widget buildText() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 13, right: 7, left: 7),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 0.3,
          width: 200,
          color: greyTextColor,
        ),
        const SizedBox(height: 13),
        Material(
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () => onAccept(),
            child: SizedBox(
              height: 30,
              width: 50,
              child: Center(
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget buildButtonCancel(BuildContext context) {
  //   return AccentButton(
  //     onTap: () {
  //       Navigator.pop(context);
  //     },
  //     title: positiveTitle,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MainDialog(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          buildImage(),
          buildText(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 26.5),
              buildButton(context),
              const SizedBox(
                height: 15,
              ),
              // buildButtonCancel(context),
            ],
          ),
        ],
      ),
    );
  }
}
