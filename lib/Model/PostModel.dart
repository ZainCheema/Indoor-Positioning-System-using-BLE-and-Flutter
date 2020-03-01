// Help:
// https://medium.com/flutter/some-options-for-deserializing-json-with-flutter-7481325a4450

import 'UserModel.dart';
import 'CommentModel.dart';

class Post {
  const Post({this.user, this.postID, this.postText, this.comments});

  final User user;
  final String postID;
  final String postText;
  final List<Comment> comments;

  factory Post.fromJson(Map<dynamic, dynamic> json) {
    
    List<Comment> populateComments(Map commentsObj) {
      List<Comment> comments;
      commentsObj.forEach((key, values) {
        comments.add(Comment.fromJson(values));
      });
      return comments;
    }

    return Post(
        user: User.fromJson(json['User']),
        postID: json['PostID'].toString(),
        postText: json['PostText'].toString(),
        comments: populateComments(json['Comments']));
  }

  Map<dynamic, dynamic> toJson() => {
        'User': user,
        'PostID': postID,
        'PostText': postText,
        'Comments': comments,
      };
}
