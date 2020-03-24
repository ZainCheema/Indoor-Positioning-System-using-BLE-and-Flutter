// Help:
// https://medium.com/flutter/some-options-for-deserializing-json-with-flutter-7481325a4450

import 'User.dart';
import 'Comment.dart';

class Post {
  const Post({this.user, this.postID, this.postText, /*this.comments*/});

  final User user;
  final String postID;
  final String postText;
  //final List<Comment> comments;

  factory Post.fromJson(var json) {
    
    // List<Comment> populateComments(List<Map<dynamic, dynamic>>  commentsObj) {
    //   List<Comment> comments = new List<Comment>();
    //   commentsObj.forEach((json) =>
    //     comments.add(Comment.fromJson(json)));
    //   return comments;
    // }

    return Post(
        user: User.fromJson(json['User']),
        postText: json['PostText'].toString(),
        postID: json['PostID'].toString(),
        //comments: populateComments(json['Comments'])
    );
  }

  Map<dynamic, dynamic> toJson() => {
        'User': user,
        'PostID': postID,
        'PostText': postText,
        //'Comments': comments,
      };
}
