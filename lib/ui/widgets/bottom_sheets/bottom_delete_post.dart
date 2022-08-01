import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

enum ViewTypeDelete {
  stories,
  post,
}

class DeletePostBottom extends StatefulWidget {
  final Function() onDelete;
  final int? storiesId;
  final ViewTypeDelete viewTypeDelete;
  const DeletePostBottom({
    Key? key,
    required this.onDelete,
    this.storiesId,
    required this.viewTypeDelete,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<DeletePostBottom> {
  void _deleteStories() async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    BlocProvider.of<UserBloc>(context).add(
      DeleteStories(
        storiesId: widget.storiesId!,
        token: token,
      ),
    );
    // widget.onDelete();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
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
            child: Material(
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: widget.viewTypeDelete == ViewTypeDelete.post
                    ? widget.onDelete
                    : _deleteStories,
                child: SizedBox(
                  height: 47,
                  child: Center(
                    child: Text(
                      widget.viewTypeDelete == ViewTypeDelete.post
                          ? 'Удалить пост'
                          : 'Удалить сторис',
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
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
