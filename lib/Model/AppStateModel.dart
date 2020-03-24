import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:uuid/uuid.dart';
import 'User.dart';
import 'package:random_words/random_words.dart';
import 'Post.dart';

class AppStateModel extends foundation.ChangeNotifier {
  
    // Singleton
  AppStateModel._();

  static AppStateModel _instance = new AppStateModel._();

  static AppStateModel get instance => _instance;
  
  bool wifiEnabled = true;
  bool gpsEnabled = true;
  bool bluetoothEnabled = true;

  Firestore firestoreReference = Firestore.instance;
  Uuid uuid = new Uuid();

  // User of the app.
  User user;

  // All nearby users.
  List<User> nearbyUsers;

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  void init() async {
    // This will check wifi, gps and bluetooth
    // If all these checks pass, create the user, then load the nearby users

    CollectionReference userPath = firestoreReference
      .collection('Country')
      .document('City')
      .collection('Street')
      .document('Users')
      .collection('User');

    if (wifiEnabled & bluetoothEnabled & gpsEnabled) {
      debugPrint("init() called");



      Iterable<WordPair> userNames = generateWordPairs().take(1);

      String userId = uuid.v1().toString();
      String userName = userNames.elementAt(0).toString();

      Map<String, dynamic> userJson = {'UUID': userId, 'UserName': userName};

      user = new User.fromJson(userJson);
    }

    await userPath.add({'UUID': user.uuid, 'UserName': user.userName});
  }

  void loadNearbyUsers() {}

  User getUser() {
    return user;
  }

  void removeUser() {}

  void getNearbyUser() {}
}
