import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/bloc/user/user_bloc.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/enum/enums.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

enum ViewType {
  subscribers,
  mySubscribers,
}

class SubscribersPage extends StatefulWidget {
  ViewType viewType;
  UserInfo userInfo;
  Function(UserInfo) onChanged;
  SubscribersPage({
    Key? key,
    this.viewType = ViewType.mySubscribers,
    required this.userInfo,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SubscribersPage> createState() => _SubscribersPageState();
}

class _SubscribersPageState extends State<SubscribersPage> {
  void _subscribe(int index) async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    var result = await Repository()
        .subscribe(widget.userInfo.subscriptions[index].nickname, token);

    if (result != null) {
      BlocProvider.of<UserBloc>(context).add(
        ChangeSubscriptions(
          subscription: widget.userInfo.subscriptions[index],
          subscribers: widget.userInfo.subscribers.firstWhere((element) =>
              element.nickname ==
              widget.userInfo.subscriptions[index].nickname),
          changes: result.subscribe ? Changes.add : Changes.remove,
          viewType: widget.viewType,
        ),
      );
    }
  }

  void _delete(int index) async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    // if (widget.viewType == ViewType.subscribers) {
    //   print('deleted');
    //   BlocProvider.of<UserBloc>(context).add(
    //     ChangeSubscriptions(
    //       subscription: widget.userInfo.subscriptions[index],
    //       changes: Changes.add,
    //       viewType: widget.viewType,
    //     ),
    //   );
    // }
    var result = await Repository()
        .subscribe(widget.userInfo.subscribers[index].nickname, token);

    if (result != null) {
      BlocProvider.of<UserBloc>(context).add(
        ChangeSubscriptions(
          subscription: widget.userInfo.subscriptions[index],
          subscribers: widget.userInfo.subscribers[index],
          changes: result.subscribe ? Changes.add : Changes.remove,
          viewType: widget.viewType,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(builder: (context, snapshot) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(),
        body: _body(),
      );
    });
  }

  CustomScrollView _body() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          flexibleSpace: _topNavigate(),
          toolbarHeight: 61,
          pinned: true,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        if (widget.viewType == ViewType.mySubscribers) _mySubscribers(),
        if (widget.viewType == ViewType.subscribers) _mySubscribes(),
      ],
    );
  }

  Widget _mySubscribers() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _mySubscribersCard(index),
        childCount: widget.userInfo.subscribers.length,
      ),
    );
  }

  Widget _mySubscribes() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _subscribeCard(index),
        childCount: widget.userInfo.subscriptions.length,
      ),
    );
  }

  Widget _subscribeCard(int index) {
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.04,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(
              user: UserModel(
                  [], widget.userInfo.subscriptions[index].nickname, ''),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0, top: 0),
        child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: widget.userInfo.subscriptions[index].photo != null
                  ? !widget.userInfo.subscriptions[index].photo!.contains('mp4')
                      ? Image(
                          image: NetworkImage(
                            apiUrl +
                                widget.userInfo.subscriptions[index].photo!,
                            headers: {},
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
                        )
                  : const Image(
                      image: AssetImage(
                        'assets/user.png',
                      ),
                      fit: BoxFit.cover,
                      width: 55,
                      height: 55,
                    ),
            ),
            title: Text(
              widget.userInfo.subscriptions[index].nickname,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.userInfo.subscriptions[index].nickname,
              style: TextStyle(
                fontSize: 13,
                color: greyTextButtonColor,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: !widget.userInfo.subscriptions[index].isInYourSubscription
                ? BlueButton(onTap: () {
                    _subscribe(index);
                    setState(() {
                      widget.userInfo.subscriptions[index]
                              .isInYourSubscription =
                          !widget.userInfo.subscriptions[index]
                              .isInYourSubscribers;
                    });
                    widget.onChanged(widget.userInfo);
                  })
                : WhiteButton(
                    title: widget.viewType == ViewType.mySubscribers
                        ? 'Подписки'
                        : 'Удалить',
                    onTap: () {
                      _subscribe(index);
                      setState(() {
                        widget.userInfo.subscriptions[index]
                                .isInYourSubscription =
                            !widget.userInfo.subscriptions[index]
                                .isInYourSubscription;
                      });
                      widget.onChanged(widget.userInfo);
                    })
            // : !onTapSubscribes[index]
            //     ? BlueButton(onTap: () {
            //         setState(() {
            //           onTapSubscribes[index] = true;
            //         });
            //       })
            //     : WhiteButton(
            //         title: widget.viewType == ViewType.mySubscribers
            //             ? 'Подписки'
            //             : 'Удалить',
            //         onTap: () {
            //           setState(() {
            //             onTapSubscribes[index] = false;
            //           });
            //         }),
            ),
      ),
    );
  }

  Widget _mySubscribersCard(int index) {
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.04,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountPage(
              user: UserModel(
                [],
                widget.userInfo.subscribers[index].nickname,
                '',
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0, top: 0),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: widget.userInfo.subscribers[index].photo != null
                ? !widget.userInfo.subscribers[index].photo!.contains('mp4')
                    ? Image(
                        image: NetworkImage(
                          apiUrl + widget.userInfo.subscribers[index].photo!,
                          headers: {},
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
                      )
                : const Image(
                    image: AssetImage(
                      'assets/user.png',
                    ),
                    fit: BoxFit.cover,
                    width: 55,
                    height: 55,
                  ),
          ),
          title: Text(
            widget.userInfo.subscribers[index].nickname,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            widget.userInfo.subscribers[index].nickname,
            style: TextStyle(
              fontSize: 13,
              color: greyTextButtonColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: !widget.userInfo.subscribers[index].isInYourSubscription
              ? BlueButton(onTap: () {
                  _delete(index);
                  setState(() {
                    widget.userInfo.subscribers[index].isInYourSubscription =
                        !widget
                            .userInfo.subscribers[index].isInYourSubscription;
                  });
                  widget.onChanged(widget.userInfo);
                })
              : WhiteButton(
                  title: widget.viewType == ViewType.mySubscribers
                      ? 'Подписки'
                      : 'Удалить',
                  onTap: () {
                    _delete(index);
                    setState(() {
                      widget.userInfo.subscribers[index].isInYourSubscription =
                          !widget
                              .userInfo.subscribers[index].isInYourSubscription;
                    });
                    widget.onChanged(widget.userInfo);
                  },
                ),
        ),
      ),
    );
  }

  Widget _padding(double height) {
    return SliverToBoxAdapter(child: SizedBox(height: height));
  }

  Widget _topNavigate() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.viewType = ViewType.mySubscribers;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  height: 60,
                  width: 100,
                  child: Center(
                    child: Text(
                      'Подписчики',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.viewType == ViewType.subscribers
                            ? greyTextButtonColor
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    widget.viewType = ViewType.subscribers;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  height: 60,
                  width: 100,
                  child: Center(
                    child: Text(
                      'Подписки',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.viewType == ViewType.mySubscribers
                            ? greyTextButtonColor
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 0.5,
          // margin: const EdgeInsets.only(top: 5),
          width: MediaQuery.of(context).size.width,
          color: greyLineColor,
        ),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      title: Text(
        widget.userInfo.nickname!,
        style: const TextStyle(
            fontFamily: 'SF UI', fontSize: 22, color: Colors.black),
      ),
    );
  }
}

class WhiteButton extends StatelessWidget {
  const WhiteButton({
    Key? key,
    required this.title,
    this.height,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final double? height;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.04,
      onTap: onTap,
      child: Container(
        width: 105,
        height: height ?? 27,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 0.7, color: greyBorderColor),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontFamily: 'SF UI',
            ),
          ),
        ),
      ),
    );
  }
}

class BlueButton extends StatelessWidget {
  const BlueButton({
    Key? key,
    required this.onTap,
    this.height,
  }) : super(key: key);

  final double? height;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      duration: const Duration(milliseconds: 150),
      bound: 0.04,
      onTap: onTap,
      child: Container(
        width: 105,
        height: height ?? 27,
        decoration: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Center(
          child: Text(
            'Подписаться',
            style: TextStyle(
                color: Colors.white, fontSize: 13, fontFamily: 'SF UI'),
          ),
        ),
      ),
    );
  }
}
