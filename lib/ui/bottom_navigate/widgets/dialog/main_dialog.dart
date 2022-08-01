import 'package:flutter/material.dart';
import 'package:y_storiers/ui/bottom_navigate/widgets/dialog/main_card.dart';

class MainDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;

  // ignore: use_key_in_widget_constructors
  const MainDialog(
      {required this.title,
      required this.child,
      this.margin = EdgeInsets.zero,
      this.padding = const EdgeInsets.only(left: 7, right: 7)});

  Widget buildTitle() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 10),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(63),
      alignment: Alignment.center,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: MainCard(
          padding: const EdgeInsets.only(bottom: 0),
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 30),
          shadowPadding: const EdgeInsets.only(bottom: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              buildTitle(),
              const SizedBox(height: 10),
              Container(padding: padding, child: child),
              // const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
