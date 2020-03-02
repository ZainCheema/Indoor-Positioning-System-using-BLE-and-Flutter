import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_words/random_words.dart';
import 'package:umbrella/Model/ModelTester.dart';
import 'package:umbrella/widgets.dart';



var firestoreReference = Firestore.instance;

List<PostCard> dummyPostCards = ModelTester.generateDummyPosts(5);

class FeedScreen extends StatefulWidget {
  @override
  FeedScreenState createState() {
    return FeedScreenState();
  }
}

class FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();

    Iterable<WordPair> userNames = generateWordPairs().take(5);

    for (int i = 0; i < userNames.length; i++) {
      firestoreReference
          .collection('User')
          .document(userNames.elementAt(i).toString())
          .setData(({"Person": "Added"}));
    }


  }

  @override
  Widget build(BuildContext context) {
    var tiles = new List<Widget>();

    for (int i = 0; i < dummyPostCards.length; i++) {
      tiles.add(dummyPostCards[i]);
    }

    return Scaffold(
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new SubtitleBar(location: "Cottingham Road", userNumber: "5"),
            Expanded(
              child: new ListView(
                children: tiles,
              ),
            )
          ],
        ),
      );
  }
}
