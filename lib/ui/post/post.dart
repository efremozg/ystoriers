import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/post/widgets/post.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class PostPage extends StatefulWidget {
  final GetPost postId;
  final int index;
  final String nickname;
  const PostPage({
    Key? key,
    required this.postId,
    required this.index,
    required this.nickname,
  }) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  GetPost? post;

  @override
  void didChangeDependencies() {
    // _getPost();
    super.didChangeDependencies();
  }

  // void _getPost() async {
  //   var token = Provider.of<AppData>(context).user.userToken;
  //   var result = await Repository().getPost(widget.postId, token);

  //   if (result != null) {
  //     setState(() {
  //       post = result;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: CustomScrollView(
        slivers: [
          // if (post != null)
          _post()
          // else
          //   SliverToBoxAdapter(
          //       child: Padding(
          //     padding: const EdgeInsets.only(top: 350),
          //     child: CircularProgressIndicator.adaptive(),
          //   )),
        ],
      ),
    );
  }

  Widget _post() {
    return SliverToBoxAdapter(
      child: PostWidget(
        post: widget.postId,
        nickname: widget.nickname,
        main: false,
        play: true,
        onDeleted: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.2,
      title: const Text(
        'Публикация',
        style: TextStyle(fontSize: 14),
      ),
      foregroundColor: Colors.black,
    );
  }
}
