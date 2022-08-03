import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart' as d;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/bloc/user/user_event.dart';
import 'package:y_storiers/services/constants.dart';
import 'package:y_storiers/services/objects/check_name.dart';
import 'package:y_storiers/services/objects/check_reset.dart';
import 'package:y_storiers/services/objects/correct.dart';
import 'package:y_storiers/services/objects/feed.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/get_stories.dart';
import 'package:y_storiers/services/objects/get_users.dart';
import 'package:y_storiers/services/objects/like.dart';
import 'package:y_storiers/services/objects/notification.dart';
import 'package:y_storiers/services/objects/post_answer.dart';
import 'package:y_storiers/services/objects/posts.dart';
import 'package:y_storiers/services/objects/recommended.dart';
import 'package:y_storiers/services/objects/search_chats.dart';
import 'package:y_storiers/services/objects/stories.dart';
import 'package:y_storiers/services/objects/stories_request.dart';
import 'package:y_storiers/services/objects/subscribe.dart';
import 'package:y_storiers/services/objects/success.dart';
import 'package:y_storiers/services/objects/user_created.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/provider/app_data.dart';

class Repository {
  d.Dio dio = d.Dio(
    d.BaseOptions(
      baseUrl: apiUrl,
    ),
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(value)));
  }

  void _showAnswer(int status, String message, BuildContext context) {
    StandartSnackBar.show(
      context,
      message,
      status == 0 ? SnackBarStatus.success() : SnackBarStatus.warning(),
    );
  }

  Future<dynamic> checkAvaibleName(String name) async {
    try {
      d.Response response = await dio.post("users/check_nickname/$name");
      print(response.data);
      return CheckName.fromJson(response.data);
    } catch (e) {
      return false;
    }
  }

  Future<bool?> checkPhone(
      BuildContext context, String name, String phone) async {
    // _removeCertificate();
    d.Response response = await dio.post("users/check_phone_number", data: {
      "nickname": name,
      "phone_number": phone.replaceAll(RegExp(r"[^0-9]+"), ""),
    });

    try {
      return SuccessAnswer.fromJson(response.data).success;
    } catch (e) {
      return null;
    }
  }

  Future<SearchChats?> searchChats(
      BuildContext context, String text, String token) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": '$token'};
    d.Response response = await dio.post("users/chat_search", data: {
      "str": text,
    });
    // print(response.data);

    // try {
    return SearchChats.fromJson(response.data);
    // } catch (e) {
    //   return null;
    // }
  }

  Future<CorrectAnswerCode?> checkCode(String name, String code) async {
    // _removeCertificate();
    d.Response response = await dio.post("users/check_code", data: {
      "nickname": name,
      "code": code,
    });
    print(response.data);

    try {
      return CorrectAnswerCode.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<UserCreatedAnswer?> setPassword(String password, String token) async {
    // _removeCertificate();
    try {
      dio.options.headers = {"Authorization": '$token'};
      d.Response response = await dio.post("users/set_password", data: {
        "password": password,
      });
      return UserCreatedAnswer.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<CorrectAnswer?> authUser(String name, String password) async {
    // _removeCertificate();
    // dio.options.headers = {"Authorization": '$token'};
    d.Response response = await dio.post("users/login", data: {
      "nickname": name,
      "password": password,
    });
    print(response.data);

    try {
      return CorrectAnswer.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Future<CorrectAnswer?> downLoadVideo(String name, String password) async {
  //   _removeCertificate();
  //   // dio.options.headers = {"Authorization": '$token'};
  //   // d.Response response = await dio.download('', savePath)

  //   try {
  //     return CorrectAnswer.fromJson(response.data);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<UserInfo?> getInfo(
      String nickname, String token, BuildContext? context) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": '$token'};

    d.Response response =
        await dio.get("users/get_user_by_str/$nickname").catchError((error) {
      // _showAnswer(1, error.toString(), context!);
    });

    try {
      var user = UserInfo.fromJson(response.data);
      return user;
    } catch (e) {
      if (context != null) {
        // _showAnswer(response.statusCode!, e.toString(), context);
      }
      return UserInfo.fromJson(response.data);
      // print('object');
      // return null;
    }
  }

  Future<UserInfo?> getInfoById(
      String id, String token, BuildContext? context) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": '$token'};

    try {
      d.Response response =
          await dio.get("users/get_user_by_id/$id").catchError((error) {
        print(error);
        _showAnswer(1, error.toString(), context!);
      });
      return UserInfo.fromJson(response.data);
    } catch (e) {
      return null;
      // return UserInfo.fromJson(response.data);
      // print('object');
      // return null;
    }
  }

  Future<EditPhoto?> changePhoto(
    String? photo,
    String token,
  ) async {
    dio.options.headers = {"Authorization": '$token'};

    var changedPhoto = {
      "photo": photo,
    };
    d.Response response =
        await dio.put("users/change_photo", data: changedPhoto);
    print('response is ${response.data}');

    return EditPhoto.fromJson(response.data);
  }

  Future<EditUser?> editInfo(
    String? name,
    String nickname,
    String? description,
    String? email,
    String? gender,
    int? birthday,
    String? photo,
    String token,
    String? phone,
  ) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": '$token'};

    var dataWithPhoto = {
      "full_name": name,
      "nickname": nickname,
      "email": email,
      "description": description,
      "gender": gender,
      "birthday": birthday,
      "photo": photo,
      "phone_number": phone,
    };
    print(dataWithPhoto);

    d.Response response =
        await dio.post("users/edit_profile", data: dataWithPhoto);

    print(response.data);

    // try {
    return EditUser.fromJson(response.data);
    // } catch (e) {
    //   return null;
    // }
  }

  Future<SuccessAnswer?> addStory(
      StroiesRequest stroiesRequest, String token) async {
    dio.options.headers = {"Authorization": "$token"};
    // print(stroiesRequest.media);
    d.Response response =
        await dio.post("stories/add_stories", data: stroiesRequest.toJson());
    // print(response.data);
    try {
      return SuccessAnswer.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<GetStories?> getStories(String nickname) async {
    // _removeCertificate();
    // dio.options.headers = {"Authorization": '$token'};
    d.Response response = await dio.get("stories/$nickname/get_stories");
    // print(response.data);
    try {
      return GetStories.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<PostAnswer?> addPosts(PostRequest postRequest, String token) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": "$token"};
    d.Response response =
        await dio.post("posts/create_post", data: postRequest.toJson());
    // print(response.data);
    try {
      return PostAnswer.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<LikeAnswer?> likePosts(String token, int postId) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("posts/like_post/$postId");
    // print(response.data);
    try {
      return LikeAnswer.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<GetPost?> getPost(int postId, String token) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("posts/post/$postId");
    // print(response.data);
    // try {
    return GetPost.fromJson(response.data);
    // } catch (e) {
    // return null;
    // }
  }

  Future<GetUsers?> searchUsers(String text, String token) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.post("users/search", data: {
      "string": text,
    });
    print(response.data);
    // try {
    return GetUsers.fromJson(response.data);
    // } catch (e) {
    // return null;
    // }
  }

  Future<FeedAnswer?> getFeed(String token, BuildContext context) async {
    // _removeCertificate();
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("posts/feed");
    print(response.data);
    // try {
    // return FeedAnswer.fromJson(response.data);
    // } catch (e) {
    //   _showAnswer(response.statusCode!, e.toString(), context);
    //   return null;
    // }
    try {
      return FeedAnswer.fromJson(response.data);
    } catch (e) {
      _showAnswer(response.statusCode!, e.toString(), context);
      return null;
    }
  }

  Future<List<GetPost>?> getRecomended(String token, int index) async {
    // _removeCertificate();
    print('search index = $index');
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.post("posts/recommended", data: {
      'i': index,
    });
    // print(response.data);
    // return RecommendedAnswer.fromJson(response.data).posts;
    try {
      return RecommendedAnswer.fromJson(response.data).posts;
    } catch (e) {
      return null;
    }
  }

  Future<NotificationAnswer?> getNotification(String token) async {
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("users/notification");
    print(response.data);
    // return RecommendedAnswer.fromJson(response.data).posts;
    // try {
    //   print(')))))');
    return NotificationAnswer.fromJson(response.data);
    // } catch (e) {
    //   print('(((((');
    //   return null;
    // }
  }

  Future<SubscribeAnswer?> subscribe(String userName, String token) async {
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("users/subscribe/$userName");
    // print(response.data);
    try {
      return SubscribeAnswer.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<SubscribeAnswer?> getNotifications(String token) async {
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("users/subs");
    // print(response.data);
    try {
      // print(response.data);
      return SubscribeAnswer.fromJson(response.data);
    } catch (e) {
      // print(e.toString());
      return null;
    }
  }

  Future<SuccessAnswer?> deletePost(String token, int postId) async {
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("posts/delete_post$postId");
    // print(response.data);
    // try {
    return SuccessAnswer.fromJson(response.data);
    // } catch (e) {
    //   return null;
    // }
  }

  Future<SuccessAnswer?> deleteStory(String token, int storyId) async {
    // print(storyId);
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("stories/delete_story$storyId");

    // print(response.data);
    // try {
    return SuccessAnswer.fromJson(response.data);
    // } catch (e) {
    //   return null;
    // }
  }

  Future<SuccessAnswer?> checkStory(String token, int storyId) async {
    print(storyId);
    dio.options.headers = {"Authorization": "$token"};
    d.Response response = await dio.get("stories/story$storyId");
    return (SuccessAnswer.fromJson(response.data));
  }

  Future<SuccessAnswer?> resetPasswordStepOne(
      String token, String phone) async {
    dio.options.headers = {"Authorization": token};
    d.Response response = await dio.post("users/discard_step_1", data: {
      "phone_number": phone,
    });
    return SuccessAnswer.fromJson(response.data);
  }

  Future<List<AllProfile>?> checkResetCode(String phone, int code) async {
    print(phone);
    // _removeCertificate();
    d.Response response = await dio.post("users/discard_step_2", data: {
      "phone_number": phone,
      "code": code,
    });
    print(response.data);

    try {
      if (CheckResetCode.fromJson(response.data).isCorrect) {
        return CheckResetCode.fromJson(response.data).allProfiles;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<SuccessAnswer?> resetPassword(int id, String password) async {
    // _removeCertificate();
    print(password);
    d.Response response = await dio.post("users/discard_step_3", data: {
      "id": id,
      "password": password,
    });

    print(response.data);

    try {
      return SuccessAnswer.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
