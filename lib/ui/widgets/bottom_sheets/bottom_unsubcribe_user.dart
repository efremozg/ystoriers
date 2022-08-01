import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/ui/add_post/edit_post.dart';

class UnsubscribeUserBottom extends StatefulWidget {
  const UnsubscribeUserBottom({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<UnsubscribeUserBottom> {
  ImagePicker _picker = ImagePicker();
  XFile? xFile;

  void _pickImage() async {
    try {
      xFile = await _picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPostPage(xFile: xFile!),
          ),
        );
      }
    } catch (e) {
      throw 'error is $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Container(
            height: 3,
            width: 30,
            decoration: BoxDecoration(
                color: greyClose, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(height: 15),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 1,
            color: greyClose.withOpacity(0.21),
          ),
          ScaleButton(
            duration: const Duration(milliseconds: 150),
            bound: 0.04,
            onTap: () {
              Navigator.pop(context, true);
            },
            child: const ListTile(
              title: Text('Отменить подписку'),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: greyClose.withOpacity(0.21),
          ),
        ],
      ),
    );
  }
}
