import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/feed.dart';
import 'package:y_storiers/services/objects/search_chats.dart';
import 'package:y_storiers/services/objects/stories.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/chat/pages/test/chat.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/widgets/text_fields/text_field.dart';

class AllChatsPage extends StatefulWidget {
  const AllChatsPage({Key? key, required this.closeChat}) : super(key: key);

  final Function() closeChat;

  @override
  State<AllChatsPage> createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
  final _searchController = TextEditingController();
  final _streamController = StreamController<bool>();

  var loading = true;
  var _search = false;

  List<Chat> _chats = [];
  List<UserInfo> _searchedChats = [];
  List<UserInfo> usersInfo = [];
  SearchChats? _searchChats;
  @override
  void initState() {
    _searchController.addListener(() async {
      var token = Provider.of<AppData>(context, listen: false).user.userToken;
      if (_searchController.text.isNotEmpty) {
        _streamController.sink.add(true);
        var result = await Repository()
            .searchChats(context, _searchController.text, token);
        if (result != null) {
          setState(() {
            _searchChats = result;
            print(_searchedChats.length);
          });
        }
      } else {
        _streamController.sink.add(false);
        setState(() {
          _searchChats = null;
        });
      }
    });
    super.initState();
  }

  final userRef = FirebaseFirestore.instance.collection('chats');

  Stream<List<Chat>> messages() {
    print('im here 1');
    var query = FirebaseFirestore.instance
        .collection('chats')
        .orderBy('updatedAt', descending: true);

    return query.snapshots().map(
      (snapshot) {
        return snapshot.docs.fold<List<Chat>>([], (previousValue, doc) {
          final data = doc.data();

          var chats = [...previousValue, Chat.fromJson(data)];
          // (chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)) as Iterable<Chat>);

          return chats;
        });
      },
    );
  }

  void _getUsers() async {
    var user = Provider.of<AppData>(context, listen: false).user;
    if (_chats.isNotEmpty) {
      _chats.forEach((element) async {
        // print(element.chatId);
        // print(element.chatId.replaceFirst(user.userId.toString(), ''));
        // print(user.userId.toString());
        // var checkChatId = getChatId(
        //   element.chatId.replaceFirst(user.userId.toString(), ''),
        //   user.userId.toString(),
        // );
        // print(element.chatId == checkChatId);
        // print(element.chatId);
        var result = await Repository().getInfoById(
          element.chatId.replaceFirst(user.userId.toString(), ''),
          user.userToken,
          null,
        );
        if (result != null) {
          setState(() {
            // print('object');
            _searchedChats.add(result);
            usersInfo.add(result);
          });
        }
      });
    }
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppData>(context);
    return StreamBuilder<bool>(
        stream: _streamController.stream,
        initialData: false,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: _appBar(),
            body: Column(
              children: [
                _searchWidget(),
                const SizedBox(height: 15),
                if (!snapshot.data!)
                  Expanded(
                    child: StreamBuilder(
                      stream: messages(),
                      builder: (context, AsyncSnapshot<List<Chat>> data) {
                        if (data.hasData) {
                          print('im here 2');
                          var chats = data.data
                              ?.where(
                                (element) =>
                                    element.lastSenderId ==
                                        provider.user.userId ||
                                    element.lastRecipientId ==
                                        provider.user.userId,
                              )
                              .toList();
                          if (loading) {
                            _chats = chats!;
                            _getUsers();
                          }
                          if (usersInfo.isNotEmpty &&
                              !loading &&
                              !snapshot.data!) {
                            return ListView.builder(
                              reverse: false,
                              padding:
                                  const EdgeInsets.only(bottom: 15, top: 15),
                              itemCount: usersInfo.length == _chats.length
                                  ? usersInfo.length
                                  : 0,
                              itemBuilder: (context, index) {
                                return _chatCard(
                                  _chats[index],
                                );
                              },
                            );
                          } else {
                            if (_chats.isEmpty && !snapshot.data!) {
                              return const Padding(
                                padding: const EdgeInsets.only(bottom: 70),
                                child: Center(
                                  child: Text('Чатов пока нет.'),
                                ),
                              );
                            } else {
                              return const CupertinoActivityIndicator();
                            }
                          }
                        } else {
                          return const CupertinoActivityIndicator();
                        }
                      },
                    ),
                  ),
                if (snapshot.data! && _searchChats != null)
                  Expanded(
                      child: CustomScrollView(
                    slivers: [
                      if (_searchChats!.allUsersFromSubscriptions.isNotEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 15, top: 5, bottom: 10),
                            child: Text(
                              'В ваших подписках',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _searchCard(
                              _searchChats!.allUsersFromSubscriptions[index],
                              false),
                          childCount:
                              _searchChats!.allUsersFromSubscriptions.length,
                        ),
                      ),
                      if (_searchChats!.allUsers.isNotEmpty)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                EdgeInsets.only(left: 15, top: 5, bottom: 10),
                            child: Text(
                              'Рекомендации',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _searchCard(_searchChats!.allUsers[index], false),
                          childCount: _searchChats!.allUsers.length,
                        ),
                      ),
                    ],
                  )),
              ],
            ),
          );
        });
  }

  AppBar _appBar() {
    var provider = Provider.of<AppData>(context);
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 250,
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.closeChat,
                  child: const Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 9),
                  child: Text(
                    provider.user.nickName,
                    style: const TextStyle(
                        fontFamily: 'SF UI', fontSize: 22, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          // SizedBox(
          //   width: 100,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       SvgPicture.asset(
          //         'assets/add.svg',
          //         width: 27,
          //         height: 27,
          //       ),
          //       GestureDetector(
          //         onTap: () {},
          //         child: Container(
          //           width: 14,
          //           height: 3,
          //           margin: const EdgeInsets.only(left: 20, right: 5),
          //           child: SvgPicture.asset(
          //             'assets/more.svg',
          //             width: 25,
          //             height: 25,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _searchCard(AllUser user, bool search) {
    var userId = Provider.of<AppData>(context, listen: false).user.userId;
    return ScaleButton(
      onTap: () {
        // Provider.of<AppData>(context, listen: false).updateSearchedUsers(user);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPageTest(
              chatId: getChatId(
                user.id.toString(),
                userId.toString(),
              ),
              userInfo: UserInfo(
                  id: user.id,
                  nickname: user.nickname,
                  phoneNumber: '',
                  email: '',
                  isAdmin: false,
                  isPhoneConfirmed: true,
                  fullName: '',
                  description: '',
                  gender: '',
                  birthday: 0,
                  photo: user.photo,
                  posts: [],
                  stories: StoriesUser(
                      id: 0,
                      nickname: '',
                      avatar: '',
                      stories: StoriesAnswer(
                          nickname: '',
                          photo: '',
                          allStories: [],
                          index: 0,
                          isFullViewed: false)),
                  subscribers: [],
                  subscriptions: [],
                  isInYourSubscription: false,
                  isInYourSubscribers: false),
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 150),
      bound: 0.05,
      child: Container(
        color: Colors.white,
        height: 70,
        width: double.infinity,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 15),
                if (user.photo != null)
                  if (user.photo!.isEmpty || user.photo!.contains('mp4'))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: const Image(
                        image: AssetImage(
                          'assets/user.png',
                        ),
                        fit: BoxFit.cover,
                        width: 55,
                        height: 55,
                      ),
                    )
                  else
                    Container()
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: const Image(
                      image: AssetImage(
                        'assets/user.png',
                      ),
                      fit: BoxFit.cover,
                      width: 55,
                      height: 55,
                    ),
                  ),
                // Image.asset(
                //   'assets/account.png',
                //   height: 55,
                //   width: 55,
                // ),
                if (user.photo != null)
                  if (user.photo!.isNotEmpty && !user.photo!.contains('mp4'))
                    ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: apiUrl + user.photo!,
                          fit: BoxFit.cover,
                          width: 55,
                          height: 55,
                        )),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 17,
                      child: Text(
                        user.nickname,
                        style:
                            const TextStyle(fontFamily: 'SF UI', fontSize: 14),
                      ),
                    ),
                    if (user.name != null)
                      SizedBox(
                        height: 17,
                        child: Text(
                          user.name!,
                          style: TextStyle(
                            fontSize: 13,
                            color: greyTextButtonColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                  ],
                )
              ],
            ),
            if (!search)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.close,
                      size: 18,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _searchWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: CustomTextField(
        onTap: () {},
        hint: 'Поиск',
        search: true,
        controller: _searchController,
      ),
    );
  }

  Widget _chatCard(Chat chat) {
    var provider = Provider.of<AppData>(context);
    var info = usersInfo.isNotEmpty
        ? usersInfo.firstWhere(
            (element) =>
                element.id.toString() ==
                chat.chatId.replaceFirst(
                  provider.user.userId.toString(),
                  '',
                ),
          )
        : null;
    if (info != null) {
      return ScaleButton(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPageTest(
                chatId: chat.chatId,
                userInfo: info,
              ),
            ),
          );
        },
        duration: const Duration(milliseconds: 150),
        bound: 0.05,
        child: Container(
          color: Colors.white,
          height: 80,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 15),
              _getImage(info.photo),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 17,
                    child: Text(
                      info.nickname ?? '',
                      style: const TextStyle(fontFamily: 'SF UI', fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: 17,
                    child: Text(chat.lastMessage,
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _getImage(String? photo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: photo != null
          ? !photo.contains('mp4')
              ? CachedNetworkImage(
                  imageUrl: mediaUrl + photo,
                  fit: BoxFit.cover,
                  width: 55,
                  height: 55,
                )
              : const Image(
                  image: AssetImage(
                    'assets/user.png',
                  ),
                  fit: BoxFit.cover,
                  width: 55,
                  height: 55,
                )
          : const Image(
              image: AssetImage(
                'assets/user.png',
              ),
              fit: BoxFit.cover,
              width: 55,
              height: 55,
            ),
    );
  }
}

class Chat {
  String chatId;
  String lastMessage;
  String updatedAt;
  int lastSenderId;
  int lastRecipientId;

  Chat({
    required this.chatId,
    required this.lastMessage,
    required this.updatedAt,
    required this.lastSenderId,
    required this.lastRecipientId,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        chatId: json['chatId'],
        lastMessage: json['lastMessage'],
        updatedAt: json['lastMessage'],
        lastRecipientId: json['lastRecipientId'],
        lastSenderId: json['lastSenderId'],
      );
}
