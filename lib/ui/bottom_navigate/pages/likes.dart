import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/notification.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/post/post.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/subscribers/subscribers.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({Key? key}) : super(key: key);

  @override
  State<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage>
    with AutomaticKeepAliveClientMixin<LikesPage> {
  Future<void> _refresh() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      BlocProvider.of<UserBloc>(context).add(
        GetNotification(
          token: Provider.of<AppData>(context, listen: false).user.userToken,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, snapshot) {
        var notification = BlocProvider.of<UserBloc>(context).notifications;
        print(notification?.sortedNotifMonth.length);
        // print('length ${notification?.sortedNotif.length}');
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _appBar(),
          body: notification != null
              ? CustomScrollView(
                  slivers: [
                    CupertinoSliverRefreshControl(onRefresh: _refresh),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 0.2,
                        width: double.infinity,
                        color: Colors.grey[500],
                      ),
                    ),
                    // _dateText('На этой неделе'),

                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    if (notification.sortedNotifDay.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 15, top: 10, bottom: 10),
                          child: Text(
                            'За сегодня',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (notification.sortedNotifDay.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => notification
                                      .sortedNotifDay[index].type !=
                                  'subscriptions'
                              ? _likeCard(notification.sortedNotifDay[index])
                              : _subscribeCard(
                                  notification.sortedNotifDay[index]),
                          childCount: notification.sortedNotifDay.length,
                        ),
                      ),
                    if (notification.sortedNotifWeek.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          height: 0.1,
                          width: double.infinity,
                          color: Colors.grey[500],
                        ),
                      ),
                    if (notification.sortedNotifWeek.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 15, top: 20, bottom: 10),
                          child: Text(
                            'За неделю',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (notification.sortedNotifWeek.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => notification
                                      .sortedNotifWeek[index].type !=
                                  'subscriptions'
                              ? _likeCard(notification.sortedNotifWeek[index])
                              : _subscribeCard(
                                  notification.sortedNotifWeek[index]),
                          childCount: notification.sortedNotifWeek.length,
                        ),
                      ),
                    if (notification.sortedNotifMonth.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          height: 0.1,
                          width: double.infinity,
                          color: Colors.grey[500],
                        ),
                      ),
                    if (notification.sortedNotifMonth.isNotEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 15, top: 20, bottom: 10),
                          child: Text(
                            'За месяц',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (notification.sortedNotifMonth.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => notification
                                      .sortedNotifMonth[index].type !=
                                  'subscriptions'
                              ? _likeCard(notification.sortedNotifMonth[index])
                              : _subscribeCard(
                                  notification.sortedNotifMonth[index]),
                          childCount: notification.sortedNotifMonth.length,
                        ),
                      ),
                    // const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    // _dateText('За этот месяц'),
                    // const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    // SliverList(
                    //   delegate: SliverChildBuilderDelegate(
                    //     (context, index) => _subscribeCard(),
                    //     childCount: 3,
                    //   ),
                    // ),
                  ],
                )
              : Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: Colors.grey[300]!,
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _likeCard(SortedNotif sortedNotif) {
    // print(sortedNotif.post?.mediaUrl.length);
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.04,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(
              user: UserModel([], sortedNotif.userLikedNickname ?? '', ''),
            ),
          ),
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => PostPage(
        //       postId: sortedNotif.post!.postId,
        //       index: 0,
        //       nickname: sortedNotif.post!.userName,
        //     ),
        //   ),
        // );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, top: 5),
        child: ListTile(
          leading: sortedNotif.userLikedPhoto == null
              ? Container(
                  height: 44,
                  width: 44,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/user.png'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    height: 44,
                    width: 44,
                    // decoration: BoxDecoration(
                    //   image: DecorationImage(
                    //     image:
                    //         NetworkImage(mediaUrl + sortedNotif.userLikedPhoto!),
                    //     fit: BoxFit.cover,
                    //   ),
                    //   shape: BoxShape.circle,
                    // ),
                    child: Image(
                      image: NetworkImage(
                        mediaUrl + sortedNotif.userLikedPhoto!,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          title: Text.rich(
            TextSpan(
              text: sortedNotif.post?.liked.first,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(
                  text: sortedNotif.post!.liked.length > 1
                      ? " и еще ${sortedNotif.post!.liked.length} пользователям понравилась ваша публикация"
                      : " понравилась ваша публикация",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.start,
          ),
          trailing: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Image.network(
              mediaUrl + sortedNotif.post!.mediaUrl.first.media,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _subscribeCard(SortedNotif sortedNotif) {
    // print(sortedNotif.subPhoto);
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.04,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(
              user: UserModel([], sortedNotif.subNickname ?? '', ''),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, top: 5),
        child: ListTile(
          leading: sortedNotif.subPhoto == null
              ? Container(
                  height: 44,
                  width: 44,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/user.png'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                )
              : Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(mediaUrl + sortedNotif.subPhoto!),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
          title: Text.rich(
            TextSpan(
              text: sortedNotif.subNickname,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
              children: const [
                TextSpan(
                  text: " подписался(ась) на ваши обновления.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.start,
          ),
          trailing: ScaleButton(
              duration: const Duration(milliseconds: 150),
              bound: 0.04,
              onTap: () {},
              child: _subscribeButton(sortedNotif)),
        ),
      ),
    );
  }

  Widget _subscribeButton(SortedNotif sortedNotif) {
    return SizedBox(
      height: 25,
      child: !sortedNotif.isInYourSubscriptions
          ? BlueButton(
              onTap: () {
                if (sortedNotif.subNickname != null) {
                  _subscribe(sortedNotif.subNickname!);
                  setState(() {
                    sortedNotif.isInYourSubscriptions =
                        !sortedNotif.isInYourSubscriptions;
                  });
                }
              },
              height: 30,
            )
          : WhiteButton(
              onTap: () {
                if (sortedNotif.subNickname != null) {
                  _subscribe(sortedNotif.subNickname!);
                  setState(() {
                    sortedNotif.isInYourSubscriptions =
                        !sortedNotif.isInYourSubscriptions;
                  });
                }
              },
              title: 'Подписки',
              height: 30,
            ),
    );
  }

  void _subscribe(String nickname) async {
    var user = Provider.of<AppData>(context, listen: false).user;
    // print(userInfo!.nickname);
    var result = await Repository().subscribe(nickname, user.userToken);

    if (result != null) {
      BlocProvider.of<UserBloc>(context).add(
        GetInfo(
          nickname: nickname,
          token: user.userToken,
        ),
      );
    }
  }

  Widget _dateText(String text) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 18, top: 5),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: const Text(
        'Действия',
        style:
            TextStyle(fontSize: 22, color: Colors.black, fontFamily: 'SF UI'),
      ),
      centerTitle: false,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
