import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:uuid/uuid.dart';
import 'User.dart';
import 'package:random_words/random_words.dart';

class AppStateModel extends foundation.ChangeNotifier {
  // Singleton
  AppStateModel._();

  static AppStateModel _instance = new AppStateModel._();

  static AppStateModel get instance => _instance;

  bool wifiEnabled = true;
  bool gpsEnabled = true;
  bool bluetoothEnabled = true;

  Uuid uuid = new Uuid();

  // User of the app.
  User user;

  String iBeaconUUID;

  // A list of all users in the app.
  List<User> allUsers;

  // All nearby users.
  List<User> nearbyUsers;

  CollectionReference userPath = Firestore.instance
      .collection('Country')
      .document('City')
      .collection('Street')
      .document('Users')
      .collection('User');

  CollectionReference postPath = Firestore.instance
          .collection('Country')
          .document('City')
          .collection('Street')
          .document('Posts')
          .collection('Post');

  
  Stream<QuerySnapshot> userSnapshots;

  StreamSubscription usersStream;
  
  Stream<QuerySnapshot> postSnapshots;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  void init() async {
    // This will check wifi, gps and bluetooth
    // If all these checks pass, create the user, then load the nearby users

    if (wifiEnabled & bluetoothEnabled & gpsEnabled) {
      debugPrint("init() called");

      Iterable<WordPair> userNames = generateWordPairs().take(1);

      String userId = uuid.v1().toString();
      iBeaconUUID = userId;
      userId = userId.replaceAll(RegExp('-'), '');

      if(Platform.isAndroid) {
        // For Android, the user's uuid has to be 20 chars long to conform
        // with Eddystones NamespaceId length
        // Also has to be without hyphens
        userId = userId.substring(0, 20);

        if(userId.length == 20) {
         // debugPrint(userId);
          debugPrint("Android users ID is the correct format");
        } else {
          debugPrint(userId);
          // debugPrint(userId.length.toString());
          debugPrint("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        }
      }

      String userName = userNames.elementAt(0).toString();

      Map<String, dynamic> userJson = {'UUID': userId, 'UserName': userName};

      user = new User.fromJson(userJson);

      allUsers = new List<User>();

      nearbyUsers = new List<User>();

      userSnapshots = Firestore.instance
                .collection(userPath.path)
                .snapshots();

      usersStream = userSnapshots.listen((s) {
        debugPrint("USER ADDED");
        allUsers.clear();
        for(var document in s.documents) {
          allUsers = List.from(allUsers);
          allUsers.add(User.fromJson(document.data));
        }
        debugPrint("ALL USERS: " + allUsers.length.toString());
      });

      postSnapshots = Firestore.instance
                .collection(postPath.path)
                .snapshots();
    }

    await userPath.document(user.uuid).setData({'UUID': user.uuid, 'UserName': user.userName});
  }

  void loadNearbyUsers() {}

  void addNearbyUser(User pUser) {
    nearbyUsers.add(pUser);
  }

  List<User> getNearbyUsers() {
    return nearbyUsers;
  }

  List<User> getAllUsers() {
    return allUsers;
  }

  User getUser() {
    return user;
  }

  String getIBeaconUUID() {
    return iBeaconUUID;
  }

  CollectionReference getPostPath() {
    return postPath;
  }

  void removeUser() {}

  void getNearbyUser() {}
}
