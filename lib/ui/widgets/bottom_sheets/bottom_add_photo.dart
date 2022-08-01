import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/ui/add_post/add_post.dart';

class AddPhotoBottom extends StatefulWidget {
  const AddPhotoBottom({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<AddPhotoBottom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            margin: const EdgeInsets.all(17),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => const AddPostPage(
                            photoType: PhotoType.account,
                          ),
                        ),
                      ).then((value) {
                        Navigator.pop(context, value);
                      });
                    },
                    child: const SizedBox(
                      height: 47,
                      child: Center(
                        child: Text('Новое фото профиля'),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: greyClose.withOpacity(0.21),
                ),
                Material(
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context, 'delete');
                    },
                    child: const SizedBox(
                      height: 47,
                      child: Center(
                        child: Text(
                          'Удалить фото',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 17, right: 17, bottom: 20),
            child: Material(
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const SizedBox(
                  height: 47,
                  child: Center(
                    child: Text(
                      'Отмена',
                      style: TextStyle(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
