import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/objects/user_info.dart' as info;
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/chat/widgets/custom_text_field.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class ChatPageTest extends StatefulWidget {
  const ChatPageTest({
    Key? key,
    required this.chatId,
    required this.userInfo,
  }) : super(key: key);

  final String chatId;
  final info.UserInfo userInfo;

  @override
  _ChatPageTestState createState() => _ChatPageTestState();
}

class _ChatPageTestState extends State<ChatPageTest> {
  final _messageController = TextEditingController();
  var lastTyping = DateTime.now().millisecond;
  final _timerLength = 800;
  var _typing = false;
  Timer? timer;

  void _updateTyping() {
    if (!_typing) {
      setState(() {
        _typing = true;
        typing(widget.chatId);
      });
    }

    lastTyping = DateTime.now().millisecondsSinceEpoch;
  }

  Stream<List<Message>> messages(String chatId) {
    var query = FirebaseFirestore.instance
        .collection('chats/$chatId/messages')
        .orderBy('createdAt', descending: true);

    return query.snapshots().map(
      (snapshot) {
        return snapshot.docs.fold<List<Message>>([], (previousValue, doc) {
          final data = doc.data();
          data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
          data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

          return [...previousValue, Message.fromJson(data)];
        });
      },
    );
  }

  Stream<List<String>> typings(String chatId) {
    var nickname = Provider.of<AppData>(context, listen: false).user.nickName;
    var query = FirebaseFirestore.instance
        .collection('chats/$chatId/write')
        .where("nickname", isNotEqualTo: nickname);

    return query.snapshots().map(
      (snapshot) {
        return snapshot.docs.fold<List<String>>([], (previousValue, doc) {
          return [...previousValue, doc.data()['name']];
        });
      },
    );
  }

  Future typing(String chatId) async {
    var user = Provider.of<AppData>(context, listen: false).user;
    var name = user.nickName.isNotEmpty ? user.nickName : "Аноним";

    await FirebaseFirestore.instance.collection('chats/$chatId/write').add({
      "nickname": user.nickName,
      "name": name,
      "date": FieldValue.serverTimestamp(),
    });
  }

  Future stopTyping(String chatId) async {
    var nickname = Provider.of<AppData>(context, listen: false).user.nickName;
    // var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    var query = FirebaseFirestore.instance
        .collection('chats/$chatId/write')
        .where("nickname", isEqualTo: nickname);

    query.get().then((value) {
      for (var item in value.docs) {
        item.reference.delete();
      }
    });
  }

  Future updateTyping(String chatId) async {
    var now = DateTime.now().millisecondsSinceEpoch;
    var query = FirebaseFirestore.instance.collection('chats/$chatId/write');

    query.get().then((value) {
      for (var item in value.docs) {
        int date = item['date']?.millisecondsSinceEpoch;

        if ((now - date) > 30000) {
          item.reference.delete();
        }
      }
    });
  }

  Future sendMessage(String chatId, String text) async {
    var appData = Provider.of<AppData>(context, listen: false);
    // var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    var message = Message(
      userName: appData.user.nickName,
      userNickname: appData.user.nickName,
      text: text,
      type: "text",
      createdAt: 0,
      updatedAt: 0,
    ).toJson();
    message['createdAt'] = FieldValue.serverTimestamp();
    message['updatedAt'] = FieldValue.serverTimestamp();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc()
        .set(message);

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      "chatId": chatId,
      "updatedAt": FieldValue.serverTimestamp(),
      "lastMessage": text,
      'lastSenderId': appData.user.userId,
      'lastRecipientId': widget.userInfo.id,
    });

    // await FirebaseFirestore.instance.collection('chats/$chatId/messages').add(
    //       message,
    //     );
  }

  Widget bubleBuilder(Message message) {
    var nickName = Provider.of<AppData>(context, listen: false).user.nickName;
    // var uid = FirebaseAuth.instance.currentUser?.uid ?? "";
    return message.userNickname == nickName
        ? outMessage(message)
        : inMessage(message);
  }

  Widget inMessage(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        widget.userInfo.photo == null
            ? Image.asset(
                'assets/user.png',
                height: 30,
                width: 30,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  mediaUrl + widget.userInfo.photo!,
                  fit: BoxFit.cover,
                  height: 30,
                  width: 30,
                ),
              ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 5, 10),
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 7),
          decoration: BoxDecoration(
            color: messageColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   message.userName.isNotEmpty ? message.userName : "Аноноим",
              //   style: const TextStyle(
              //     fontSize: 13,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              const SizedBox(
                height: 3,
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Text(
                  message.text,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              // Text(
              //   // DateConvert(context).fromUnix(
              //   //   message.createdAt ?? 0,
              //   //   "Hm",
              //   // ),
              //   '',
              //   style: const TextStyle(
              //     fontSize: 11,
              //     color: Colors.grey,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget outMessage(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(5, 5, 10, 10),
          padding: const EdgeInsets.fromLTRB(10, 9, 10, 7),
          decoration: BoxDecoration(
            color: messageColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Text(
                  message.text,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              // Row(
              //   children: [
              //     Text(
              //       // DateConvert(context).fromUnix(
              //       //   message.createdAt ?? 0,
              //       //   "Hm",
              //       // ),
              //       '',
              //       style: const TextStyle(
              //         fontSize: 11,
              //         color: Colors.grey,
              //       ),
              //     ),
              //     const SizedBox(
              //       width: 3,
              //     ),
              //     const Icon(
              //       Icons.check,
              //       color: Colors.blue,
              //       size: 15,
              //     )
              //   ],
              // ),
            ],
          ),
        ),
      ],
    );
  }

  void _getInfo() async {
    // var result = await Repository().getInfo(widget., token)
  }

  @override
  void initState() {
    super.initState();
    if (widget.userInfo == null) {
      _getInfo();
    }

    updateTyping(widget.chatId);
    _messageController.addListener(_updateTyping);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      var typingTimer = DateTime.now().millisecondsSinceEpoch;
      var timeDiff = typingTimer - lastTyping;

      if ((timeDiff >= _timerLength) && _typing) {
        setState(() {
          _typing = false;
          stopTyping(widget.chatId);
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    // stopTyping(widget.chatId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: messages(widget.chatId),
                builder: (context, AsyncSnapshot<List<Message>> data) {
                  if (data.hasData) {
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.only(bottom: 15, top: 15),
                      itemCount: data.data!.length,
                      itemBuilder: (context, index) {
                        return bubleBuilder(data.data![index]);
                      },
                    );
                  } else {
                    return const CupertinoActivityIndicator();
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 90,
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 40, top: 10),
                child: SizedBox(
                  height: 40,
                  child: ChatTextField(
                    sendMessage: () async {
                      if (_messageController.text.isNotEmpty) {
                        sendMessage(
                          widget.chatId,
                          _messageController.text,
                        );
                        setState(() {
                          _messageController.text = '';
                        });
                      }
                    },
                    hint: 'Напишите сообщение...',
                    controller: _messageController,
                    parameters: false,
                  ),
                ),
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.grey.withOpacity(0.1),
            //     borderRadius: const BorderRadius.only(
            //       topLeft: Radius.circular(15),
            //       topRight: Radius.circular(15),
            //     ),
            //   ),
            //   child: SafeArea(
            //     child: Padding(
            //       padding: const EdgeInsets.fromLTRB(15, 5, 0, 5),
            //       child: Row(
            //         children: [
            // Expanded(
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Container(
            //       height: 90,
            //       color: Colors.white,
            //       padding: const EdgeInsets.only(
            //           left: 15, right: 15, bottom: 40, top: 10),
            //       child: SizedBox(
            //         height: 40,
            //         child: ChatTextField(
            //           hint: 'Напишите сообщение...',
            //           controller: TextEditingController(),
            //           parameters: false,
            //         ),
            //       ),
            //     ),
            //   ),
            // )
            // Expanded(
            //   child: TextField(
            //     controller: _messageController,
            //     textCapitalization: TextCapitalization.sentences,
            //     decoration: const InputDecoration(
            //       hintText: "Сообщение",
            //       border: InputBorder.none,
            //       counterText: "",
            //     ),
            //   ),
            // ),
            // IconButton(
            //   onPressed: () async {
            //     sendMessage(
            //       widget.chatId,
            //       _messageController.text,
            //     );
            //     setState(() {
            //       _messageController.text = '';
            //     });
            //   },
            //   icon: Icon(
            //     Icons.send,
            //     color: accentColor,
            //   ),
            // ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
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
            flex: 3,
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
                          user: UserModel([], widget.userInfo.nickname!, ''),
                        ),
                      ),
                    );
                  },
                  child: widget.userInfo.photo == null
                      ? Image.asset(
                          'assets/user.png',
                          height: 30,
                          width: 30,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            mediaUrl + widget.userInfo.photo!,
                            fit: BoxFit.cover,
                            height: 30,
                            width: 30,
                          ),
                        ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountPage(
                          user: UserModel([], widget.userInfo.nickname!, ''),
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 9),
                    child: Text(
                      widget.userInfo.nickname!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.black,
                      ),
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

class Message {
  Message({
    required this.userName,
    required this.userNickname,
    required this.text,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  String userName;
  String userNickname;
  String text;
  String type;
  int? createdAt;
  int? updatedAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      userName: json['userName'] ?? "Аноним",
      userNickname: json['userNickname'],
      text: json['text'],
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userName': userName,
        'userNickname': userNickname,
        'text': text,
        'type': type,
      };
}
