import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:random_words/random_words.dart';
import 'package:umbrella/Model/PostModel.dart';
import 'package:umbrella/Model/UserModel.dart';
import 'package:umbrella/View/NewPostDialog.dart';
import 'package:umbrella/utils.dart';
import 'package:umbrella/widgets.dart';
import 'package:uuid/uuid.dart';

import '../styles.dart';

// Help
// https://medium.com/@kfarsoft/deeping-firestore-queries-with-flutter-2210fd3b49e1

Firestore firestoreReference = Firestore.instance;
Uuid uuid = new Uuid();

List<Placemark> location = new List<Placemark>();

String country;
String postcode;
String street = "";

String usersNumber = "";

StreamSubscription postStream;

CollectionReference userPath = firestoreReference
    .collection('Country')
    .document('City')
    .collection('Street')
    .document('Users')
    .collection('User');

CollectionReference postPath = firestoreReference
    .collection('Country')
    .document('City')
    .collection('Street')
    .document('Posts')
    .collection('Post');

Future<QuerySnapshot> getAllPosts() {
  postPath.orderBy('asc');
  return firestoreReference.collection(postPath.path).getDocuments();
}

Iterable<WordPair> userNames = generateWordPairs().take(1);

String userId = uuid.v1().toString();
String userName = userNames.elementAt(0).toString();

Map<String, dynamic> userJson = {'UUID': userId, 'UserName': userName};

User user = User.fromJson(userJson);

void createUserRecord(User pUser) async {
  await userPath.add({'UUID': pUser.uuid, 'UserName': pUser.userName});
  getCountryCityStreet().then((userLocation) {
    if (userLocation != null) {

      country = userLocation[0].country;
      debugPrint("Country: $country");

      postcode = userLocation[0].postalCode;
      debugPrint("PostCode: $postcode");

      street = userLocation[0].thoroughfare;
      if(street == "") {
        street = userLocation[0].subAdministrativeArea;
      } else {
        street = "United Kingdom";
      }


      debugPrint("Street: $street");
    }
  });

  userPath.getDocuments().then((s) {
    usersNumber = s.documents.length.toString();
    debugPrint("Users: $usersNumber");
  });
}

class FeedScreen extends StatefulWidget {
  @override
  FeedScreenState createState() {
    return FeedScreenState();
  }
}

class FeedScreenState extends State<FeedScreen> {
  var tiles = new List<PostCard>();

  @override
  void initState() {
    super.initState();

    createUserRecord(user);

    postStream =
        firestoreReference.collection(postPath.path).snapshots().listen((s) {
      tiles.clear();
      for (var document in s.documents) {
        setState(() {
          tiles = List.from(tiles);
          tiles.add(PostCard(post: Post.fromJson(document.data)));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Iterable recentTiles = tiles.reversed;
    var mostRecentPosts = recentTiles.toList();

    return Scaffold(
      floatingActionButton: new FloatingActionButton(
          backgroundColor: createMaterialColor(Color(0xFFE8E6D9)),
          child: new Icon(Icons.add),
          onPressed: () {
            return newPostDialog(context, user, postPath);
          }),
      body: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new SubtitleBar(location: street, userNumber: usersNumber),
            Expanded(
              child: new ListView(
                children: mostRecentPosts,
              ),
            )
          ]),
    );
  }
}
