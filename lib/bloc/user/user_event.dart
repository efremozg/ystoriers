import 'package:flutter/material.dart';
import 'package:y_storiers/services/enum/enums.dart';
import 'package:y_storiers/services/objects/post.dart';
import 'package:y_storiers/services/objects/post_answer.dart';
import 'package:y_storiers/services/objects/posts.dart';
import 'package:y_storiers/services/objects/stories_request.dart';
import 'package:y_storiers/services/objects/user_info.dart';
import 'package:y_storiers/ui/add_post/add_post.dart';
import 'package:y_storiers/ui/provider/app_data.dart';
import 'package:y_storiers/ui/subscribers/subscribers.dart';

abstract class UserEvent {}

class GetInfo extends UserEvent {
  final String nickname;
  final String token;
  BuildContext? context;

  GetInfo({
    required this.nickname,
    required this.token,
    this.context,
  });
}

class UpdatePhoto extends UserEvent {
  final String nickname;
  final String? photo;
  final String token;
  final BuildContext context;

  UpdatePhoto(
      {required this.context,
      required this.nickname,
      required this.photo,
      required this.token});
}

class UpdateInfo extends UserEvent {
  final String? name;
  final String nickname;
  final String? description;
  final String? gender;
  final String? email;
  final int? birth;
  final String? photo;
  final String? phone;
  final String token;
  final BuildContext context;

  UpdateInfo({
    required this.name,
    required this.nickname,
    required this.description,
    required this.email,
    required this.gender,
    required this.birth,
    required this.photo,
    required this.token,
    required this.phone,
    required this.context,
  });
}

class AddPost extends UserEvent {
  final List<Media> media;
  final String token;
  final BuildContext context;
  final PhotoType photoType;
  final Function()? onSuccess;

  AddPost({
    required this.media,
    required this.token,
    required this.context,
    required this.photoType,
    required this.onSuccess,
  });
}

class AddStory extends UserEvent {
  final BuildContext context;
  final MediaType mediaType;
  final String media;

  final String token;

  AddStory({
    required this.mediaType,
    required this.token,
    required this.context,
    required this.media,
  });
}

class GetRecomended extends UserEvent {
  final String token;

  GetRecomended({
    required this.token,
  });
}

class GetFeed extends UserEvent {
  final String token;
  final BuildContext context;

  GetFeed({required this.token, required this.context});
}

class GetNotification extends UserEvent {
  final String token;

  GetNotification({
    required this.token,
  });
}

class Loading extends UserEvent {
  final bool loading;

  Loading({
    required this.loading,
  });
}

class DeletePost extends UserEvent {
  final int postId;

  DeletePost({
    required this.postId,
  });
}

class DeleteStories extends UserEvent {
  final int storiesId;
  final String token;

  DeleteStories({
    required this.storiesId,
    required this.token,
  });
}

class ChangeSubscribers extends UserEvent {
  final Subscribers subscribers;
  final Subscription subscription;
  final Changes changes;
  final ViewType viewType;

  ChangeSubscribers({
    required this.subscribers,
    required this.subscription,
    required this.changes,
    required this.viewType,
  });
}

class ChangeSubscriptions extends UserEvent {
  final Subscription subscription;
  final Subscribers? subscribers;
  final Changes changes;
  final ViewType viewType;

  ChangeSubscriptions({
    required this.subscription,
    this.subscribers,
    required this.changes,
    required this.viewType,
  });
}

// class CheckStory extends UserEvent {
//   final String token;
//   final int storyId;
//   final Changes changes;
//   final ViewType viewType;

//   CheckStory({
//     required this.token,
//     this.subscribers,
//     required this.changes,
//     required this.viewType,
//   });
// }

class LogOut extends UserEvent {}
