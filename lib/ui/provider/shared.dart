import 'package:shared_preferences/shared_preferences.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class PrefsHandler {
  PrefsHandler(this._preferences);

  final SharedPreferences _preferences;

  final String _userId = "user_id";
  final String _userToken = "user_token";
  final String _nickname = "nickname";

  final String _searchedUsers = "users";

  static Future<PrefsHandler> getInstance() async {
    var shared = await SharedPreferences.getInstance();
    return PrefsHandler(shared);
  }

  String getSearchedUsers() {
    return _preferences.getString(_searchedUsers) ?? '';
  }

  void setSearchedUsers(String user) {
    _preferences.setString(_searchedUsers, user);
  }

  User getUser() {
    return User(
      userId: _preferences.getInt(_userId) ?? 0,
      userToken: _preferences.getString(_userToken) ?? '',
      nickName: _preferences.getString(_nickname) ?? '',
    );
  }

  void setUser(User user) {
    _preferences.setInt(_userId, user.userId);
    _preferences.setString(_userToken, user.userToken);
    _preferences.setString(_nickname, user.nickName);
  }

  void setUserId(int userId) {
    _preferences.setInt(_userId, userId);
  }

  void setUserToken(String token) {
    _preferences.setString(_userToken, token);
  }

  void setUserNickname(String nickname) {
    _preferences.setString(_nickname, nickname);
  }

  String getUserToken() {
    return _preferences.getString(_userToken) ?? '';
  }

  void logOut() {
    _preferences.setInt(_userId, 0);
    _preferences.setString(_nickname, '');
    _preferences.setString(_userToken, '');
  }
}
