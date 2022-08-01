import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class EditPostPage extends StatefulWidget {
  const EditPostPage({Key? key, required this.xFile}) : super(key: key);
  final XFile xFile;

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.file(
          File(widget.xFile.path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
