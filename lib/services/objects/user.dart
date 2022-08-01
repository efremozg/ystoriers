import 'package:y_storiers/services/objects/post.dart';

class UserModel {
  UserModel(this.stories, this.userName, this.imageUrl);

  final List<StoryModel> stories;
  final String userName;
  final String imageUrl;
}

// class User {
//   User({
//     required this.userName,
//     required this.description,
//     required this.imageUrl,
//   });
//   final String userName;
//   final String description;
//   final String imageUrl;
// }

class StoryModel {
  StoryModel(this.imageUrl, this.mediaType);

  final String imageUrl;
  final MediaType mediaType;
}
