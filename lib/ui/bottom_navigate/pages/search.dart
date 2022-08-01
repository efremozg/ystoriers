import 'dart:async';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scale_button/scale_button.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/get_users.dart';
import 'package:y_storiers/services/objects/user.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/bottom_navigate/pages/account.dart';
import 'package:y_storiers/ui/post/widgets/search_image.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  final streamController = StreamController<bool>();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  var _loading = true;
  var _search = false;
  var _visibleCancel = false;

  static const double loadExtent = 80.0;
  double _oldScrollOffset = 0.0;

  List<GetPost> _posts = [];
  List<AllUser> _users = [];
  int scroll = 0;

  Future<void> _refresh() async {
    return Future.delayed(const Duration(seconds: 2));
  }

  _scrollControllerListener() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.position.pixels;
    final bool scrollingDown = _oldScrollOffset < offset;
    _oldScrollOffset = _scrollController.position.pixels;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final double positiveReloadBorder = max(maxExtent - loadExtent, 0);

    if (((scrollingDown && offset > positiveReloadBorder) ||
        positiveReloadBorder == 0 && !_search)) {
      scroll++;
      if (scroll == 1) {
        print(scroll);
        _getRecommended();
      }
    } else {
      scroll = 0;
    }
  }

  @override
  void initState() {
    _scrollController.addListener(_scrollControllerListener);
    // Timer(Duration(milliseconds: 500), () {
    _getRecommended();
    // });
    print('inited');

    _searchController.addListener(() {
      if (_searchController.text == '') {
        streamController.sink.add(false);
        print('123');
      } else {
        print('456');
        streamController.sink.add(true);
      }
    });

    super.initState();
  }

  void _searchUsers(String text) async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    var result = await Repository().searchUsers(text, token);

    if (result != null) {
      setState(() {
        _users = result.allUsers;
      });
    }
  }

  void _getRecommended() async {
    var token = Provider.of<AppData>(context, listen: false).user.userToken;
    // var result = await Repository().getRecomended(token);

    BlocProvider.of<UserBloc>(context).add(GetRecomended(token: token));

    // if (result != null) {
    //   setState(() {
    //     _posts =
    //         result.where((element) => element.mediaUrl.isNotEmpty).toList();
    //     _loading = false;
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    var searchedUsers =
        Provider.of<AppData>(context).searchedUsers.reversed.toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: BlocBuilder<UserBloc, UserState>(builder: (context, snapshot) {
        var recommended = BlocProvider.of<UserBloc>(context).recommendedPosts;
        if (_posts.isEmpty && recommended.isNotEmpty) {
          _posts = recommended;
          // print(recommended.length);
        }
        return StreamBuilder<bool>(
            stream: streamController.stream,
            initialData: false,
            builder: (context, snapshot) {
              return _posts.isNotEmpty
                  ? CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        if (_search)
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.only(top: 5, bottom: 10),
                              width: double.infinity,
                              height: 1,
                              color: greyClose.withOpacity(0.21),
                            ),
                          ),
                        if (!_search)
                          CupertinoSliverRefreshControl(onRefresh: _refresh),
                        if (!_search)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _postList(index + 1),
                              childCount: _posts.length / 18 < 1
                                  ? 1
                                  : _posts.length ~/ 18,
                            ),
                          ),
                        if (_search && _searchController.text == '')
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(left: 15, bottom: 5),
                              child: Text(
                                'Недавнее',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        if (_search && snapshot.data!)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _chatCard(_users[index], true),
                              childCount: _users.length,
                            ),
                          ),
                        if (_search && !snapshot.data!)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _chatCard(searchedUsers[index], false),
                              childCount: searchedUsers.length,
                            ),
                          ),
                        if (!_search)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          )
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
                    );
            });
      }),
    );
  }

  Widget _chatCard(AllUser user, bool search) {
    return ScaleButton(
      onTap: () {
        Provider.of<AppData>(context, listen: false).updateSearchedUsers(user);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AccountPage(user: UserModel([], user.nickname, '')),
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
                if (user.photo.isEmpty || user.photo.contains('mp4'))
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
                if (user.photo.isNotEmpty && !user.photo.contains('mp4'))
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image(
                      image: NetworkImage(
                        apiUrl + user.photo,
                        headers: {},
                      ),
                      fit: BoxFit.cover,
                      width: 55,
                      height: 55,
                    ),
                  ),
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
                    if (user.fullName != '')
                      SizedBox(
                        height: 17,
                        child: Text(
                          user.fullName,
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
                    onTap: () {
                      Provider.of<AppData>(context, listen: false)
                          .deleteSearchedUser(user);
                    },
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

  Widget _postList(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: StaggeredGrid.count(
        crossAxisCount: 3,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        children: [
          if (_posts.isNotEmpty)
            if (_posts[index * 18 - 18].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 18),
          if (_posts.length > 1)
            if (_posts[index * 18 - 17].mediaUrl.isNotEmpty)
              _picture(2, 2, index, 17),
          if (_posts.length > 2)
            if (_posts[index * 18 - 16].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 16),
          if (_posts.length > 3)
            if (_posts[index * 18 - 15].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 15),
          if (_posts.length > 4)
            if (_posts[index * 18 - 14].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 14),
          if (_posts.length > 5)
            if (_posts[index * 18 - 13].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 13),
          if (_posts.length > 6)
            if (_posts[index * 18 - 12].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 12),
          if (_posts.length > 7)
            if (_posts[index * 18 - 11].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 11),
          if (_posts.length > 8)
            if (_posts[index * 18 - 10].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 10),
          if (_posts.length > 9)
            if (_posts[index * 18 - 9].mediaUrl.isNotEmpty)
              _picture(2, 2, index, 9),
          if (_posts.length > 10)
            if (_posts[index * 18 - 8].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 8),
          if (_posts.length > 11)
            if (_posts[index * 18 - 7].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 7),
          if (_posts.length > 12)
            if (_posts[index * 18 - 6].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 6),
          if (_posts.length > 13)
            if (_posts[index * 18 - 5].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 5),
          if (_posts.length > 14)
            if (_posts[index * 18 - 4].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 4),
          if (_posts.length > 15)
            if (_posts[index * 18 - 3].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 3),
          if (_posts.length > 16)
            if (_posts[index * 18 - 2].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 2),
          if (_posts.length > 17)
            if (_posts[index * 18 - 1].mediaUrl.isNotEmpty)
              _picture(1, 1, index, 1)
        ],
      ),
    );
  }

  Widget _picture(
    int crossAxisCellCount,
    int mainAxisCellCount,
    int index,
    int picutreIndex,
  ) {
    return SearchImage(
      crossAxisCellCount: crossAxisCellCount,
      index: index,
      mainAxisCellCount: mainAxisCellCount,
      picutreIndex: picutreIndex,
      postModel: _posts[index * 18 - picutreIndex],
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              onEnd: () {
                setState(() {
                  // if (_visibleCancel == false) {
                  Timer(Duration(milliseconds: 600), () {
                    _visibleCancel = !_visibleCancel;
                  });
                  // }
                });
              },
              height: 40,
              width: _search
                  ? MediaQuery.of(context).size.width - 110
                  : MediaQuery.of(context).size.width,
              duration: Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: _search ? 40 : 0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200]),
              // width: double.infinity,
              child: Container(
                child: TextField(
                  controller: _searchController,
                  onChanged: (text) {
                    if (text == '') {
                      _users = [];
                      setState(() {});
                    } else {
                      _searchUsers(text);
                    }
                  },
                  // controller: _searchController,
                  onTap: () {
                    setState(() {
                      _search = true;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      _search = false;
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 0,
                    ),
                    prefixIcon: SizedBox(
                      width: 24,
                      child: Align(
                        child: SvgPicture.asset(
                          'assets/page_search.svg',
                          color: const Color.fromRGBO(158, 158, 158, 1),
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: const BorderSide(
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    hintText: 'Поиск',
                  ),
                ),
              ),
            ),
          ),
          // if (_visibleCancel)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _search = false;
                  _searchController.clear();
                });
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: _search ? 60 : 0,
                height: 40,
                child: Center(
                  child: Text(
                    _search ? 'Отмена' : '',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
