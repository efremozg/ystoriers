import 'package:flutter/material.dart';
import 'package:y_storiers/services/objects/get_users.dart';
import 'package:y_storiers/ui/provider/shared.dart';

class User {
  int userId;
  String userToken;
  String nickName;
  User({
    required this.userId,
    required this.userToken,
    required this.nickName,
  });
}

class AppData extends ChangeNotifier {
  AppData(
    this._user,
    this._searchedUsers,
    this.isOpenStories,
  );

  User _user;
  bool isOpenStories;
  List<AllUser> _searchedUsers;

  User get user => _user;
  List<AllUser> get searchedUsers => _searchedUsers;

  static Future<AppData> init() async {
    final prefs = await PrefsHandler.getInstance();

    return AppData(
      prefs.getUser(),
      prefs.getSearchedUsers() != ''
          ? AllUser.decode(prefs.getSearchedUsers())
          : [],
      false,
    );
  }

  void updateSearchedUsers(AllUser allUser) async {
    if (!_searchedUsers.contains(allUser) && _searchedUsers.length <= 10) {
      _searchedUsers.add(allUser);

      (await PrefsHandler.getInstance())
          .setSearchedUsers(AllUser.encode(_searchedUsers));
      notifyListeners();
    }
  }

  void deleteSearchedUser(AllUser allUser) async {
    if (_searchedUsers.contains(allUser)) {
      _searchedUsers.remove(allUser);

      (await PrefsHandler.getInstance())
          .setSearchedUsers(AllUser.encode(_searchedUsers));
      notifyListeners();
    }
  }

  void openStories(bool isOpened) async {
    isOpenStories = isOpened;
    notifyListeners();
  }

  void setUserToken(String token) async {
    _user.userToken = token;
    (await PrefsHandler.getInstance()).setUserToken(token);
    notifyListeners();
  }

  void setUser(User user) async {
    (await PrefsHandler.getInstance()).setUser(user);
    _user = user;
    notifyListeners();
  }

  void setUserId(int userId) async {
    (await PrefsHandler.getInstance()).setUserId(userId);
    _user.userId = userId;
    notifyListeners();
  }

  void setUserNickname(String nickname) async {
    (await PrefsHandler.getInstance()).setUser(User(
        userId: user.userId, userToken: user.userToken, nickName: nickname));
    _user.nickName = nickname;
    notifyListeners();
  }

  void logOut() async {
    (await PrefsHandler.getInstance()).logOut();
    _user = User(userId: 0, userToken: '', nickName: '');
    notifyListeners();
  }
}
