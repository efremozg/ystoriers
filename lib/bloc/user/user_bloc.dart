import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:y_storiers/bloc/user/user.dart';
import 'package:y_storiers/services/enum/enums.dart';
import 'package:y_storiers/services/objects/feed.dart';
import 'package:y_storiers/services/objects/get_post.dart';
import 'package:y_storiers/services/objects/notification.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/posts.dart';
import 'package:y_storiers/services/objects/stories_request.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/services/repository.dart';
import 'package:y_storiers/ui/add_post/add_post.dart';
import 'package:y_storiers/ui/add_post/widgets/standart_snackbar.dart';
import 'package:y_storiers/ui/main/control/main_control.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/subscribers/subscribers.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserIdle());

  UserInfo? userInfo;
  List<GetPost> posts = [];
  List<StoriesUser> stories = [];
  List<GetPost> recommendedPosts = [];
  bool loadPosts = false;
  NotificationAnswer? notifications;
  String bitmap = '';
  ScrollController? scrollController;
  int searchIndex = 1;

  @override
  Stream<UserState> mapEventToState(
    UserEvent event,
  ) async* {
    if (event is GetInfo) {
      yield UserLoading();
      var result = await Repository()
          .getInfo(event.nickname, event.token, event.context);
      if (result != null) {
        userInfo = result;
        userInfo?.posts = result.posts.reversed.toList();
      }

      yield UserIdle();
    }

    if (event is AddPost) {
      yield PostAddeting();

      print(event.media.first.media);

      Navigator.pop(event.context);

      StandartSnackBar.show(
        event.context,
        'Пост загружается',
        SnackBarStatus.loading(),
      );

      var result = await Repository().addPosts(
        PostRequest(media: event.media, description: ''),
        event.token,
      );

      if (result != null) {
        if (result.postCreated) {
          StandartSnackBar.show(
            event.context,
            'Пост загружен',
            SnackBarStatus.success(),
          );
          userInfo?.posts.insert(0, result.post);
          posts.insert(
              0,
              GetPost(
                  postId: result.post.postId,
                  userPhoto: result.post.userPhoto,
                  userId: result.post.userId,
                  userName: result.post.userName,
                  mediaUrl: result.post.mediaUrl,
                  countOfLikes: result.post.countOfLikes,
                  timestamp: result.post.date,
                  liked: result.post.liked));
          if (event.photoType != PhotoType.stories) {
            // BlocProvider.of<UserBloc>(context).add(Loading(loading: false));
            // Navigator.pop(event.context, result.post);
          } else {
            // BlocProvider.of<UserBloc>(context).add(Loading(loading: false));
            event.onSuccess!();
          }
        }
      } else {
        StandartSnackBar.show(
          event.context,
          'Пост не удалось загрузить',
          SnackBarStatus.warning(),
        );
      }
      yield UserIdle();
    }

    if (event is AddStory) {
      yield StoryAddeting();

      StandartSnackBar.show(
        event.context,
        'История загружается',
        SnackBarStatus.loading(),
      );

      Navigator.pushAndRemoveUntil(
        event.context,
        MaterialPageRoute(
          builder: (context) => MainPageControl(),
        ),
        (route) => false,
      );

      var result = await Repository().addStory(
        StroiesRequest(
          media: event.media,
          reversed: false,
          mediaType: event.mediaType == MediaType.image ? 'image' : 'video',
        ),
        event.token,
      );

      if (result != null) {
        if (result.success) {
          yield StorySuccess();
          StandartSnackBar.show(
            event.context,
            'История загружена',
            SnackBarStatus.success(),
          );
          BlocProvider.of<UserBloc>(event.context).add(
            GetInfo(
              nickname: userInfo!.nickname!,
              token: event.token,
            ),
          );
        }
      } else {
        StandartSnackBar.show(
          event.context,
          'Не удалось загрузить историю',
          SnackBarStatus.warning(),
        );
      }
      yield UserIdle();
    }

    if (event is GetFeed) {
      yield UserLoading();

      var result = await Repository().getFeed(event.token, event.context);

      if (result != null) {
        posts = result.feed;
        stories = result.storiesUsers;
        loadPosts = true;
      } else {
        // StandartSnackBar.show(
        //   event.context,
        //   'error',
        //   1 == 0 ? SnackBarStatus.success() : SnackBarStatus.warning(),
        // );
      }

      yield UserIdle();
    }

    if (event is UpdatePhoto) {
      yield UserLoading();

      StandartSnackBar.show(
        event.context,
        'Фото обновляется',
        SnackBarStatus.loading(),
      );

      var result = await Repository().changePhoto(event.photo, event.token);
      if (result != null) {
        StandartSnackBar.show(
          event.context,
          'Фото обновлено',
          SnackBarStatus.success(),
        );
        Navigator.pop(event.context);
      }
      yield UserIdle();
    }

    if (event is UpdateInfo) {
      yield UserLoading();

      StandartSnackBar.show(
        event.context,
        'Профиль обновляется',
        SnackBarStatus.loading(),
      );
      var result = await Repository().editInfo(
        event.name,
        event.nickname,
        event.description,
        event.email,
        event.gender,
        event.birth,
        event.photo,
        event.token,
        event.phone,
      );

      if (result != null) {
        userInfo = result.user;
        userInfo?.posts = result.user.posts.reversed.toList();
        var nickname =
            Provider.of<AppData>(event.context, listen: false).user.nickName;
        if (nickname != result.user.nickname) {
          Provider.of<AppData>(event.context, listen: false)
              .setUserNickname(result.user.nickname!);
        }
        StandartSnackBar.show(
          event.context,
          'Профиль обновлён',
          SnackBarStatus.success(),
        );
        Navigator.pop(event.context);
      } else {
        StandartSnackBar.show(
          event.context,
          'Профиль не удалось обновить',
          SnackBarStatus.success(),
        );
      }
      yield UserIdle();
    }

    if (event is GetRecomended) {
      yield UserLoading();

      var result = await Repository().getRecomended(event.token, searchIndex);

      if (result != null) {
        if (searchIndex == 0) {
          recommendedPosts = result.reversed.toList();
        } else {
          recommendedPosts.addAll(result.reversed.toList());
        }
      }
      searchIndex++;
      yield UserIdle();
    }

    if (event is GetNotification) {
      yield UserLoading();

      var result = await Repository().getNotification(event.token);

      if (result != null) {
        notifications = result;
      }

      yield UserIdle();
    }

    if (event is Loading) {
      yield UserLoading();

      // var result = await Repository().getNotification(event.token);

      yield UserIdle();
    }

    if (event is DeletePost) {
      yield UserLoading();

      // var result = await Repository().getNotification(event.token);
      posts.removeWhere((element) => element.postId == event.postId);
      userInfo?.posts.removeWhere((element) => element.postId == event.postId);

      yield UserIdle();
    }

    if (event is DeleteStories) {
      yield UserLoading();

      var result = await Repository().deleteStory(event.token, event.storiesId);
      userInfo?.stories.stories.allStories
          .removeWhere((element) => element.id == event.storiesId);

      yield UserIdle();
    }

    if (event is ChangeSubscribers) {
      yield UserLoading();

      if (event.viewType == ViewType.mySubscribers) {
        var subscription = Subscription(
          nickname: event.subscribers.nickname,
          photo: event.subscribers.photo,
          isInYourSubscription: event.subscribers.isInYourSubscription,
          isInYourSubscribers: true,
        );

        if (event.changes == Changes.add) {
          userInfo!.subscriptions.add(subscription);
          userInfo!.subscribers
              .where((element) => element == event.subscribers)
              .first
              .isInYourSubscription = true;
        } else {
          userInfo!.subscriptions.remove(subscription);
          userInfo!.subscribers
              .where((element) => element == event.subscribers)
              .first
              .isInYourSubscription = false;
        }
      }

      yield UserIdle();
    }

    if (event is ChangeSubscriptions) {
      yield UserLoading();

      if (event.viewType == ViewType.subscribers) {
        if (event.changes == Changes.add) {
          userInfo!.subscriptions.add(event.subscription);
          userInfo!.subscribers
              .where((element) => element == event.subscribers)
              .first
              .isInYourSubscription = true;
        } else {
          userInfo!.subscriptions.remove(event.subscription);
          userInfo!.subscribers
              .where((element) => element == event.subscribers)
              .first
              .isInYourSubscription = false;
        }
      } else {
        if (event.subscribers != null) {
          var subscription = Subscription(
            nickname: event.subscribers!.nickname,
            photo: event.subscribers!.photo,
            isInYourSubscription: event.subscribers!.isInYourSubscription,
            isInYourSubscribers: event.subscribers!.isInYourSubscribers,
          );
          if (event.changes == Changes.add) {
            userInfo!.subscriptions.add(subscription);
            userInfo!.subscribers
                .where((element) => element == event.subscribers)
                .first
                .isInYourSubscription = true;
          } else {
            userInfo!.subscriptions.removeWhere(
                (element) => element.nickname == subscription.nickname);
            userInfo!.subscribers
                .where((element) => element == event.subscribers)
                .first
                .isInYourSubscription = false;
          }
        }
      }

      yield UserIdle();
    }
    if (event is LogOut) {
      userInfo = null;
      posts = [];
      stories = [];
      recommendedPosts = [];
      loadPosts = false;
      notifications = null;
    }
  }
}
