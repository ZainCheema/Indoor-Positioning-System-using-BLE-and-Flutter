import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:umbrella/Model/AppStateModel.dart';
import 'package:umbrella/Model/Post.dart';
import 'package:umbrella/Model/User.dart';
import 'package:umbrella/View/NewPostDialog.dart';
import 'package:umbrella/utils.dart';
import 'package:umbrella/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../styles.dart';

// Help
// https://medium.com/@kfarsoft/deeping-firestore-queries-with-flutter-2210fd3b49e1

List<Placemark> location = new List<Placemark>();

String country;
String postcode;
String street = "";

String usersNumber = "";

StreamSubscription postStream;

class FeedScreen extends StatefulWidget {
  @override
  FeedScreenState createState() {
    return FeedScreenState();
  }
}

class FeedScreenState extends State<FeedScreen> {
  List<PostCard> tiles;

  @override
  void initState() {
    debugPrint("FeedScreen initState() called");
    tiles = new List<PostCard>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("FeedScreen Widget build(BuildContext context) called");

    AppStateModel.instance.loadPosts();

    List<Post> initialPosts = AppStateModel.instance.getPosts();

    debugPrint("Number of Initial Posts: " + initialPosts.length.toString());

    setState(() {
      initialPosts
          .forEach((post) => tiles.add(PostCard(post: Post.fromJson(post))));
    });

    Iterable recentTiles = tiles.reversed;
    var mostRecentPosts = recentTiles.toList();
    debugPrint("Number of posts: " + tiles.length.toString());

    return Consumer<AppStateModel>(builder: (context, model, child) {
      postStream = model.postSnapshots.listen((s) {
        debugPrint("New post made, loaded");
        tiles.clear();
        for (var document in s.documents) {
          setState(() {
            tiles = List.from(tiles);
            tiles.add(PostCard(post: Post.fromJson(document.data)));
          });
        }
      });

    if(tiles.length != 0) {
      return Scaffold(
        floatingActionButton: new FloatingActionButton(
            backgroundColor: createMaterialColor(Color(0xFFE8E6D9)),
            child: new Icon(Icons.add),
            onPressed: () {
              return newPostDialog(
                  context, model.getUser(), model.getPostPath());
            }),
        body: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new SubtitleBar(
                  left: model.getUser().userName, right: usersNumber),
              Expanded(
                child: new ListView(
                  children: mostRecentPosts,
                ),
              )
            ]),
      );
    } else {
      debugPrint("There are no posts that have been made");
      return Container(
        child: Text('It feels lonely :(', textAlign: TextAlign.center,)
      );
     }
    });
  }
}
