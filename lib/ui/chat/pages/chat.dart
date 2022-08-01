import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/chat/models/message.dart';
import 'package:y_storiers/ui/chat/widgets/custom_text_field.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [
    Message(
        userId: '1', id: 1, text: 'hello', time: DateTime.now(), user: true),
    Message(
        userId: '2', id: 1, text: 'hello', time: DateTime.now(), user: false),
    Message(
      userId: '1',
      id: 1,
      text: 'how are u?',
      time: DateTime.now(),
      user: true,
    ),
    Message(
      userId: '2',
      id: 1,
      text: 'i am fine, thank you, and how are u?',
      time: DateTime.now(),
      user: true,
    ),
    Message(
      userId: '1',
      id: 1,
      text: 'i am fine too',
      time: DateTime.now(),
      user: false,
    ),
    Message(
        userId: '1', id: 1, text: 'hello', time: DateTime.now(), user: true),
    Message(
        userId: '2', id: 1, text: 'hello', time: DateTime.now(), user: false),
    Message(
        userId: '1', id: 1, text: 'hello', time: DateTime.now(), user: true),
    Message(
        userId: '2', id: 1, text: 'hello', time: DateTime.now(), user: false),
    Message(
        userId: '1', id: 1, text: 'hello', time: DateTime.now(), user: true),
    Message(
        userId: '2', id: 1, text: 'hello', time: DateTime.now(), user: false),
    Message(
        userId: '1', id: 1, text: 'hello', time: DateTime.now(), user: true),
    Message(
        userId: '2', id: 1, text: 'hello', time: DateTime.now(), user: false),
    Message(
        userId: '1', id: 1, text: 'hello', time: DateTime.now(), user: true),
    Message(
        userId: '2', id: 1, text: 'hello', time: DateTime.now(), user: false),
  ];
  // var _isLoad = false;

  ScrollController _scrollController = ScrollController();
  @override
  void didChangeDependencies() {
    if (_scrollController != null) {
      // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    Timer(const Duration(milliseconds: 50), (() {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1), curve: Curves.ease);
    }));
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: Colors.white,
      body: _body(),
    );
  }

  Widget _body() {
    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            _chat(),
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            )
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 90,
            color: Colors.white,
            padding:
                const EdgeInsets.only(left: 15, right: 15, bottom: 40, top: 10),
            child: SizedBox(
              height: 40,
              child: ChatTextField(
                sendMessage: () {},
                hint: 'Напишите сообщение...',
                controller: TextEditingController(),
                parameters: false,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _chat() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) =>
            _message(_messages[index].text, _messages[index].user),
        childCount: _messages.length,
      ),
    );
  }

  Widget _message(String text, bool user) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      child: Row(
        mainAxisAlignment:
            user ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!user)
            Image.asset(
              'assets/account.png',
              height: 30,
              width: 30,
            ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            decoration: BoxDecoration(
              color: messageColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountPage(
                          user: UserModel([], 'username', ''),
                        ),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/account.png',
                    height: 30,
                    width: 30,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountPage(
                          user: UserModel([], 'username', ''),
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 9),
                    child: Text(
                      'username',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 14,
                  height: 3,
                  margin: const EdgeInsets.only(left: 20, right: 5),
                  child: SvgPicture.asset(
                    'assets/more.svg',
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
