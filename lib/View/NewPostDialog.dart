import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:umbrella/Model/UserModel.dart';
import 'package:uuid/uuid.dart';

TextEditingController textEditingController = new TextEditingController();

newPostDialog(BuildContext context, User user, CollectionReference postPath) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('NEW POST'),
          content: TextField(
            controller: textEditingController,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new FlatButton(
                  child: new Icon(Icons.send, color: Colors.black,),
                  onPressed: () {
                    Uuid uuid = new Uuid();
                    String postId = uuid.v1().toString();

                    String postText = textEditingController.text;

                    postPath.document(postId).setData({
                      'User': user.toJson(),
                      'PostID': postId,
                      'PostText': postText
                    });

                    textEditingController.clearComposing();

                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          ],
        );
      });
}
