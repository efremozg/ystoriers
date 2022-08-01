import 'package:flutter/material.dart';

class PostPoints extends StatelessWidget {
  const PostPoints({
    Key? key,
    required this.index,
    required this.position,
  }) : super(key: key);

  final int index;
  final int position;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 7,
      width: 7,
      margin: const EdgeInsets.only(left: 2.5, right: 2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: index == position
            ? const Color.fromRGBO(50, 181, 255, 1)
            : const Color.fromRGBO(196, 196, 196, 1),
      ),
    );
  }
}
