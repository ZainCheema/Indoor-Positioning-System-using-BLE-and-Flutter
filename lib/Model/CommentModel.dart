// Help:
// https://medium.com/flutter/some-options-for-deserializing-json-with-flutter-7481325a4450
import 'UserModel.dart';

class Comment {

  const Comment({this.user, this.postID, this.commentText, this.commentId, this.upvotes});
  
  // The user of the comment
  final User user;
  // The post they are commenting on
  final String postID;
  // What they commented
  final String commentText;
  // ID of comment
  final String commentId;
  // The number of upvotes they have (feature withheld for the time being)
  final int upvotes;

factory Comment.fromJson(Map<dynamic, dynamic> json) {
    return Comment(
      user: User.fromJson(json['User']),
      postID: json['PostID'].toString(),
      commentText: json['CommentText'].toString(),
      commentId: json['CommentID'].toString(),
      upvotes: json['Upvotes']
    );
}

} 